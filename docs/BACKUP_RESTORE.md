# Backup and Restore Guide

This guide covers backing up and restoring your Vibe Palace installation across machines.

## Overview

Vibe Palace provides comprehensive backup capabilities:

- **Full Backup**: Configurations + state + planet metadata
- **Config-Only Backup**: Just your configuration files
- **Cross-Machine Restore**: Migrate to a new machine
- **Incremental Backups**: Multiple backup versions

## Backup Commands

### Create Full Backup

Back up everything (configs, state, metadata):

```bash
vibe backup
```

Output:
```
💾 Full Backup
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Creating full backup (configs + state)...
Backup complete!
Backup saved to: /home/user/.vibe-palace/backups/vibe-backup-20250118-120000.tar.gz
```

### Config-Only Backup

Back up only configuration files (smaller, faster):

```bash
vibe backup --configs
```

Use this when you:
- Want to share your dotfiles
- Only care about configs, not installation state
- Have limited space

### List Available Backups

```bash
vibe backup --list
```

Output:
```
Available backups:
/home/user/.vibe-palace/backups/vibe-backup-20250118-120000.tar.gz
/home/user/.vibe-palace/backups/vibe-backup-20250117-153000.tar.gz
/home/user/.vibe-palace/backups/vibe-configs-20250116-090000.tar.gz
```

## Backup Contents

### Full Backup Structure

```
vibe-backup-20250118-120000.tar.gz
├── configs/                    # Configuration files
│   ├── starship.toml
│   ├── nvim/
│   │   └── lua/
│   │       └── custom/
│   │           └── init.lua
│   ├── tmux.conf
│   └── ... (other configs)
├── state.json                 # Installation state
└── manifest.json              # Backup metadata
    ├── created_at: "2025-01-18T12:00:00Z"
    ├── vibe_version: "1.0.0"
    ├── planet_count: 8
    └── hostname: "machine-name"
```

### What Gets Backed Up

**Configurations:**
- `~/.config/starship.toml`
- `~/.config/nvim/` (Neovim config)
- `~/.tmux.conf`
- `~/.gitconfig` (if modified by Vibe)
- Planet-specific configurations

**State:**
- `~/.vibe-palace/state.json`
- Planet versions and installation dates
- Checksums

**Metadata:**
- Backup timestamp
- Vibe Palace version
- List of installed planets

### What Doesn't Get Backed Up

- Downloaded binaries (reinstalled on restore)
- Language packages (reinstalled on restore)
- Temporary files
- Cache files

This keeps backups small and focused.

## Restore Commands

### Restore from Backup

```bash
vibe restore vibe-backup-20250118-120000.tar.gz
```

Or use wildcards:
```bash
vibe restore vibe-backup-*.tar.gz
```

**Process:**
1. Validates backup integrity
2. Extracts configurations to `~/.config/`
3. Restores state file
4. Installs missing planets
5. Verifies restoration

### Restore Flow

```
1. Validation
   ├── Check backup file exists
   ├── Verify tar.gz integrity
   └── Validate manifest.json

2. Extraction
   ├── Backup configs to ~/.vibe-palace/restore-backup/
   ├── Extract new configs
   └── Restore state.json

3. Planet Installation
   ├── Read state.json
   ├── Calculate install order
   └── Install missing planets

4. Verification
   ├── Run health checks
   └── Report any issues
```

### Safety Features

- **Automatic Backup**: Before restoring, existing configs are backed up
- **Validation**: Backup file is validated before restoration
- **Confirmation**: You must confirm before overwriting
- **Rollback**: Can restore the previous backup if something goes wrong

## Use Cases

### 1. Cross-Machine Migration

**Scenario:** Moving from old laptop to new one.

**On old machine:**
```bash
vibe backup
# Copy backup file to external drive or cloud storage
```

**On new machine:**
```bash
git clone https://github.com/your-username/vibe-palace.git
cd vibe-palace
./vibe restore /path/to/vibe-backup-*.tar.gz
```

All your tools and configs are restored!

### 2. Share Your Dotfiles

**Scenario:** Share your configuration with others.

```bash
vibe backup --configs
# Share vibe-configs-*.tar.gz
```

Others can extract just the configs they want.

### 3. Pre-Experiment Backup

**Scenario:** Trying out a new planet or config.

```bash
vibe backup
vibe install experimental-planet
# Test it out
vibe restore vibe-backup-*.tar.gz  # If needed
```

### 4. Disaster Recovery

**Scenario:** Something went wrong, need to reset.

```bash
vibe restore vibe-backup-*.tar.gz
```

Restores your last known good state.

### 5. Multiple Machines

**Scenario:** Keep dev environments in sync.

