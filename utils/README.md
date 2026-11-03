# Utils

Various general utility scripts.

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
    --db vault/itops.kdbx
```

On divergence it saves both database versions under
`~/secrets-vault-backups/`, exits with code `2` and prints the manual
KeePassXC merge procedure. It does not overwrite either version.

Credentials are read from `~/.github-usr` and `~/.github-pwd` through the
`git-askpass-github.sh` helper. Those files are only obfuscated with a fixed
OpenSSL passphrase; SSH deploy keys or a proper credential helper are
recommended as a next step.

### Install the hourly cron job

Run once per machine:

```bash
~/itops-scripts/utils/install-secrets-cron.sh --dry-run
~/itops-scripts/utils/install-secrets-cron.sh
```

Each host gets a different minute to reduce concurrent pushes. The next
`crontab -l > cron/<host>.crontab` job mirrors the change into the repository.
