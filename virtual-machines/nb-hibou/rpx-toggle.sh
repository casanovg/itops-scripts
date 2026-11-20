#!/usr/bin/env bash
#
# rpx-toggle.sh — Pausa / reanuda UN vhost del reverse proxy NB-Hibou
#                 sin detener nginx completo ni los hosts downstream (.20, .21, .35...).
#
# Host: NB-Hibou (10.77.77.33) — CONF_DIR=/etc/nginx/conf.d
# Fuente versionada: ~/itops-scripts/virtual-machines/nb-hibou/rpx-toggle.sh
#   (repo casanovg/itops-scripts, clonado en cada host). Instalado en
#   /usr/local/sbin/rpx-toggle.sh (`sudo install -m 755 ...`).
#
# Descubrimiento DINÁMICO (sin lista fija): un "servicio" es cada archivo
#   `loc.*.conf` o `rpx.*.conf` de CONF_DIR (los que nginx carga con
#   `include *.conf`). Queda afuera todo lo demás: *.bak*, *.backup,
#   *.___conf___, snippets como cloudflare-real-ip.conf, etc.
#   Los `loc|rpx.*.conf.disabled` se muestran como HARD-OFF.
#   Clave del servicio = nombre de archivo sin prefijo (rpx./loc.) ni
#   .conf (p. ej. rpx.ai-ollama.conf → ai-ollama). También se acepta el
#   basename completo o el FQDN (server_name).
#   Los vhosts `loc.*` (servicios LOCALES del propio host) exigen --force.
#
# Mecanismo default (soft): el vhost vivo se respalda en BACKUP_DIR y se reemplaza
#   por un stub con el MISMO server_name y los MISMOS certs LE que devuelve 503
#   "Servicio no disponible en este momento / Service temporarily unavailable".
#   TLS sigue terminando (Cloudflare no da 525/526) y el timer certbot-renew
#   (DNS-01) sigue renovando sin tocar HTTP.
# Mecanismo --hard: foo.conf → foo.conf.disabled (nginx solo carga *.conf).
#   El SNI queda sin match y Cloudflare devuelve 525/526: solo emergencias.
#
# Uso:
#   rpx-toggle.sh status [svc|fqdn|all]...   # estado (default: todo lo descubierto)
#   rpx-toggle.sh list                        # inventario: solo loc./rpx. (.conf/.disabled)
#   rpx-toggle.sh off <svc|fqdn>... [--hard] [--force]   # 'all' solo con --force
#   rpx-toggle.sh on  <svc|fqdn>... [--hard] [--force]
#
# Ejemplos:
#   rpx-toggle.sh off ai-ollama
#   rpx-toggle.sh off ai.w1.ar photos.w1.ar
#   rpx-toggle.sh off seafile-and-calibre --force   # loc.* = servicio local
#
set -euo pipefail

CONF_DIR="${CONF_DIR:-/etc/nginx/conf.d}"
BACKUP_DIR="${BACKUP_DIR:-/root/nginx-rpx-baks}"
STUB_MARKER="rpx-toggle: maintenance stub"

usage() {
  sed -n '2,/^set /p' "$0" | sed 's/^# \{0,1\}//'
}

