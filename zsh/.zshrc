# Early exports and Oh-My-Zsh setup
export SHELL=/bin/zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="minimal"
HYPHEN_INSENSITIVE="true"
# Load plugins FIRST
plugins=(zsh-vi-mode copybuffer copyfile copypath zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh

# PATH exports
export GEM_HOME="$HOME/gems"
export PATH="$HOME/gems/bin:$PATH"
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH:/usr/local/go/bin"
export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/nvim-linux64/bin:/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/opt/mysql/bin:$PATH"
export PATH="/opt/homebrew/opt/openldap/bin:$PATH"
export PATH="/opt/homebrew/opt/openldap/sbin:$PATH"
export PATH=$PATH:$HOME/go/bin
export PATH="$PATH:/Users/I761196/.lmstudio/bin"

# Shell options
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_ALL_DUPS
setopt AUTO_CD
setopt AUTOPUSHD
setopt NO_BEEP
HISTFILE=$HOME/.zhistory
SAVEHIST=30000
HISTSIZE=30000

# Editor setup
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# aichat integration for Zsh line editor (define function but don't bind yet)
_aichat_zsh() {
    if [[ -n "$BUFFER" ]]; then
        local _old=$BUFFER
        BUFFER+="⌛"
        zle -I && zle redisplay
        BUFFER=$(command aichat -r '%shell%' "$_old")
        zle end-of-line
    fi
}
zle -N _aichat_zsh

# aichat with command evaluation function
_aichat_eval_zsh() {
    if [[ -n "$BUFFER" ]]; then
        # Check if buffer contains %%
        if [[ "$BUFFER" == *%%* ]]; then
            local command_part="${BUFFER%%\%\%*}"  # Everything before %%
            local prompt_part="${BUFFER#*\%\%}"    # Everything after %%
            
            # Remove leading/trailing whitespace from both parts
            command_part="${command_part## }"
            command_part="${command_part%% }"
            prompt_part="${prompt_part## }"
            prompt_part="${prompt_part%% }"
            
            # Show progress indicator temporarily
            local _old_buffer=$BUFFER
            BUFFER+="⌛"
            zle -I && zle redisplay
            
            # Restore original buffer
            BUFFER=$_old_buffer
            zle -I && zle redisplay
            
            # Print a separator line
            echo "\n--- AI Response ---"
            
            # Evaluate the command part and execute aichat
            local command_result
            if command_result=$(eval "$command_part" 2>&1); then
                # Execute aichat with the result and prompt, output to stdout
                command aichat "$command_result" "$prompt_part"
            else
                # If command fails, show error
                echo "Error executing command: $command_part"
                command aichat "$command_result" "$prompt_part"
            fi
            
            # Print separator line
            echo "--- End AI Response ---"
            
        else
            # If no %% found, show error message
            echo "Error: No %% delimiter found. Usage: command %% prompt"
        fi
        
        # Reset prompt to show buffer is ready for next command
        zle reset-prompt
    fi
}
zle -N _aichat_eval_zsh

# FzF Settings
export FZF_DEFAULT_COMMAND="fd --type f --exclude .git --exclude .venv --ignore-file ~/.gitignore . ."
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --exclude .git --exclude venv --ignore-file ~/.gitignore . $HOME"
export FZF_CTRL_R_OPTS="
  --height '50%'
  --preview 'echo {}' --preview-window up:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"
export FZF_ALT_C_OPTS="--preview 'tree -C {}'"

# Source fzf
source <(fzf --zsh)

# Functions
function user_display {
  [[ $USER == "I761196" ]] && echo "me" || echo $USER
}

function cld {
    exec {fd_ccloud}>>/dev/stdout
    . =(ccloud-multitool --ppid $$ --stdout-fd $fd_ccloud "$@")
    exec {fd_ccloud}>&-
    tmux setenv -g KUBECONFIG "${KUBECONFIG}"
}

_fzf_complete_path_segment() {
  local basepath word fzf_result
  word=${(z)LBUFFER}
  basepath="${word##* }"
  if [[ "$basepath" != */ ]]; then
    basepath="${basepath%/*}/"
  fi
  if [[ -d "$basepath" ]]; then
    fzf_result=$(command ls -1a "$basepath" 2>/dev/null | fzf)
    if [[ -n "$fzf_result" ]]; then
      LBUFFER+="$fzf_result/"
    fi
  else
    echo "Not a valid path: $basepath" >&2
  fi
  zle reset-prompt
}
zle -N _fzf_complete_path_segment

# Define your shortcuts/aliases with descriptions
declare -A shortcuts
shortcuts=(
    "CTRL + U"              "autosuggest-accept"
    "CTRL + N"              "forward-word"
    "CTRL + V"              "fzf path completion"
    "CTRL + H"              "show this shortcuts menu"
    "ALT  + E"              "aichat to create commands"
    "ALT  + D"              "aichat command evaluation, use 'command %% prompt'"
    "CTRL + R"              "fzf history search"
    "filepath"              "readlink -f"
    "cppath"                "copy current file path to clipboard"
    "cpfile"                "copy current file to clipboard"
    "rgi"                   "ripgrep with ignore and color"

)

# Function to show shortcuts
function show_shortcuts() {
    local selected
    # Create a formatted list
    local -a items=()
    for shortcut desc in ${(kv)shortcuts}; do
        items+=("$shortcut|$desc")
    done
    
    # Use fzf if available, otherwise use simple select
    if command -v fzf >/dev/null 2>&1; then
        selected=$(printf '%s\n' "${items[@]}" | \
                  column -t -s '|' | \
                  fzf --prompt="Shortcuts > " \
                      --height=40% \
                      --border \
                      --preview-window=hidden)
        
        if [[ -n "$selected" ]]; then
            # Extract the command and execute it
            local cmd=$(echo "$selected" | awk '{print $1}' | cut -d'=' -f2 | tr -d "'\"")
            print -z "$cmd"  # Put command in command line buffer
        fi
    else
        # Fallback to simple display
        echo "\n📋 Available Shortcuts:"
        printf '%s\n' "${items[@]}" | column -t -s '|' | nl
    fi
}

# Bind to Ctrl+H (you can change this)
zle -N show_shortcuts

# zsh-vi-mode setup - runs after the plugin is loaded
function zvm_after_init() {
  # Custom key bindings after zsh-vi-mode loads
  bindkey -r '^U'
  bindkey '^U' autosuggest-accept
  bindkey '^n' forward-word
  bindkey '^v' _fzf_complete_path_segment
  # IMPORTANT: Add the aichat keybinding here
  bindkey '\ee' _aichat_zsh
  bindkey '\ed' _aichat_eval_zsh
  bindkey '^H' show_shortcuts
}

# Autosuggestions config
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=(forward-word)

# Other environment variables
export OS_PW_CMD="security find-generic-password -a $USER -s openstack -w"
export VAULT_ADDR=https://vault.global.cloud.sap/

# Aliases
alias filepath="readlink -f"
alias srcvenv="source .venv/bin/activate"
alias ll="ls -lah"
alias cppath="copypath"
alias cpfile="copyfile"
alias h="u8s helm --"
alias h3="u8s helm3 --"
alias osenv="env | grep OS_"
alias rgi='rg -i --hidden --color=always'
alias k8s="nvim -c 'lua require(\"kubectl\").toggle({tab=true})'"
alias grep='grep --color=auto'

# Completions and final setup
source <(cld completion zsh --prog-name cld)
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"
eval "$(starship init zsh)"

# Tmux-specific environment setup
if [[ -n "$TMUX" ]]; then
    # Ensure we're in the right directory when creating new panes
    if [[ -z "$TMUX_PANE_START_PATH" ]]; then
        export TMUX_PANE_START_PATH="$PWD"
    fi
fi
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"


# Also create an alias for manual access
alias shortcuts='show_shortcuts'
alias auth_clavis_dev='kubernikusctl auth init --username I761196 --user-domain-name monsoon3 --project-id a2f358d6ba924c6c80996c7525ba359f --auth-url https://identity-3.eu-de-1.cloud.sap/v3 --url https://kubernikus.eu-de-1.cloud.sap --name clavis-dev  '

# pnpm
export PNPM_HOME="/Users/I761196/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Added by Antigravity
export PATH="/Users/I761196/.antigravity/antigravity/bin:$PATH"

#eval "$(zoxide init zsh)"
