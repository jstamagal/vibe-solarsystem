# Troubleshooting Guide & FAQ

This guide covers common issues, solutions, and frequently asked questions about Vibe Palace.

## Table of Contents

- [Installation Issues](#installation-issues)
- [Planet-Specific Issues](#planet-specific-issues)
- [Configuration Issues](#configuration-issues)
- [Backup & Restore Issues](#backup--restore-issues)
- [Performance Issues](#performance-issues)
- [FAQ](#faq)

---

## Installation Issues

### "planet not found" Error

**Problem:**
```bash
$ ./vibe install myplanet
Error: Planet not found: myplanet
```

**Solution:**
1. Check available planets:
   ```bash
   ./vibe list
   ```

2. Verify planet file exists:
   ```bash
   ls planets/*.sh
   ```

3. Check for typos in planet name

### Permission Denied

**Problem:**
```bash
$ ./vibe install mercury
bash: ./vibe: Permission denied
```

**Solution:**
```bash
# Make vibe executable
chmod +x vibe

# Or install to /usr/local/bin
sudo ln -s $(pwd)/vibe /usr/local/bin/vibe
```

### "command not found: vibe"

**Problem:**
```bash
$ vibe install mercury
bash: vibe: command not found
```

**Solution:**

**Option 1: Use relative path**
```bash
./vibe install mercury
```

**Option 2: Add to PATH**
```bash
# Add to ~/.bashrc or ~/.zshrc
export PATH="$PATH:/path/to/vibe-palace"
```

**Option 3: Create symlink**
```bash
sudo ln -s $(pwd)/vibe /usr/local/bin/vibe
```

### Installation Hangs or Takes Too Long

**Problem:** Installation seems stuck or very slow.

**Solution:**
1. Check network connection
2. Use verbose mode:
   ```bash
   ./vibe install --verbose mercury
   ```
3. Try installing individual dependencies manually
4. Check if package manager is working:
   ```bash
   brew doctor        # macOS
   apt update         # Ubuntu/Debian
   ```

### Dependency Resolution Failure

**Problem:**
```bash
$ ./vibe install saturn
Error: Failed to calculate installation order
```

**Solution:**
1. Check dependency tree:
   ```bash
   ./vibe tree saturn
   ```

2. Install dependencies manually:
   ```bash
   ./vibe install mercury
   ./vibe install mars
   ./vibe install saturn
   ```

3. Check for circular dependencies in planet files

### "state.json corrupt" Error

**Problem:**
```bash
Error: Failed to parse state.json
```

**Solution:**
```bash
# Remove corrupt state
rm ~/.vibe-palace/state.json

# Reinitialize
./vibe status
```

---

## Planet-Specific Issues

### Mercury: Starship Not Working

**Problem:** Starship prompt not showing.

**Solution:**
1. Verify installation:
   ```bash
   starship --version
   ```

2. Check shell initialization:
   ```bash
   # For Bash
   eval "$(starship init bash)"

   # For Zsh
   eval "$(starship init zsh)"
   ```

3. Add to shell config:
   ```bash
   # Add to ~/.bashrc or ~/.zshrc
   eval "$(starship init bash)"
   ```

### Venus: Neovim Won't Launch

**Problem:**
```bash
$ nvim
Error: Cannot open configuration file
```

**Solution:**
```bash
# Reinstall Venus planet
./vibe uninstall venus
./vibe install venus

# Verify config exists
ls -la ~/.config/nvim/
```

### Mars: Language Version Issues

**Problem:** Node.js, Python, or Rust not working.

**Solution:**

**Node.js:**
```bash
fnm list-remote
fnm install 20
fnm use 20
```

**Python:**
```bash
pyenv versions
pyenv install 3.12
pyenv global 3.12
```

**Rust:**
```bash
rustc --version
# If not found, reinstall Mars
./vibe uninstall mars
./vibe install mars
```

### Jupiter: Database Clients Missing

**Problem:** Database clients not found.

**Solution:**
```bash
# Check what's installed
./vibe doctor

# Reinstall Jupiter
./vibe uninstall jupiter
./vibe install jupiter
```

### Saturn: AI Tools Not Configured

**Problem:** AI tools asking for API keys.

**Solution:**
AI tools require separate API key configuration:

**Claude Code:**
```bash
export ANTHROPIC_API_KEY="your-key"
# Add to ~/.bashrc or ~/.zshrc
```

**aichat:**
```bash
aichat config set api_key your-key
```

### Uranus: Docker Not Running

**Problem:**
```bash
$ docker ps
Error: Cannot connect to Docker daemon
```

**Solution:**
```bash
# Start Docker
sudo systemctl start docker    # Linux
open -a Docker                 # macOS

# Verify
docker ps
```

### Neptune: kubectl Not Working

**Problem:** kubectl can't connect to cluster.

**Solution:**
```bash
# Check cluster status
kubectl cluster-info

# If no cluster, install kind or minikube
kind create cluster

# Verify
kubectl get nodes
```

### Pluto: Zsh Not Default Shell

**Problem:** Zsh installed but not default.

**Solution:**
```bash
# Set Zsh as default shell
chsh -s $(which zsh)

# Log out and log back in
```

---

## Configuration Issues

### Shell Config Not Loading

**Problem:** Changes not taking effect in new terminal.

**Solution:**
```bash
# Reload shell configuration
source ~/.bashrc    # For Bash
source ~/.zshrc     # For Zsh

# Or open new terminal
```

### Conflicting Configurations

**Problem:** Multiple tools configuring the same thing.

**Solution:**
1. Check shell config for conflicts:
   ```bash
   grep -n "PS1" ~/.bashrc
   grep -n "PROMPT" ~/.zshrc
   ```

2. Comment out conflicting configs

3. Test in clean shell:
   ```bash
   bash --norc
   ```

### Custom Configs Overwritten

**Problem:** Vibe Palace overwrote your custom configs.

**Solution:**
1. Restore from backup:
   ```bash
   ~/.vibe-palace/restore-backup/
   ```

2. Add custom configs to:
   ```bash
   ~/.config/vibe/custom.sh
   ```

---

## Backup & Restore Issues

### Restore Fails

**Problem:**
```bash
$ ./vibe restore vibe-backup-*.tar.gz
Error: Restore failed
```

**Solution:**
1. Verify backup file:
   ```bash
   tar -tzf vibe-backup-*.tar.gz | head
   ```

2. Check available backups:
   ```bash
   ./vibe backup --list
   ```

3. Try specific backup:
   ```bash
   ./vibe restore /full/path/to/vibe-backup-20250118-120000.tar.gz
   ```

### Backup File Not Found

**Problem:**
```bash
Error: Backup file not found
```

**Solution:**
```bash
# List backups
ls -la ~/.vibe-palace/backups/

# Use full path
./vibe restore ~/.vibe-palace/backups/vibe-backup-*.tar.gz
```

### Permission Errors During Restore

**Problem:** Can't write to `~/.config/`.

**Solution:**
```bash
# Fix permissions
sudo chown -R $USER:$USER ~/.config/

# Retry restore
./vibe restore vibe-backup-*.tar.gz
```

---

## Performance Issues

### Slow Installation

**Problem:** Installation taking longer than expected.

**Solution:**
1. Use verbose mode to see what's happening:
   ```bash
   ./vibe install --verbose venus
   ```

2. Check internet connection
3. Close other heavy processes
4. Install planets individually:
   ```bash
   ./vibe install mercury
   ./vibe install venus
   ```

### High Memory Usage

**Problem:** System slow during installation.

**Solution:**
1. Install planets one at a time
2. Close unnecessary applications
3. Check available memory:
   ```bash
   free -h    # Linux
   vm_stat   # macOS
   ```

### Health Check Slow

**Problem:** `vibe doctor` takes too long.

**Solution:**
This is normal if many planets are installed. To speed up:

1. Check specific planet:
   ```bash
   bash -c "source planets/mercury.sh && planet_check_health"
   ```

2. Skip health checks for rarely-used planets

---

## FAQ

### General Questions

**Q: What is Vibe Palace?**
A: A modular development environment installer. Each "planet" is a component you can install independently.

**Q: Do I need to install all planets?**
A: No! Install only what you need. For example:
```bash
./vibe install mercury    # Just terminal tools
./vibe install venus      # Plus editor
```

**Q: Can I uninstall planets?**
A: Yes! Use `./vibe uninstall <planet>` to remove any planet.

**Q: Is it safe to run multiple times?**
A: Yes! Vibe Palace is idempotent - running it twice is safe.

**Q: What happens if installation fails?**
A: The system stops and reports the error. You can retry or check dependencies with `./vibe doctor`.

### System Requirements

**Q: What operating systems are supported?**
A: Linux and macOS. Windows is not supported.

**Q: Do I need sudo/root access?**
A: Sometimes, depending on the tool. Most tools install to `~/.local/` and don't require sudo.

**Q: How much disk space is needed?**
A: Approximately 2-5 GB for all planets, depending on which tools you install.

### Customization

**Q: Can I add my own tools?**
A: Yes! Create a custom planet. See `examples/custom-planet.sh` for a template.

**Q: Can I modify existing planets?**
A: Yes, but be careful. Changes may be overwritten when updating. Consider creating a custom planet instead.

**Q: How do I add custom shell configurations?**
A: Add to `~/.config/vibe/custom.sh` (auto-sourced) or directly to `~/.bashrc`/`~/.zshrc`.

### Updates & Maintenance

**Q: How do I update Vibe Palace?**
A:
```bash
cd /path/to/vibe-palace
git pull origin main
```

**Q: How do I update installed tools?**
A: Use the tool's native update mechanism:
```bash
brew upgrade          # Homebrew tools
fnm install latest    # Node.js
rustup update        # Rust
```

**Q: Do planets auto-update?**
A: No. You control when to update. This prevents unexpected changes.

### Backup & Restore

**Q: How often should I backup?**
A: Before major changes, or weekly if you make frequent changes.

**Q: Can I sync between machines?**
A: Yes! Use backup/restore:
```bash
# Machine 1
./vibe backup

# Machine 2
./vibe restore /path/to/backup.tar.gz
```

**Q: Are backups encrypted?**
A: No. Encrypt sensitive backups manually:
```bash
gpg -c vibe-backup-*.tar.gz
```

### Troubleshooting

**Q: How do I know if something is wrong?**
A: Run health checks:
```bash
./vibe doctor
```

**Q: Where can I find logs?**
A: Check `~/.vibe-palace/logs/` for installation logs.

**Q: Something broke after installation. Now what?**
A:
1. Run `./vibe doctor` to identify issues
2. Check logs in `~/.vibe-palace/logs/`
3. Try `./vibe uninstall <planet>` and reinstall
4. Restore from backup if needed

### Comparison to Alternatives

**Q: How is this different from apt/brew?**
A: Vibe Palace is a meta-installer. It uses apt/brew under the hood but adds:
- Modular installation
- Dependency management
- Configuration management
- Backup/restore
- Health checks

**Q: Should I use this or Dotfiles?**
A: Both! Use Vibe Palace for tool installation, dotfiles for configuration.

**Q: How is this better than the old palace.sh?**
A: Modular, testable, rollback-capable, dependency-aware, and much easier to maintain.

---

## Getting Help

### Still Having Issues?

1. **Check documentation:**
   ```bash
   ls docs/
   cat docs/PLANETS.md
   ```

2. **Run diagnostics:**
   ```bash
   ./vibe doctor
   ./vibe status
   ```

3. **Check logs:**
   ```bash
   ls ~/.vibe-palace/logs/
   cat ~/.vibe-palace/logs/latest.log
   ```

4. **Ask for help:**
   - GitHub Issues: https://github.com/your-username/vibe-palace/issues
   - GitHub Discussions: https://github.com/your-username/vibe-palace/discussions

### Reporting Bugs

When reporting bugs, include:

1. **System information:**
   ```bash
   uname -a
   bash --version
   ./vibe version
   ```

2. **Exact error message:**
   ```bash
   ./vibe install <planet> 2>&1 | tee bug-report.txt
   ```

3. **Steps to reproduce:**
   - What you did
   - What you expected
   - What actually happened

4. **Health check output:**
   ```bash
   ./vibe doctor > health-check.txt
   ```

---

## See Also

- [ARCHITECTURE.md](ARCHITECTURE.md) - System architecture
- [PLANETS.md](PLANETS.md) - Planet descriptions
- [BACKUP_RESTORE.md](BACKUP_RESTORE.md) - Backup guide
- [TESTING.md](TESTING.md) - Testing guide
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guide

---

Need more help? Join the community!
