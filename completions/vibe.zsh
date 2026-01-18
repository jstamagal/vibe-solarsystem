# Zsh completion for Vibe Palace

_vibe() {
    local -a commands
    commands=(
        'install:Install a planet or all planets'
        'uninstall:Uninstall a planet'
        'status:Show installation status'
        'doctor:Run health checks'
        'list:List all available planets'
        'tree:Show dependency tree for a planet'
        'graph:Show dependency graph'
        'backup:Create backup'
        'restore:Restore from backup'
        'help:Show help message'
        'version:Show version information'
    )

    local -a planets
    planets=(
        'mercury:Terminal Foundation'
        'venus:Editors & IDEs'
        'mars:Programming Languages'
        'jupiter:Databases'
        'saturn:AI Development'
        'uranus:Dev Tools'
        'neptune:Containers'
        'pluto:Bonus Tools'
    )

    local -a global_options
    global_options=(
        '--dry-run[Show what would be done without doing it]'
        '--verbose[Show detailed output]'
        '--quiet[Suppress non-error output]'
        '--yes[Auto-confirm all prompts]'
        '--help[Show help message]'
        '--version[Show version]'
    )

    local -a install_options
    install_options=(
        '--all[Install all planets]'
        '--dry-run[Show what would be done]'
        '--verbose[Detailed output]'
        '--quiet[Suppress output]'
        '--yes[Auto-confirm]'
    )

    local -a backup_options
    backup_options=(
        '--configs[Backup only configurations]'
        '--list[List available backups]'
        '--dry-run[Show what would be done]'
    )

    local context state state_descr line
    typeset -A opt_args

    _arguments -C \
        "${global_options[@]}" \
        '1: :->command' \
        '*: :->args'

    case $state[1] in
        command)
            _describe 'command' commands
            ;;
        args)
            case $words[2] in
                install)
                    if [[ $words[CURRENT] == --* ]]; then
                        _describe 'option' install_options
                    else
                        _describe 'planet' planets
                        _values 'option' '--all'
                    fi
                    ;;
                uninstall|tree)
                    _describe 'planet' planets
                    ;;
                backup)
                    if [[ $words[CURRENT] == --* ]]; then
                        _describe 'option' backup_options
                    else
                        _describe 'option' backup_options
                    fi
                    ;;
                restore)
                    _files -g '*.tar.gz'
                    ;;
                *)
                    ;;
            esac
            ;;
    esac
}

_vibe "$@"
