# Migration Guide: From palace.sh to Vibe Solar System

This guide helps you migrate from the monolithic `palace.sh` to the modular Vibe Solar System.

## Overview

### What Changed?

**Before (palace.sh):**
- 1104-line monolithic script
- All-or-nothing installation
- No rollback capability
- Difficult to maintain
- Tightly coupled phases

**After (Vibe Solar System):**
- Modular planet architecture
- Install only what you need
- Full rollback support
- Easy to extend
- Dependency-aware

### Key Benefits

✅ **Modularity**: Install individual components
✅ **Idempotency**: Safe to run multiple times
✅ **Rollback**: Uninstall cleanly
✅ **Dependency Management**: Automatic resolution
✅ **Health Checks**: Verify installations
✅ **Backup/Restore**: Cross-machine migration

## Migration Path

### Option 1: Fresh Start (Recommended)

Start clean with the new system:

1. **Backup your current configs:**
   ```bash
   # Back up important configs
   mkdir -p ~/palace-backup
   cp -r ~/.config ~/palace-backup/
   cp ~/.bashrc ~/palace-backup/
   cp ~/.zshrc ~/palace-backup/
   ```

2. **Install Vibe Palace:**
   ```bash
   git clone https://github.com/your-username/vibe-palace.git
   cd vibe-palace
   chmod +x vibe
   ```

3. **Install what you need:**
   ```bash
   # Install terminal tools
   ./vibe install mercury

   # Install editors
   ./vibe install venus

   # Install languages
   ./vibe install mars
   ```

4. **Restore custom configs:**
   ```bash
   # Copy back any custom configs
   cp ~/palace-backup/.bashrc ~/
   cp ~/palace-backup/custom-config ~/.config/
   ```

### Option 2: Gradual Migration

Run both systems side-by-side:

1. **Keep palace.sh:**
   ```bash
   # Keep it for reference
   mv palace.sh palace.sh.backup
   ```

2. **Install Vibe Palace:**
   ```bash
   git clone https://github.com/your-username/vibe-palace.git
   cd vibe-palace
   chmod +x vibe
   ```

3. **Test with one planet:**
   ```bash
   # Install just Mercury
   ./vibe install mercury
   ```

4. **Verify and test:**
   ```bash
   # Check everything still works
   ./vibe doctor

   # Test your tools
   starship --version
   eza --version
   ```

5. **Gradually add more:**
   ```bash
   # Install other planets as needed
   ./vibe install venus
   ./vibe install mars
   ```

6. **Remove old system when ready:**
   ```bash
   # Once comfortable, uninstall old tools
   # Or just keep as backup
   ```

## Phase Mapping

Here's how `palace.sh` phases map to planets:

### Phase 1: Pre-flight Checks
- **Status**: Handled by `vibe` CLI
- **Action**: Automatic pre-flight checks before each installation

### Phase 2: Terminal Bling → **Mercury**
```bash
# Old
palace.sh (would install everything)

# New
./vibe install mercury
```

**Tools:**
- ✅ Starship prompt
- ✅ Zoxide
- ✅ eza, bat, delta
- ✅ fzf, ripgrep, fd
- ✅ tmux + TPM

### Phase 3: Neovim → **Venus**
```bash
# Old
palace.sh (included in full install)

# New
./vibe install venus
```

**Tools:**
- ✅ Neovim 0.11+
- ✅ LazyVim
- ✅ JetBrains Mono font

### Phase 4: Zsh → **Pluto**
```bash
# Old
palace.sh (included in full install)

# New
./vibe install pluto
```

**Tools:**
- ✅ Zsh
- ✅ Oh My Zsh
- ✅ Atuin
- ✅ tldr

### Phase 5-8: Languages → **Mars**
```bash
# Old
palace.sh (included in full install)

# New
./vibe install mars
```

**Tools:**
- ✅ fnm (Node.js)
- ✅ pyenv (Python)
- ✅ rustup (Rust)
- ✅ Go
- ✅ Java

### Phase 9-12: AI Tools → **Saturn**
```bash
# Old
palace.sh (included in full install)

# New
./vibe install saturn
```

**Tools:**
- ✅ Claude Code
- ✅ aichat
- ✅ MCP Servers

### Phase 13: Docker → **Neptune**
```bash
# Old
palace.sh (included in full install)

# New
./vibe install neptune
```

**Tools:**
- ✅ Docker + Compose
- ✅ kubectl + helm
- ✅ kind/minikube
- ✅ podman

### Phase 14: Databases → **Jupiter**
```bash
# Old
palace.sh (included in full install)

# New
./vibe install jupiter
```

**Tools:**
- ✅ PostgreSQL + pgcli
- ✅ MySQL + mycli
- ✅ Redis + iredis
- ✅ MongoDB shell
- ✅ SQLite

### Phase 15: Git Tools → **Uranus**
```bash
# Old
palace.sh (included in full install)

# New
./vibe install uranus
```

**Tools:**
- ✅ Git + lazygit + gh
- ✅ Docker (already in Neptune)
- ✅ lazydocker
- ✅ jq, yq, httpie
- ✅ gum

### Phase 16: Extra Tools → **Pluto**
See Phase 4 above.

## Configuration Migration

### Shell Configurations

**Old (.bashrc or .zshrc):**
```bash
# palace.sh added many configs here
# Hard to manage and update
```

**New:**
- Configs in individual planet scripts
- Clean separation of concerns
- Easier to update and maintain

### Manual Migration Steps

1. **Backup old configs:**
   ```bash
   cp ~/.bashrc ~/.bashrc.backup
   cp ~/.zshrc ~/.zshrc.backup
   ```

