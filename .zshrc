# Load NVM early (Antigravity MCP needs npx here)
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"
POWERLEVEL10K_MODE="nerdfont-complete"

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
plugins=(
	git
	fzf-tab
	dnf
	zsh-autosuggestions
	zsh-syntax-highlighting
	rust
	npm	
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

enable-fzf-tab

# INDRA Added start

alias bat='batcat'

bindkey -e
bindkey '^f' autosuggest-accept
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

alias edit='gnome-text-editor'
alias view='vim $(fzf --preview="cat {}")'

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no

zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --icons=always --color=always $realpath'

zstyle ':fzf-tab:complete:ls:*' fzf-preview '
    if [[ -f $realpath ]]; then
        case $realpath in
            *.py|*.txt|*.cpp|*.toml|*.yml|*.yaml|*.html|*.json|*.md|*.bat)
                bat --color=always $realpath 2>/dev/null || cat $realpath
                ;;
            *)
                eza -1 --icons=always --color=always $realpath
                ;;
        esac
    else
        eza -1 --icons=always --color=always $realpath
    fi'

export FZF_DEFAULT_OPTS="
  --height 90%
  --layout reverse
  --border rounded
  --info inline"

# fzf Ctrl+R history with preview
export FZF_CTRL_R_OPTS="
  --preview 'echo {}'
  --preview-window 'down:3:wrap'"

# Alt+C directory jump with tree preview  
export FZF_CTRL_T_OPTS="
  --preview 'batcat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || eza --icons=always --color=always {}'
  --preview-window 'right:60%:wrap:border-left'
  --bind 'ctrl-/:change-preview-window(down:70%|hidden|right:60%)'"

# INDRA Added End

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/ihackerubuntu/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/ihackerubuntu/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/home/ihackerubuntu/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/ihackerubuntu/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


# eza
alias ls='eza --icons=auto'
alias ll='eza -lah --icons=auto'
alias la='eza -a --icons=auto'
alias tree='eza --tree --icons=auto'

# zoxide
eval "$(zoxide init zsh --cmd cd)"

# Yaki file manager
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	command rm -f -- "$tmp"
}

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH=$BUN_INSTALL/bin:$PATH
. "$HOME/.cargo/env"

export MODULAR_HOME="/home/ihackerubuntu/.modular"
export PATH="/home/ihackerubuntu/.modular/pkg/packages.modular.com_max/bin:$PATH"

source /opt/ros/jazzy/setup.zsh
export GZ_SIM_RESOURCE_PATH=/home/ihackerubuntu/Documents/GazeboSim_Fuels


export PATH="$PATH"

export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp

export CPATH=$CPATH:/home/ihackerubuntu/cuda-samples/Common

# Aria setup
export ARIA_DIR=/usr/local/Aria
export PATH=$PATH:$ARIA_DIR/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ARIA_DIR/lib


# export PATH=$ANDROID_HOME/bin:$PATH
# export ANDROID_HOME=/usr/local/android-studio
export ANDROID_HOME=/home/ihackerubuntu/Android/Sdk
export PATH=$ANDROID_HOME/bin:$PATH
export NDK_HOME="$ANDROID_HOME/ndk/$(ls -1 $ANDROID_HOME/ndk | sort -V | tail -n1)"
export JAVA_HOME=/home/ihackerubuntu/.local/share/JetBrains/Toolbox/apps/android-studio/jbr
#export ANDROID_STUDIO_HOME=/home/ihackerubuntu/.local/share/JetBrains/Toolbox/apps/android-studio
#export $ANDROID_STUDIO_PATH=/home/ihackerubuntu/.local/share/JetBrains/Toolbox/apps/android-studio
#export PATH="$ANDROID_STUDIO_HOME/bin:$PATH"

export PATH="${HOME}/.fvm/bin:${HOME}/.fluvio/bin:${PATH}"

. "$HOME/.local/bin/env"

source $HOME/.local/bin/env # For UV Python package manager

# bun completions
[ -s "/home/ihackerubuntu/.bun/_bun" ] && source "/home/ihackerubuntu/.bun/_bun"

export GITHUB_PERSONAL_ACCESS_TOKEN=

# NODE, NPX, load add top of this


# opencode
export PATH=/home/ihackerubuntu/.opencode/bin:$PATH

# Add these lines to the file:
# export OPENROUTER_API_KEY=""
# export ANTHROPIC_BASE_URL="https://openrouter.ai/api"
# export ANTHROPIC_AUTH_TOKEN="$OPENROUTER_API_KEY"
# export ANTHROPIC_API_KEY="" # Important: Must be explicitly empty
# export ANTHROPIC_MODEL="openrouter/free"

# export ANTHROPIC_BASE_URL="http://localhost:4000"
# export ANTHROPIC_API_KEY="anything"
# export ANTHROPIC_MODEL="qwen2.5-coder:1.5b"
# export ANTHROPIC_AUTH_TOKEN="dummy"
# export ANTHROPIC_API_KEY="dummy"
# export CLAUDE_SKIP_AUTH=1
# export ANTHROPIC_DISABLE_THINKING=1
# export DISABLE_ANTHROPIC_THINKING=true

# export ANTHROPIC_MODEL="qwen3.5:0.8b"
# export ANTHROPIC_BASE_URL="http://localhost:4000"
# export ANTHROPIC_API_KEY="dummy"

# This is for see free claude code to claude code
export ANTHROPIC_BASE_URL="http://localhost:8082"
export ANTHROPIC_AUTH_TOKEN="freecc"
export CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY="1"
export CLAUDE_CODE_AUTO_COMPACT_WINDOW="190000"

# Added by Antigravity CLI installer
export PATH="/home/ihackerubuntu/.local/bin:$PATH"