```bash
# On machine 1
vibe backup
# Sync to cloud storage (Google Drive, Dropbox, etc.)

# On machine 2
vibe restore ~/CloudStorage/vibe-backup-*.tar.gz
```

## Advanced Usage

### Backup Location

Backups are stored in:
```
~/.vibe-palace/backups/
```

You can change this by setting:
```bash
export VIBE_BACKUP_DIR="/custom/path"
```

### Automated Backups

Add to your crontab for automatic backups:

```bash
# Daily backup at 2 AM
0 2 * * * /path/to/vibe backup

# Weekly backup on Sunday
0 2 * * 0 /path/to/vibe backup --configs
```

### Backup Rotation

Keep only recent backups:

```bash
# Keep last 7 days
find ~/.vibe-palace/backups -name "vibe-backup-*.tar.gz" -mtime +7 -delete
```

### Sync to Cloud

**rclone example:**
```bash
vibe backup
rclone copy ~/.vibe-palace/backups/ remote:vibe-backups
```

**rsync example:**
```bash
rsync -av ~/.vibe-palace/backups/ user@server:/backups/vibe/
```

## Troubleshooting

### Restore Fails

**Problem:** Restore command fails mid-way.

**Solution:**
1. Check what was restored:
   ```bash
   vibe status
   ```
2. Re-run restore:
   ```bash
   vibe restore vibe-backup-*.tar.gz
   ```
3. Or manually install missing planets:
   ```bash
   vibe install --all
   ```

### Validation Errors

**Problem:** Backup file is corrupted.

**Solution:**
- Try an older backup: `vibe backup --list`
- Re-create backup from current state

### Permission Errors

**Problem:** Can't write to `~/.config/`

**Solution:**
```bash
sudo chown -R $USER:$USER ~/.config/
```

### Planet Installation Fails During Restore

**Problem:** Planet fails to install during restore.

**Solution:**
1. State is still restored
2. Install failed planet manually:
   ```bash
   vibe install failed-planet
   ```
3. Run health check:
   ```bash
   vibe doctor
   ```

### Missing Configs After Restore

**Problem:** Some configs not restored.

**Solution:**
1. Check backup contents:
   ```bash
   tar -tzf vibe-backup-*.tar.gz
   ```
2. Extract manually:
   ```bash
   tar -xzf vibe-backup-*.tar.gz -C ~/.config/
   ```

## Best Practices

1. **Backup Regularly**: Before major changes
2. **Test Restores**: Verify backups work
3. **Keep Multiple Versions**: Don't overwrite old backups
4. **Offsite Storage**: Store backups externally
5. **Document Customizations**: Keep notes on manual changes
6. **Version Control**: Consider tracking configs in git too

## Integration with Dotfile Managers

### GNU Stow

```bash
vibe backup --configs
cd ~/.vibe-palace/backups
tar -xzf vibe-configs-*.tar.gz
stow configs
```

### chezmoi

```bash
vibe backup --configs
chezmoi add ~/.config/
```

### Manual Git

```bash
vibe backup --configs
cd ~/.dotfiles
git add ~/.config/
git commit -m "Update configs"
```

## Security Considerations

### Sensitive Data

Backups may contain:
- API keys (if in configs)
- SSH keys (if backed up)
- Personal tokens

**Recommendations:**
- Don't share public backups
- Use encryption for cloud backups:
  ```bash
  gpg -c vibe-backup-*.tar.gz
  ```
- Review contents before sharing
- Use `.gitignore` for sensitive files

### Encrypted Backups

```bash
# Encrypt
gpg -symmetric --cipher-algo AES256 vibe-backup-*.tar.gz

# Decrypt
gpg -d vibe-backup-*.tar.gz.gpg > vibe-backup-*.tar.gz
vibe restore vibe-backup-*.tar.gz
```

## FAQ

**Q: How large are backups?**
A: Typically 1-10 MB for configs only, 10-50 MB for full backup.

**Q: Can I restore a partial backup?**
A: Yes, manually extract what you need from the tar.gz.

**Q: Do backups include installed packages?**
A: No, only configs. Packages are reinstalled during restore.

**Q: Can I restore on a different OS?**
A: Linux ↔ Linux works. macOS ↔ macOS works. Cross-OS may have issues.

**Q: How often should I backup?**
A: Before major changes, or weekly for automated backups.

**Q: Can I automate restore?**
A: Yes, use `--yes` flag:
   ```bash
   vibe restore --yes vibe-backup-*.tar.gz
   ```

## See Also

- [ARCHITECTURE.md](ARCHITECTURE.md) - System architecture
- [PLANETS.md](PLANETS.md) - Planet descriptions
- [TESTING.md](TESTING.md) - Testing guide
