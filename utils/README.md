# Utils

Various general utility scripts.

## itops-scripts synchronization

`git-sync.sh` synchronizes this repository. It is idempotent: concurrent
runs are serialized with `flock`, a second run without changes is a no-op,
pulls are fast-forward only (never merge commits), and diverged histories
are rebased when clean or reported with exit code `2` otherwise. The GitHub
token never appears in push URLs; pushes use the `git-askpass-github.sh`
helper.

```bash
# Normal mode (cron default): commit local changes, fast-forward, push
~/itops-scripts/utils/git-sync.sh ~/itops-scripts/

# Read-only consumer: only fast-forward, never commit or push
~/itops-scripts/utils/git-sync.sh ~/itops-scripts/ --read-only
```

Existing `cron/*.crontab` entries keep working unchanged: the optional
positional repo path is still accepted. No crontab changes are required;
machines pick up the new script on their next pull.

## Secrets vault synchronization

`secrets-sync.sh` synchronizes the private `secrets-vault` repository. It is
designed for a binary KeePass database, so it never merges conflicts
automatically.

```bash
# Normal mode: commit local changes, fast-forward, push
~/itops-scripts/utils/secrets-sync.sh

# Read-only machine: only fast-forward, never commit or push
~/itops-scripts/utils/secrets-sync.sh --read-only

# Custom paths
~/itops-scripts/utils/secrets-sync.sh \
    --repo ~/secrets-vault \
    --db vault/hta-itops.kdbx
```

On divergence it saves both database versions under
`~/secrets-vault-backups/`, exits with code `2` and prints the manual
KeePassXC merge procedure. It does not overwrite either version.

Credentials are read from `~/.github-usr` and `~/.github-pwd` through the
`git-askpass-github.sh` helper. Those files are only obfuscated with a fixed
OpenSSL passphrase; SSH deploy keys or a proper credential helper are
recommended as a next step.

### Install the hourly cron job

Install ONLY on these four hosts (vault scope):

- nb-comet (this workstation)
- nb-spirit, hta-opportunity, hta-enterprise

```bash
~/itops-scripts/utils/install-secrets-cron.sh --dry-run
~/itops-scripts/utils/install-secrets-cron.sh
```

Each host gets a different minute to reduce concurrent pushes. The next
`crontab -l > cron/<host>.crontab` job mirrors the change into the repository.

## Human-driven sessions

`git-sync-careful.sh` is the interactive counterpart of `git-sync.sh` for
human sessions with uncommitted work from others. It never stages files you
did not name (`--only f1 f2`, or `--all`), runs secrets hygiene before
committing, pulls with `--rebase --autostash`, stops on conflicts instead
of pushing a mess, and pushes only with `--push`. Default with no `-m` is
`--check` (read-only report).

```bash
~/itops-scripts/utils/git-sync-careful.sh --check ~/itops-scripts/
~/itops-scripts/utils/git-sync-careful.sh -m "docs: ..." --only utils/x.sh --push ~/itops-scripts/
```