discover() { # "ESTADO|basename" — loc./rpx.*.conf (los que nginx carga) + sus .disabled
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

server_names() { # <file> → server_names públicos únicos; "" si no hay directiva; "_" si es catch-all
  local raw names
  raw=$(grep -hE '^\s*server_name\s+' "$1" 2>/dev/null || true)
  [[ -z "$raw" ]] && { echo ""; return 0; }
  names=$(echo "$raw" \
    | sed -E 's/^\s*server_name\s+//; s/;\s*(#.*)?$//' \
    | tr ' ' '\n' | grep -vE '^(_|localhost)$' | sort -u | tr '\n' ' ' | sed 's/ *$//' || true)
  [[ -z "$names" ]] && names="_"
  echo "$names"
}

ssl_paths() { # <file> → "<fullchain> <privkey>" (vacío si no tiene TLS)
  local crt key
  crt=$(grep -m1 -oP '^\s*ssl_certificate\s+\K[^;\s]+' "$1" 2>/dev/null || true)
  key=$(grep -m1 -oP '^\s*ssl_certificate_key\s+\K[^;\s]+' "$1" 2>/dev/null || true)
  echo "$crt $key"
}

stem_of() { # <basename> → clave (sin prefijo rpx./loc. ni .conf/.disabled)
  local b="$1"
  b="${b%.disabled}"
  b="${b%.conf}"
  b="${b#rpx.}"
  b="${b#loc.}"
  echo "$b"
}

resolve() { # <svc|fqdn|basename> → basenames (uno por línea); rc=1 si no matchea
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
    echo "Ambiguo '$1': ${fuzzy[*]} — usá el nombre de archivo completo" >&2; return 1
  fi
  if [[ ${#fuzzy[@]} -eq 0 ]]; then
    echo "Desconocido '$1'. Descubiertos: $(discover | cut -d'|' -f2 | paste -sd' ' -)" >&2; return 1
  fi
  printf '%s\n' "${fuzzy[@]}"
}

is_soft_off() { [[ -f "$CONF_DIR/$1" ]] && grep -q "$STUB_MARKER" "$CONF_DIR/$1"; }
is_hard_off() { [[ ! -f "$CONF_DIR/$1" && -f "$CONF_DIR/$1.disabled" ]]; }

vhost_path() { # <live-basename> → ruta existente (live o .disabled)
  if [[ -f "$CONF_DIR/$1" ]]; then echo "$CONF_DIR/$1"; else echo "$CONF_DIR/$1.disabled"; fi
}

reload_nginx() {
  nginx -t || return 1
  if systemctl is-active --quiet nginx 2>/dev/null; then
    systemctl reload nginx && echo "nginx recargado."
  else
    echo "nginx detenido — cambios validados (nginx -t OK), aplican al iniciarlo."
  fi
}

write_stub() { # <live-file> <backup-path>
  local live="$1" bak="$2" names crt key
  names=$(server_names "$live")
  read -r crt key < <(ssl_paths "$live")
  [[ -z "${names// }" ]] && { echo "No se pudo extraer server_name de $live" >&2; return 1; }
  {
    echo "# $STUB_MARKER (off) — original en $bak"
    echo "# Generado: $(date -u +%FT%TZ) — rpx-toggle.sh off"
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

do_status() { # basenames (uno por línea vía stdin) → tabla
  printf '%-22s %-32s %-16s %s\n' SERVICIO ARCHIVO ESTADO SERVER_NAME
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

do_list() { # inventario: solo loc./rpx.*.conf y sus .disabled
  printf '%-38s %-10s %-22s %s\n' ARCHIVO ESTADO SERVICIO SERVER_NAME
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
  local ts f live
  ts=$(date +%Y%m%d-%H%M%S)
  mkdir -p "$BACKUP_DIR"
  for f in "$@"; do
    live="$CONF_DIR/$f"
    if is_soft_off "$f"; then echo "$f: ya OFF (soft), skip"; continue; fi
    if is_hard_off "$f"; then echo "$f: ya OFF (hard), skip"; continue; fi
    if [[ "$hard" == 1 ]]; then
      cp -a "$live" "$BACKUP_DIR/${f}.${ts}.hardbak"
      mv "$live" "$live.disabled"
      echo "$f: OFF hard (→ $f.disabled, backup en $BACKUP_DIR)"
    else
      local bak="$BACKUP_DIR/${f}.${ts}.softbak"
      cp -a "$live" "$bak"
      write_stub "$live" "$bak" > "$live.new" || { echo "$f: ERROR generando stub, no se tocó" >&2; return 1; }
      mv "$live.new" "$live"
      echo "$f: OFF soft 503 (original en $bak)"
    fi
  done
  reload_nginx
}

do_on() { # basenames (args) + hard flag
  local hard="$1"; shift
  local f live latest
  for f in "$@"; do
    live="$CONF_DIR/$f"
    if [[ "$hard" == 1 ]]; then
      if is_hard_off "$f"; then
        mv "$live.disabled" "$live"
        echo "$f: ON (restaurado desde .disabled)"
      else echo "$f: no estaba OFF hard, skip"; fi
    else
      if is_soft_off "$f"; then
        latest=$(ls -t "$BACKUP_DIR/${f}."*.softbak 2>/dev/null | head -1 || true)
        [[ -n "$latest" ]] || { echo "$f: stub sin backup en $BACKUP_DIR, no toco" >&2; continue; }
        cp -a "$latest" "$live"
        echo "$f: ON (restaurado desde $latest)"
      else echo "$f: no estaba OFF soft, skip"; fi
    fi
  done
  reload_nginx
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
  local files=() t r
  if [[ ${#targets[@]} -eq 0 || " ${targets[*]} " == *" all "* ]]; then
    if [[ "$cmd" != status && "$force" != 1 ]]; then
      echo "'$cmd all' exige --force (afecta a todos los vhosts descubiertos)" >&2; return 1
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
        echo "$base es servicio LOCAL (loc.*): reintentá con --force." >&2; return 1
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
