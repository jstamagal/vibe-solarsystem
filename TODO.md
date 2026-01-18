# Vibe Solar System TODO - Progressive Agent Tasks

## Agent {{ i+1 }}: Core Library Foundation
**Status**: TODO
**Priority**: CRITICAL
**Dependencies**: None

Create the foundation library that all planets will use:

- [ ] Create `lib/` directory structure
- [ ] Implement `lib/core.sh` with:
  - Color definitions (from palace.sh)
  - Logging functions (log, success, warn, error)
  - Banner function
  - Command existence checker
  - OS detector (Linux/macOS)
- [ ] Implement `lib/state.sh` with:
  - `state_init()` - Initialize state file
  - `state_add()` - Add installed planet
  - `state_remove()` - Remove planet
  - `state_get()` - Get planet info
  - `state_list()` - List all planets
  - State file: `~/.vibe-palace/state.json`
- [ ] Add basic tests for lib functions
- [ ] Document each function with comments

**Deliverable**: Working lib/ directory with core utilities

---

## Agent {{ i+2 }}: Planet Interface Standard
**Status**: TODO
**Priority**: CRITICAL
**Dependencies**: Agent {{ i+1 }} complete

Define the standard interface that all planets must implement:

- [ ] Create `planets/README.md` with planet template
- [ ] Define required functions for each planet:
  - `planet_metadata()` - Name, version, description
  - `planet_dependencies()` - Array of dependency planets
  - `planet_install()` - Main installation logic
  - `planet_uninstall()` - Cleanup logic
  - `planet_check_health()` - Health check
  - `planet_is_installed()` - Idempotency check
- [ ] Create example planet `planets/example.sh`
- [ ] Document best practices for planet authors
- [ ] Add planet validation script

**Deliverable**: Planet interface specification + example

---

## Agent {{ i+3 }}: Orbit Controller CLI (vibe command)
**Status**: TODO
**Priority**: CRITICAL
**Dependencies**: Agent {{ i+1 }}, Agent {{ i+2 }} complete

Build the main `vibe` CLI that orchestrates everything:

- [ ] Create `vibe` main script with:
  - `vibe install <planet>` - Install single planet
  - `vibe install --all` - Install everything
  - `vibe uninstall <planet>` - Remove planet
  - `vibe status` - Show installation state
  - `vibe doctor` - Run health checks
  - `vibe --help` - Usage information
- [ ] Implement dependency resolution in `lib/deps.sh`:
  - Topological sort for install order
  - Circular dependency detection
  - Dependency tree visualization
- [ ] Add dry-run mode with `--dry-run`
- [ ] Add verbose/quiet modes
- [ ] Add confirmation prompts

**Deliverable**: Working `vibe` CLI with basic commands

---

## Agent {{ i+4 }}: Planet Mercury - Terminal Foundation
**Status**: TODO
**Priority**: HIGH
**Dependencies**: Agent {{ i+3 }} complete

Extract terminal tools from palace.sh into Mercury planet:

- [ ] Create `planets/mercury.sh`
- [ ] Port Phase 2 (Terminal Bling) from palace.sh
- [ ] Implement all required planet functions
- [ ] Add health checks for:
  - starship in PATH
  - eza, bat, fzf installed
  - tmux configured
  - .config/starship.toml exists
- [ ] Test `vibe install mercury`
- [ ] Test `vibe uninstall mercury`
- [ ] Test idempotency (run twice)

**Deliverable**: First working planet

---

## Agent {{ i+5 }}: Planet Venus - Editors
**Status**: TODO
**Priority**: HIGH
**Dependencies**: Agent {{ i+4 }} complete

Extract editor setup into Venus planet:

- [ ] Create `planets/venus.sh`
- [ ] Port Phase 3 (Neovim) from palace.sh
- [ ] Implement all required planet functions
- [ ] Add health checks for:
  - nvim in PATH
  - LazyVim installed
  - .config/nvim exists
- [ ] Test `vibe install venus`
- [ ] Test dependency resolution (mercury auto-installs)
- [ ] Test rollback

**Deliverable**: Editor planet with dependency resolution

---

## Agent {{ i+6 }}: Remaining Planets
**Status**: TODO
**Priority**: MEDIUM
**Dependencies**: Agent {{ i+5 }} complete

Port remaining phases into planets:

