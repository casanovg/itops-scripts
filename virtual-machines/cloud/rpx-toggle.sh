#!/usr/bin/env bash
#
# rpx-toggle.sh — Pause / resume ONE reverse-proxy vhost on this host
#                 without stopping all of nginx or the downstream backends.
#
# Shared server-agnostic script: the same file runs on every reverse-proxy host.
# Versioned source: ~/itops-scripts/virtual-machines/cloud/rpx-toggle.sh
#   (casanovg/itops-scripts repo, cloned on every host). Installed at
#   /usr/local/sbin/rpx-toggle.sh (`sudo install -m 755 ...`).
#
# DYNAMIC discovery (no hardcoded list): a "service" is each `loc.*.conf`
#   or `rpx.*.conf` file in CONF_DIR (what nginx loads via `include *.conf`).
#   Everything else is excluded: *.bak*, *.backup, *.___conf___, snippets
#   such as cloudflare-real-ip.conf, etc.
#   `loc|rpx.*.conf.disabled` files show up as HARD-OFF.
#   Service key = filename without prefix (rpx./loc.) or .conf
#   (e.g. rpx.ai-ollama.conf → ai-ollama). The full basename or the
#   FQDN (server_name) are also accepted.
#   `loc.*` vhosts (services LOCAL to this host) require --force.
#
# Default mechanism (soft): the live vhost is backed up to BACKUP_DIR and replaced
#   with a stub using the SAME server_name and the SAME LE certs that returns 503
#   "Servicio no disponible en este momento / Service temporarily unavailable".
#   TLS keeps terminating (no Cloudflare 525/526) and the certbot-renew
#   timer (DNS-01) keeps renewing without touching HTTP.
# Mechanism --hard: foo.conf → foo.conf.disabled (nginx only loads *.conf).
#   The SNI no longer matches and Cloudflare returns 525/526: emergencies only.
#
# Usage:
#   rpx-toggle.sh status [svc|fqdn|all]...   # status (default: everything discovered)
#   rpx-toggle.sh list                        # inventory: only loc./rpx. (.conf/.disabled)
#   rpx-toggle.sh off <svc|fqdn>... [--hard] [--force]   # 'all' only with --force
#   rpx-toggle.sh on  <svc|fqdn>... [--hard] [--force]
#
# Examples:
#   rpx-toggle.sh off <svc>
#   rpx-toggle.sh off <fqdn1> <fqdn2>
#   rpx-toggle.sh off <svc-local> --force   # loc.* = local service
#
set -euo pipefail

CONF_DIR="${CONF_DIR:-/etc/nginx/conf.d}"
BACKUP_DIR="${BACKUP_DIR:-/root/nginx-rpx-baks}"
STUB_MARKER="rpx-toggle: maintenance stub"

usage() {
  sed -n '2,/^set /p' "$0" | sed 's/^# \{0,1\}//'
}

discover() { # "STATE|basename" — loc./rpx.*.conf (what nginx loads) + their .disabled
  local f base
  shopt -s nullglob
  local files=("$CONF_DIR"/loc.*.conf "$CONF_DIR"/rpx.*.conf \
               "$CONF_DIR"/loc.*.conf.disabled "$CONF_DIR"/rpx.*.conf.disabled)
  shopt -u nullglob
  for f in "${files[@]}"; do
    base=$(basename "$f")
    if [[ "$base" == *.disabled ]]; then echo "HARD-OFF|${base%.disabled}"
    elif grep -q "$STUB_MARKER" "$f"; then echo "STUB-OFF|$base"
    else echo "LIVE|$base"; fi
  done
}

server_names() { # <file> → unique public server_names; "" if no directive; "_" if catch-all
  local raw names
  raw=$(grep -hE '^\s*server_name\s+' "$1" 2>/dev/null || true)
  [[ -z "$raw" ]] && { echo ""; return 0; }
  names=$(echo "$raw" \
    | sed -E 's/^\s*server_name\s+//; s/;\s*(#.*)?$//' \
    | tr ' ' '\n' | grep -vE '^(_|localhost)$' | sort -u | tr '\n' ' ' | sed 's/ *$//' || true)
  [[ -z "$names" ]] && names="_"
  echo "$names"
}

ssl_paths() { # <file> → "<fullchain> <privkey>" (empty if no TLS)
  local crt key
  crt=$(grep -m1 -oP '^\s*ssl_certificate\s+\K[^;\s]+' "$1" 2>/dev/null || true)
  key=$(grep -m1 -oP '^\s*ssl_certificate_key\s+\K[^;\s]+' "$1" 2>/dev/null || true)
  echo "$crt $key"
}

stem_of() { # <basename> → key (no rpx./loc. prefix, no .conf/.disabled)
  local b="$1"
  b="${b%.disabled}"
  b="${b%.conf}"
  b="${b#rpx.}"
  b="${b#loc.}"
  echo "$b"
}