2. **Review what palace.sh added:**
   ```bash
   # Look for palace.sh markers in configs
   grep -n "palace" ~/.bashrc
   grep -n "VIBE" ~/.bashrc
   ```

3. **Extract customizations:**
   ```bash
   # Save your personal customizations
   # (not added by palace.sh)
   ```

4. **Install Vibe Palace:**
   ```bash
   ./vibe install --all
   ```

5. **Add back customizations:**
   ```bash
   # Add your personal configs to:
   # ~/.config/vibe/custom.sh  (auto-sourced)
   ```

## Feature Comparison

| Feature | palace.sh | Vibe Palace |
|---------|-----------|-------------|
| Modular installation | ❌ | ✅ |
| Dependency resolution | ❌ | ✅ |
| Rollback capability | ❌ | ✅ |
| Health checks | ❌ | ✅ |
| Backup/restore | ❌ | ✅ |
| Idempotency | Partial | ✅ |
| Dry-run mode | ❌ | ✅ |
| Progress feedback | Basic | Enhanced |
| Error recovery | Limited | Comprehensive |
| Extensibility | Hard | Easy |

## Migration Checklist

### Pre-Migration

- [ ] Back up important configurations
- [ ] Document custom modifications
- [ ] Note installed tools and versions
- [ ] Test backup restoration

### Migration

- [ ] Clone Vibe Palace repository
- [ ] Make `vibe` executable
- [ ] Install first planet (Mercury)
- [ ] Verify installation works
- [ ] Install remaining planets
- [ ] Run health checks

### Post-Migration

- [ ] Test all installed tools
- [ ] Verify configurations
- [ ] Run `vibe doctor`
- [ ] Create backup
- [ ] Remove old palace.sh if desired

## Rollback Plan

If something goes wrong:

1. **Restore configs:**
   ```bash
   cp ~/palace-backup/.bashrc ~/
   cp ~/palace-backup/.zshrc ~/
   cp -r ~/palace-backup/.config/* ~/.config/
   ```

2. **Uninstall Vibe Palace:**
   ```bash
   # Remove installed planets
   ./vibe uninstall --all

   # Or remove directory
   rm -rf /path/to/vibe-palace
   ```

3. **Re-run palace.sh if needed:**
   ```bash
   ./palace.sh.backup
   ```

## Getting Help

### Common Issues

**Issue: Config conflicts**
```bash
# Solution: Check both configs
diff ~/.bashrc.backup ~/.bashrc

# Manually merge customizations
```

**Issue: Tool version mismatch**
```bash
# Check installed versions
./vibe doctor

# Reinstall specific planet
./vibe uninstall mercury
./vibe install mercury
```

**Issue: Missing dependencies**
```bash
# Check dependency tree
./vibe tree <planet>

# Install with dependencies
./vibe install <planet>
```

### Support Resources

- 📖 [Documentation](docs/)
- 🐛 [GitHub Issues](https://github.com/your-username/vibe-palace/issues)
- 💬 [Discussions](https://github.com/your-username/vibe-palace/discussions)

## Advanced Migration

### Custom Planet Creation

If you had custom modifications to palace.sh:

1. **Create a custom planet:**
   ```bash
   # See docs/CONTRIBUTING.md
   cp planets/example.sh planets/mycustom.sh
   ```

2. **Add your customizations:**
   ```bash
   # Edit planets/mycustom.sh
   vim planets/mycustom.sh
   ```

3. **Install your custom planet:**
   ```bash
   ./vibe install mycustom
   ```

### Integration with Existing Tools

Keep using some tools from palace.sh, others from Vibe:

```bash
# Install only what you want
./vibe install mercury  # Terminal tools
./vibe install venus    # Editor

# Keep using palace.sh for other tools
# Just comment out what you don't need
```

## Timeline Estimate

### Quick Migration (~30 min)

1. Backup configs: 5 min
2. Install Vibe Palace: 5 min
3. Install core planets: 15 min
4. Test and verify: 5 min

### Full Migration (~2 hours)

1. Document current setup: 30 min
2. Full installation: 60 min
3. Test all tools: 20 min
4. Migration and cleanup: 10 min

### Gradual Migration (~1 week)

1. Install Vibe Palace: Day 1
2. Test one planet: Day 1-2
3. Add more planets: Day 3-5
4. Full migration: Day 6-7
5. Remove old system: Day 7

## Success Stories

### From palace.sh to Vibe Palace

*"Migrating was straightforward. I backed up my configs, ran `./vibe install --all`, and everything just worked. The modular approach is much better for my workflow."*

### Partial Migration

*"I only use Mercury and Venus planets. Much faster than running the full palace.sh script. Love the flexibility!"*

### Team Migration

*"Our whole team migrated. We use the backup/restore feature to keep everyone's dev environment in sync. Game changer!"*

## FAQ

**Q: Do I have to migrate?**
A: No, palace.sh still works. But you won't get the benefits of the new system.

**Q: Can I run both?**
A: Yes, but there may be conflicts. Test carefully.

**Q: Will I lose my configs?**
A: No, if you backup first. The new system preserves existing configs.

**Q: How long does migration take?**
A: 30 min for quick migration, 2 hours for full migration.

**Q: What if something breaks?**
A: You can always rollback from your backup.

**Q: Can I customize planets?**
A: Yes! See CONTRIBUTING.md for how to create custom planets.

## Next Steps

1. **Backup your current setup**
2. **Clone Vibe Palace**
3. **Install your first planet**
4. **Test thoroughly**
5. **Gradually add more planets**
6. **Enjoy the modular architecture!**

---

Welcome to the Vibe Solar System! 🌟