- [ ] Create `planets/mars.sh` (Phase 5, 6, 7, 8 - Languages)
- [ ] Create `planets/jupiter.sh` (Phase 14 - Databases)
- [ ] Create `planets/saturn.sh` (Phase 9, 10, 11, 12 - AI Tools)
- [ ] Create `planets/uranus.sh` (Phase 15 - Git tools)
- [ ] Create `planets/neptune.sh` (Phase 13 - Docker)
- [ ] Create `planets/pluto.sh` (Phase 16 - Zsh)
- [ ] Test each planet independently
- [ ] Test full `vibe install --all`

**Deliverable**: Complete solar system

---

## Agent {{ i+7 }}: Backup & Restore System
**Status**: TODO
**Priority**: MEDIUM
**Dependencies**: Agent {{ i+6 }} complete

Implement backup/restore functionality:

- [ ] Create `lib/backup.sh`
- [ ] Implement `vibe backup` command:
  - Backup configs
  - Backup state file
  - Create tarball with timestamp
  - Include planet list
- [ ] Implement `vibe restore <file>` command:
  - Validate backup file
  - Restore configs
  - Restore state
  - Verify restoration
- [ ] Add config-only backup option
- [ ] Test cross-machine restore

**Deliverable**: Working backup/restore system

---

## Agent {{ i+8 }}: Testing & Quality Assurance
**Status**: TODO
**Priority**: HIGH
**Dependencies**: Agent {{ i+7 }} complete

Add comprehensive testing:

- [ ] Create `tests/` directory
- [ ] Implement `tests/test_lib.sh`:
  - Test all lib functions
  - Mock filesystem operations
  - Test error handling
- [ ] Implement `tests/test_planets.sh`:
  - Test each planet's functions
  - Test dependency resolution
  - Test rollback
- [ ] Implement `tests/integration.sh`:
  - Full install/uninstall cycle
  - Multi-planet scenarios
  - Error recovery
- [ ] Add CI/CD pipeline (GitHub Actions)
- [ ] Achieve 80%+ code coverage

**Deliverable**: Comprehensive test suite

---

## Agent {{ i+9 }}: Documentation & Polish
**Status**: TODO
**Priority**: MEDIUM
**Dependencies**: Agent {{ i+8 }} complete

Make it production-ready:

- [ ] Create `docs/ARCHITECTURE.md`:
  - System design
  - Component interaction
  - Data flow diagrams
- [ ] Create `docs/PLANETS.md`:
  - Detailed description of each planet
  - Dependencies graph
  - Installation times
- [ ] Create `docs/CONTRIBUTING.md`:
  - How to add a planet
  - Code style guidelines
  - PR process
- [ ] Update `README.md`:
  - Quick start guide
  - Installation instructions
  - Features overview
  - Screenshots
- [ ] Add man page for `vibe` command
- [ ] Create migration guide from palace.sh

**Deliverable**: Professional documentation

---

## Agent {{ i+10 }}: Advanced Features (Optional)
**Status**: TODO
**Priority**: LOW
**Dependencies**: Agent {{ i+9 }} complete

Nice-to-have features:

- [ ] Implement user config file (`~/.vibe-palace/config.toml`)
- [ ] Add progress bars for installations
- [ ] Implement plugin system for custom planets
- [ ] Add planet registry/manifest
- [ ] Create planet sharing/packaging format
- [ ] Add telemetry (opt-in)
- [ ] Create website for planet discovery
- [ ] Add auto-update notification

**Deliverable**: Feature-complete system

---

## Phase Completion Checklist

When vibe solar system is complete:

- [ ] All 8 planets implemented and tested
- [ ] Full `vibe install --all` works
- [ ] Each planet installs independently
- [ ] Dependency resolution working
- [ ] Rollback working for all planets
- [ ] Health checks passing
- [ ] Backup/restore working
- [ ] Test suite passing
- [ ] Documentation complete
- [ ] Migration from palace.sh tested
- [ ] DELETE CIRCUIT_BREAKER.txt 🎉

---

## Current Status

**Active Agent**: {{ i }}
**Current Task**: Creating PRD and TODO
**Next Task**: Agent {{ i+1 }} - Core Library Foundation
**Progress**: {{ (i-1)/10 * 100 }}% complete

## Notes

- Each agent should commit their work with clear messages
- Use branches: `agent{i}-{brief-description}`
- Test thoroughly before marking complete
- Update TODO.md as you complete tasks
- If stuck, ask for help but try to solve first
- Keep code clean and well-commented
- This machine SHITS EXCELLENCE