resolve() { # <svc|fqdn|basename> → basenames (one per line); rc=1 on no match
  local a="${1%.disabled}" st base stem exact=() fuzzy=()
  while IFS='|' read -r st base; do
    if [[ "$base" == "$a" || "$base" == "$a.conf" ]]; then exact+=("$base"); continue; fi
    stem=$(stem_of "$base")
    if [[ "$stem" == "$a" ]]; then fuzzy+=("$base"); continue; fi
    if [[ "$a" == *.* ]] && server_names "$(vhost_path "$base")" | tr ' ' '\n' | grep -qxF "$a"; then
      fuzzy+=("$base")
    fi
  done < <(discover)
  if [[ ${#exact[@]} -gt 0 ]]; then printf '%s\n' "${exact[@]}"; return 0; fi
  if [[ ${#fuzzy[@]} -gt 1 ]]; then
    echo "Ambiguous '$1': ${fuzzy[*]} — use the full filename" >&2; return 1
  fi
  if [[ ${#fuzzy[@]} -eq 0 ]]; then
    echo "Unknown '$1'. Discovered: $(discover | cut -d'|' -f2 | paste -sd' ' -)" >&2; return 1
  fi
  printf '%s\n' "${fuzzy[@]}"
}

is_soft_off() { [[ -f "$CONF_DIR/$1" ]] && grep -q "$STUB_MARKER" "$CONF_DIR/$1"; }
is_hard_off() { [[ ! -f "$CONF_DIR/$1" && -f "$CONF_DIR/$1.disabled" ]]; }

vhost_path() { # <live-basename> → existing path (live or .disabled)
  if [[ -f "$CONF_DIR/$1" ]]; then echo "$CONF_DIR/$1"; else echo "$CONF_DIR/$1.disabled"; fi
}

reload_nginx() {
  nginx -t || return 1
  if systemctl is-active --quiet nginx 2>/dev/null; then
    systemctl reload nginx && echo "nginx reloaded."
  else
    echo "nginx stopped — changes validated (nginx -t OK), they apply on start."
  fi
}

write_stub() { # <live-file> <backup-path>
  local live="$1" bak="$2" names crt key
  names=$(server_names "$live")
  read -r crt key < <(ssl_paths "$live")
  [[ -z "${names// }" ]] && { echo "Could not extract server_name from $live" >&2; return 1; }
  {
    echo "# $STUB_MARKER (off) — original at $bak"
    echo "# Generated: $(date -u +%FT%TZ) — rpx-toggle.sh off"
    echo "server {"
    echo "    listen 80;"
    echo "    server_name $names;"
    echo "    location / { return 503; }"
    echo "    error_page 503 @maintenance;"
    echo "    location @maintenance {"
    echo "        default_type text/html;"
    echo "        return 503 '<html><body style=\"font-family:sans-serif;text-align:center;margin-top:10%\">"
    echo "            <h1>Servicio no disponible en este momento</h1><p>Service temporarily unavailable.</p></body></html>';"
    echo "    }"
    echo "}"
    if [[ -n "$crt" && -n "$key" ]]; then
      echo "server {"
      echo "    listen 443 ssl;"
      echo "    server_name $names;"
      echo "    ssl_certificate $crt;"
      echo "    ssl_certificate_key $key;"
      echo "    include /etc/letsencrypt/options-ssl-nginx.conf;"
      echo "    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;"
      echo "    add_header Retry-After 3600 always;"
      echo "    location / { return 503; }"
      echo "    error_page 503 @maintenance;"
      echo "    location @maintenance {"
      echo "        default_type text/html;"
      echo "        return 503 '<html><body style=\"font-family:sans-serif;text-align:center;margin-top:10%\">"
      echo "            <h1>Servicio no disponible en este momento</h1><p>Service temporarily unavailable.</p></body></html>';"
      echo "    }"
      echo "}"
    fi
  }
}

do_status() { # basenames (one per line via stdin) → table
  printf '%-22s %-32s %-16s %s\n' SERVICE FILE STATE SERVER_NAME
  local base st names
  while IFS= read -r base; do
    [[ -z "$base" ]] && continue
    if is_soft_off "$base"; then st="OFF (soft 503)"
    elif is_hard_off "$base"; then st="OFF (hard .disabled)"
    else st="ON"; fi
    names=$(server_names "$(vhost_path "$base")" 2>/dev/null || true)
    [[ -z "$names" ]] && names="-"
    printf '%-22s %-32s %-16s %s\n' "$(stem_of "$base")" "$base" "$st" "$names"
  done
}

do_list() { # inventory: only loc./rpx.*.conf and their .disabled
  printf '%-38s %-10s %-22s %s\n' FILE STATE SERVICE SERVER_NAME
  local f base st svc names
  shopt -s nullglob
  local files=("$CONF_DIR"/loc.*.conf "$CONF_DIR"/rpx.*.conf \
               "$CONF_DIR"/loc.*.conf.disabled "$CONF_DIR"/rpx.*.conf.disabled)
  shopt -u nullglob
  for f in "${files[@]}"; do
    base=$(basename "$f")
    names="-"
    if [[ "$base" == *.disabled ]]; then
      st="HARD-OFF"; base="${base%.disabled}"
    elif grep -q "$STUB_MARKER" "$f"; then st="STUB-OFF"
    else st="LIVE"; fi
    svc=$(stem_of "$base")
    names=$(server_names "$CONF_DIR/$base" 2>/dev/null || server_names "$f" || true)
    [[ -z "$names" ]] && names="-"
    printf '%-38s %-10s %-22s %s\n' "$base" "$st" "$svc" "$names"
  done
}

do_off() { # basenames (args) + hard flag
  local hard="$1"; shift
  local ts f live changed=0
  ts=$(date +%Y%m%d-%H%M%S)
  mkdir -p "$BACKUP_DIR"
  for f in "$@"; do
    live="$CONF_DIR/$f"
    if is_soft_off "$f"; then echo "$f: already OFF (soft), skip"; continue; fi
    if is_hard_off "$f"; then echo "$f: already OFF (hard), skip"; continue; fi
    if [[ "$hard" == 1 ]]; then
      cp -a "$live" "$BACKUP_DIR/${f}.${ts}.hardbak"
      mv "$live" "$live.disabled"
      echo "$f: OFF hard (→ $f.disabled, backup in $BACKUP_DIR)"
      changed=1
    else
      local bak="$BACKUP_DIR/${f}.${ts}.softbak"
      cp -a "$live" "$bak"
      write_stub "$live" "$bak" > "$live.new" || { echo "$f: ERROR generating stub, untouched" >&2; return 1; }
      mv "$live.new" "$live"
      echo "$f: OFF soft 503 (original at $bak)"
      changed=1
    fi
  done
  if [[ "$changed" == 1 ]]; then reload_nginx; else echo "No changes — nginx untouched."; fi
}

do_on() { # basenames (args) + hard flag
  local hard="$1"; shift
  local f live latest changed=0
  for f in "$@"; do
    live="$CONF_DIR/$f"
    if [[ "$hard" == 1 ]]; then
      if is_hard_off "$f"; then
        mv "$live.disabled" "$live"
        echo "$f: ON (restored from .disabled)"
        changed=1
      else echo "$f: was not OFF hard, skip"; fi
    else
      if is_soft_off "$f"; then
        latest=$(ls -t "$BACKUP_DIR/${f}."*.softbak 2>/dev/null | head -1 || true)
        [[ -n "$latest" ]] || { echo "$f: stub without backup in $BACKUP_DIR, untouched" >&2; continue; }
        cp -a "$latest" "$live"
        echo "$f: ON (restored from $latest)"
        changed=1
      else echo "$f: was not OFF soft, skip"; fi
    fi
  done
  if [[ "$changed" == 1 ]]; then reload_nginx; else echo "No changes — nginx untouched."; fi
}

main() {
  [[ $# -ge 1 ]] || { usage; return 1; }
  case "$1" in
    -h|--help|help) usage; return 0 ;;
  esac
  local cmd="$1"; shift
  local hard=0 force=0 targets=()
  local a
  for a in "$@"; do
    case "$a" in
      --hard) hard=1 ;; --force) force=1 ;; *) targets+=("$a") ;;
    esac
  done
  if [[ "$cmd" == list ]]; then do_list; return 0; fi
  if [[ "$cmd" != status && "$cmd" != off && "$cmd" != on ]]; then usage; return 1; fi
  if [[ ("$cmd" == off || "$cmd" == on) && $EUID -ne 0 && -z "${RPX_ALLOW_NONROOT:-}" ]]; then
    echo "off/on require root (they read certs/logs and reload nginx): retry with sudo." >&2; return 1
  fi
  local files=() t r
  if [[ ${#targets[@]} -eq 0 || " ${targets[*]} " == *" all "* ]]; then
    if [[ "$cmd" != status && "$force" != 1 ]]; then
      echo "'$cmd all' requires --force (it affects every discovered vhost)" >&2; return 1
    fi
    while IFS='|' read -r _ base; do files+=("$base"); done < <(discover)
  else
    for t in "${targets[@]}"; do
      r=$(resolve "$t") || return 1
      while IFS= read -r base; do files+=("$base"); done <<< "$r"
    done
  fi
  if [[ "$cmd" != status && "$force" != 1 ]]; then
    for base in "${files[@]}"; do
      if [[ "$base" == loc.* ]]; then
        echo "$base is a LOCAL service (loc.*): retry with --force." >&2; return 1
      fi
    done
  fi
  case "$cmd" in
    status) printf '%s\n' "${files[@]}" | do_status ;;
    off)    do_off "$hard" "${files[@]}" ;;
    on)     do_on "$hard" "${files[@]}" ;;
  esac
}

main "$@"
