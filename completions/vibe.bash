# Bash completion for Vibe Palace

_vibe_completion() {
    local cur prev words cword
    _init_completion || return

    # Main commands
    local commands="install uninstall status doctor list tree graph backup restore help version"

    # Install options
    local install_opts="--all --dry-run --verbose --quiet --yes"

    # Backup options
    local backup_opts="--configs --list --dry-run --verbose --quiet --yes"

    # Global options
    local global_opts="--dry-run --verbose --quiet --yes --help -h --version -V"

    # Planet names
    local planets="mercury venus mars jupiter saturn uranus neptune pluto"

    case "${prev}" in
        install)
            COMPREPLY=($(compgen -W "${install_opts} ${planets}" -- "${cur}"))
            return 0
            ;;
        uninstall)
            COMPREPLY=($(compgen -W "${planets}" -- "${cur}"))
            return 0
            ;;
        tree)
            COMPREPLY=($(compgen -W "${planets}" -- "${cur}"))
            return 0
            ;;
        restore)
            COMPREPLY=($(compgen -f -- "${cur}"))
            return 0
            ;;
        backup)
            COMPREPLY=($(compgen -W "${backup_opts}" -- "${cur}"))
            return 0
            ;;
        *)
            ;;
    esac

    # If we're still here, provide main commands
    if [[ ${cword} -eq 1 ]]; then
        COMPREPLY=($(compgen -W "${commands} ${global_opts}" -- "${cur}"))
        return 0
    fi

    return 0
}

complete -F _vibe_completion vibe
