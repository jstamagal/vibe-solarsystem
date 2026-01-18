# Fish completion for Vibe Palace

complete -c vibe -f

# Main commands
complete -c vibe -n __fish_use_subcommand -a install -d "Install a planet"
complete -c vibe -n __fish_use_subcommand -a uninstall -d "Uninstall a planet"
complete -c vibe -n __fish_use_subcommand -a status -d "Show installation status"
complete -c vibe -n __fish_use_subcommand -a doctor -d "Run health checks"
complete -c vibe -n __fish_use_subcommand -a list -d "List all planets"
complete -c vibe -n __fish_use_subcommand -a tree -d "Show dependency tree"
complete -c vibe -n __fish_use_subcommand -a graph -d "Show dependency graph"
complete -c vibe -n __fish_use_subcommand -a backup -d "Create backup"
complete -c vibe -n __fish_use_subcommand -a restore -d "Restore from backup"
complete -c vibe -n __fish_use_subcommand -a help -d "Show help"
complete -c vibe -n __fish_use_subcommand -a version -d "Show version"

# Global options
complete -c vibe -l dry-run -s n -d "Show what would be done without doing it"
complete -c vibe -l verbose -s v -d "Show detailed output"
complete -c vibe -l quiet -s q -d "Suppress non-error output"
complete -c vibe -l yes -s y -d "Auto-confirm all prompts"

# Install command options
complete -c vibe -n "__fish_seen_subcommand_from install" -l all -d "Install all planets"
complete -c vibe -n "__fish_seen_subcommand_from install" -a mercury venus mars jupiter saturn uranus neptune pluto

# Uninstall command options
complete -c vibe -n "__fish_seen_subcommand_from uninstall" -a mercury venus mars jupiter saturn uranus neptune pluto

# Tree command options
complete -c vibe -n "__fish_seen_subcommand_from tree" -a mercury venus mars jupiter saturn uranus neptune pluto

# Backup command options
complete -c vibe -n "__fish_seen_subcommand_from backup" -l configs -d "Backup only configurations"
complete -c vibe -n "__fish_seen_subcommand_from backup" -l list -d "List available backups"

# Restore command options
complete -c vibe -n "__fish_seen_subcommand_from restore" -r -d "Backup file" -a "(__fish_complete_suffix .tar.gz)"
