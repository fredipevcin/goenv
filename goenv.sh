goenv() {
    local progName=$0
    local GOENV_DIR=.goenv
    goenv__help() {
        cat <<-EOF
Usage: ${progName} [COMMAND]

Commands:
    activate     Activates goenv
    init         Set project package for the first time
    deactivate   Deactivates goenv
EOF
    }

    goenv_init() {
        if [ ! -d "${GOENV_DIR}" ]; then
            mkdir -p "${GOENV_DIR}"

            echo "GOENV_PROJECT_PACKAGE="'"'"${1:-}"'"' > "${GOENV_DIR}/goenv"
            return 0
        fi

        echo "${GOENV_DIR} already exists" >&2
        return 1
    }

    goenv_deactivate() {
        # reset old environment variables
        # ! [ -z ${VAR+_} ] returns true if VAR is declared at all
        if ! [ -z "${_OLD_VIRTUAL_PATH+_}" ] ; then
            PATH="$_OLD_VIRTUAL_PATH"
            export PATH
            unset _OLD_VIRTUAL_PATH
        fi
        if ! [ -z "${_OLD_VIRTUAL_GOPATH+_}" ] ; then
            GOPATH="$_OLD_VIRTUAL_GOPATH"
            export GOPATH
            unset _OLD_VIRTUAL_GOPATH
        fi

        # This should detect bash and zsh, which have a hash command that must
        # be called to get it to forget past commands.  Without forgetting
        # past commands the $PATH changes we made may not be respected
        if [ -n "${BASH-}" ] || [ -n "${ZSH_VERSION-}" ] ; then
            hash -r 2>/dev/null
        fi

        if ! [ -z "${_OLD_VIRTUAL_PS1+_}" ] ; then
            PS1="$_OLD_VIRTUAL_PS1"
            export PS1
            unset _OLD_VIRTUAL_PS1
        fi

        if [ ! "${1-}" = "nondestructive" ] ; then
            # Self destruct!
            unset -f goenv_deactivate
        fi
    }

    goenv_activate() {
        if [ ! -f "${GOENV_DIR}/goenv" ]; then
            echo "${GOENV_DIR} not found. Run '${progName} init'" >&2
            return 1
        fi


        goenv_deactivate nondestructive

        _OLD_VIRTUAL_GOPATH="$GOPATH"
        GOPATH="$(pwd)/${GOENV_DIR}"
        export GOPATH

        _OLD_VIRTUAL_PATH="$PATH"
        PATH="$GOPATH/bin:$PATH"
        export PATH

        source "${GOPATH}/goenv"

        if [ -z "${GOENV_DISABLE_PROMPT-}" ] ; then
            _OLD_VIRTUAL_PS1="$PS1"
            PS1="(goenv: ${GOENV_PROJECT_PACKAGE:-"not set"} '$GOPATH') $PS1"
            export PS1
        fi

        if [ -n "${GOENV_PROJECT_PACKAGE:-}" ]; then
            mkdir -p "${GOPATH}/src/$(dirname "${GOENV_PROJECT_PACKAGE}")"
            test -L "${GOPATH}/src/${GOENV_PROJECT_PACKAGE}" || ln -s "$(pwd)" "${GOPATH}/src/${GOENV_PROJECT_PACKAGE}"
        fi

        # This should detect bash and zsh, which have a hash command that must
        # be called to get it to forget past commands.  Without forgetting
        # past commands the $PATH changes we made may not be respected
        if [ -n "${BASH-}" ] || [ -n "${ZSH_VERSION-}" ] ; then
            hash -r 2>/dev/null
        fi
    }

    local subcommand=${1:-}
    case $subcommand in
        "" | "-h" | "--help")
            goenv__help
            ;;
        *)
            shift
            type goenv_${subcommand} > /dev/null
            if [ $? = 1 ]; then
                echo "Error: '$subcommand' is not a known subcommand." >&2
                echo "     Run '${progName} --help' for a list of known subcommands." >&2
                return 1
            fi

            goenv_${subcommand} $@
            return $?
            ;;
    esac

    unset -f goenv__help goenv_init goenv_activate goenv_deactivate
}
