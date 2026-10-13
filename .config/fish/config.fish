# No shell output or starship initialization for scripts/noninteractive sessions.
if status is-interactive
    if type -q starship
        starship init fish | source
    end
end
