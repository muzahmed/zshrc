# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="/Users/muz/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# PATH additions
path+=('/usr/local/bin')
path+=('~/Library/Python/3.8/bin')
path+=('/Users/muz/.ebcli-virtual-env/executables')
export PATH

#export PATH=~/Library/Python/3.8/bin:$PATH

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

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
# See https://github.com/ohmyzsh/ohmyzsh/issues/5765
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"
DISABLE_AUTO_TITLE="true"

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
plugins=(git)

source $ZSH/oh-my-zsh.sh
source ~/src/git-subrepo/.rc

unsetopt inc_append_history
unsetopt share_history

# User configuration

SRC_DIR=~/src
RADAR_DIR=~/src/radar
TIN_DIR=~/src/tin-it

function setTitle() {
     echo -en "\e]0;$1\a"
}

function setColor {
    case $1 in
    green)
    echo -e "\033]6;1;bg;red;brightness;139\a"
    echo -e "\033]6;1;bg;green;brightness;254\a"
    echo -e "\033]6;1;bg;blue;brightness;157\a"
    ;;
    red)
    echo -e "\033]6;1;bg;red;brightness;255\a"
    echo -e "\033]6;1;bg;green;brightness;150\a"
    echo -e "\033]6;1;bg;blue;brightness;145\a"
    ;;
    blue)
    echo -e "\033]6;1;bg;red;brightness;140\a"
    echo -e "\033]6;1;bg;green;brightness;184\a"
    echo -e "\033]6;1;bg;blue;brightness;255\a"
    ;;
    yellow)
    echo -e "\033]6;1;bg;red;brightness;255\a"
    echo -e "\033]6;1;bg;green;brightness;244\a"
    echo -e "\033]6;1;bg;blue;brightness;134\a"
    ;;
    orange)
    echo -e "\033]6;1;bg;red;brightness;255\a"
    echo -e "\033]6;1;bg;green;brightness;210\a"
    echo -e "\033]6;1;bg;blue;brightness;139\a"
    ;;
    purple)
    echo -e "\033]6;1;bg;red;brightness;139\a"
    echo -e "\033]6;1;bg;green;brightness;141\a"
    echo -e "\033]6;1;bg;blue;brightness;254\a"
    ;;
    pink)
    echo -e "\033]6;1;bg;red;brightness;222\a"
    echo -e "\033]6;1;bg;green;brightness;139\a"
    echo -e "\033]6;1;bg;blue;brightness;253\a"
    ;;
    cyan)
    echo -e "\033]6;1;bg;red;brightness;1380\a"
    echo -e "\033]6;1;bg;green;brightness;233\a"
    echo -e "\033]6;1;bg;blue;brightness;253\a"
    ;;
    esac
 }


function ogc {
    open -n -a "Google Chrome" --args --profile-directory="Default" $1;
}

function atype() {
    adb shell input text $1
}

function gitlog() {
    git log -$1  --relative-date --source --decorate --oneline --abbrev-commit --pretty=format:"%C(auto,yellow)%h %C(auto,blue)%<(15)%ad %C(auto,green)%<(50)%ae %C(auto,reset)%<(70,trunc)%s %D"
}

function gitbranchcreate() {
    if [[ "$1" == "" ]] then
        echo -e $fg[red] "no branch name";
    else  
        git checkout -b "muz$1";gitbranchlist;
    fi
}

function gitbranchlist() {
    line_number=0
    current_branch=$(git branch --show-current)
    git for-each-ref --sort=authordate refs/heads/ --format='%(refname:short)%(HEAD)%(HEAD);%(committerdate:relative);%(authorname);%(contents:lines=1)' | column -t -s ';' | sort -k 1 -r | while IFS= read -r line; 
    do
        ((line_number++))
        if [[ "$line" == *"$current_branch"* ]]; then
            echo -e "$line_number: \033[1m\033[31m$line\033[0m"
        elif [[ "$line" == muz* ]]; then
            echo -e "$line_number: \033[32m$line\033[0m"
        else
            echo "$line_number: $line"
        fi
    done
}

function gitaddcommit() {
    if [[ "$VCS_STATUS_LOCAL_BRANCH" == "main" ]] then
        echo -e $fg[red] "on main branch";
    else  
        git add -A
        git commit -m "$1"
    fi
}

function gitcheckout() {
    if [[ $1 ]] then
        aa=(`git for-each-ref --sort=authordate refs/heads/ --format='%(refname:short)' | sort -k 1 -r`)
        git checkout ${aa[$1]};
    else  
        git checkout main;
    fi
}

function gitdeletebranch() {
    if [[ $1 ]] then
        aa=(`git for-each-ref --sort=authordate refs/heads/ --format='%(refname:short)' | sort -k 1 -r`)
        b="${aa[$1]}"
        if [[ "$b" == "main" ]] then
            echo -e $fg[red] "cannot delete main branch";
        else 
            git branch -D $b;gitbranchlist;
        fi        
    else  
         echo -e $fg[red] "branch not specified";
    fi        
}

# Aliases
alias refreshprofile='source ~/.zshrc'
alias editprofile='code ~/.zshrc'
alias src="pushd $SRC_DIR > /dev/null"
alias radar="pushd $RADAR_DIR > /dev/null"
alias tin="pushd $TIN_DIR > /dev/null"

#git
alias gits='git status'
alias gb="gitbranchlist"
alias gco="gitcheckout"
alias gdel="gitdeletebranch"
alias gac="gitaddcommit"
alias gbc='gitbranchcreate'
alias gl='gitlog 30'
alias glme="gl | GREP_COLOR='01;33' egrep --color 'muz.*|$'"
alias glmeonly="git log --author=\"muz\" --relative-date --decorate --oneline --abbrev-commit --pretty=format:\"%C(auto,yellow)%<(8)%h %C(auto,blue)%<(15)%ad %C(auto,reset)%<(100,trunc)%s %D\""

# NVM Setup
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# enable escape to clear prompt
bindkey "^X\x7f" backward-kill-line
# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/muz/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/muz/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/muz/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/muz/google-cloud-sdk/completion.zsh.inc'; fi
