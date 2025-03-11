# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export FZF_DEFAULT_COMMAND="fd --type f --exclude .git --exclude venv --ignore-file ~/.gitignore . $HOME"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --exclude .git --exclude venv --ignore-file ~/.gitignore . $HOME"

export FZF_CTRL_R_OPTS="
  --preview 'echo {}' --preview-window up:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"

export FZF_ALT_C_OPTS="--preview 'tree -C {}'"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="minimal"

# Jump to the next space
# zle -N jump-to-next-space
# bindkey '^[^[[C' jump-to-next-space
# jump-to-next-space() {
#   LBUFFER=${LBUFFER%%*( )}${LBUFFER#*( )}
# }

# Jump to the previous space
# zle -N jump-to-prev-space
# bindkey '^[^[[D' jump-to-prev-space
# jump-to-prev-space() {
#   LBUFFER=${LBUFFER%%*( )}${LBUFFER%%*( )}${LBUFFER#*( )}
# }


# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
#

plugins=(gitfast copybuffer copyfile copypath zsh-autosuggestions kubectl-autocomplete kubectl helm kube-ps1)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#
# AUTOCOMPLETION
# autoload -U compinit && compinit history setup
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
HISTFILE=$HOME/.zhistory
SAVEHIST=2000
HISTSIZE=999
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_ALL_DUPS
setopt AUTO_CD
setopt AUTOPUSHD
setopt NO_BEEP
# 
# # autocompletion using arrow keys (based on history)
# bindkey '\e[A' history-search-backward
# bindkey '\e[B' history-search-forward
#

# function move-to-next-space() {
#     # Search for the next space from the current cursor position
#     zle .forward-word
#     zle .backward-word
#     zle .forward-char
# }
# zle -N move-to-next-space
# 
# bindkey '^[l' move-to-next-space

alias filepath="readlink -f"
alias srcvenv="source venv/bin/activate"
alias ll="ls -lah"
alias cppath="copypath"
alias cpfile="copyfile"

# autosuggest accept keybinding
bindkey '^ ' autosuggest-accept

# obsidian start
# alias startobsidian="/home/jojop/Applications/Obsidian-1.7.4.AppImage --no-sandbox > /dev/null 2>&1 &"

# pet aliases
alias ppc="pet search | pbcopy -selection c"
alias ppe="pet exec"

# function prev() {
#   PREV=$(fc -lrn | head -n 1)
#   sh -c "pet new `printf %q "$PREV"`"
# }
#
#
#   BUFFER=$(pet search --query "$LBUFFER")
#   CURSOR=$#BUFFER
#   zle redisplay
# }
# zle -N pet-select
# stty -ixon
# bindkey '^s' pet-select

# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source <(fzf --zsh)

export WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# Install Ruby Gems to ~/gems
export GEM_HOME="$HOME/gems"
export PATH="$HOME/gems/bin:$PATH"

# add go PATH
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH:/usr/local/go/bin"
export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/nvim-linux64/bin:/opt/homebrew/bin:$PATH"


# Generated for envman. Do not edit.
# [ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
export PATH=$PATH:$HOME/go/bin
export PYENV_ROOT="$HOME/.pyenv"

[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"
#
# ccloud multitool visual
#
### ZSH examples
# colorful prompt
setopt PROMPT_SUBST
# PS1='$CCLOUD_PROMPT_ESCAPED_ZSH%{%F{118}%}%n@%m%{%f%}:%{%F{039}%}%~%{%f%}%# '
#
PROMPT='%(?.%F{green}√.%F{red}?%?)%f %B%F{240}%1~%f%b %# '
PROMPT='$(kube_ps1)'$PROMPT # or RPROMPT='$(kube_ps1)'
# PROMPT='%{$(u8s prompt)%} '$PROMPT


KUBE_PS1_SEPARATOR=" "
KUBE_PS1_PREFIX=""
KUBE_PS1_SUFFIX=" "
KUBE_PS1_CTX_COLOR="green"
alias osenv="env | grep OS_"

export OS_PW_CMD="security find-generic-password -a $USER -s openstack -w"

function cld {
    exec {fd_ccloud}>>/dev/stdout
    . =(ccloud-multitool --ppid $$ --stdout-fd $fd_ccloud "$@")
    exec {fd_ccloud}>&-
}

source <(cld completion zsh --prog-name cld)

export PATH="/opt/homebrew/opt/mysql/bin:$PATH"


alias k="u8s kubectl --"
alias kn="u8s set --namespace"
alias kc="u8s set --context"
alias kk="u8s set --kubeconfig"

alias h="u8s helm --"
alias h3="u8s helm3 --"


export PATH="/opt/homebrew/opt/openldap/bin:$PATH"
export PATH="/opt/homebrew/opt/openldap/sbin:$PATH"
