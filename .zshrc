# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="/Users/muzahmed/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# PATH additions
export PATH="/usr/local/opt/ruby/bin:$PATH"
export PATH=$HOME/.gem/bin:$PATH
export PATH="/Users/muzahmed/src/flutter/bin:$PATH"
export PATH="/usr/local/bin:$PATH"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"
DISABLE_AUTO_TITLE="true"

# PLUGINS
plugins=(git)

source $ZSH/oh-my-zsh.sh

unsetopt inc_append_history
unsetopt share_history

alias refreshprofile='source ~/.zshrc'
alias editprofile='code ~/.zshrc'

# NAVIGATION
SRC_DIR=~/src
RADAR_DIR=~/src/radar
TIN_DIR=~/src/tin
K9_DIR=~/src/k9stays

alias src="pushd $SRC_DIR > /dev/null"
alias radar="pushd $RADAR_DIR > /dev/null"
alias k9="pushd $K9_DIR > /dev/null"
alias tin="pushd $TIN_DIR > /dev/null"

function ogc {
    open -n -a "Google Chrome" --args --profile-directory="Default" $1;
}

function ogh {
    git config --get remote.origin.url | xargs open
}

## FORMATTING ##
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

infoMsg() {
    echo -e "\e[32m$*\e[0m"
}

warnMsg() {
    echo -e "\e[33m$*\e[0m"
}

errorMsg() {
    echo -e "\e[31m$*\e[0m"
}

## GIT ##
function getDefaultBranch() {
  default_branch=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's@^origin/@@')
  if [ -z "$default_branch" ]; then
      default_branch=$(git remote show origin 2>/dev/null | awk '/HEAD branch/ {print $NF}')
  fi
  if [ -z "$default_branch" ]; then
      default_branch=$(git rev-parse --abbrev-ref HEAD)
  fi
  echo $default_branch
}

function gitlog() {
  local count=${1:-20}

  # Auto-detect GitHub repo URL
  local raw_url
  raw_url=$(git config --get remote.origin.url 2>/dev/null)
  local repo_url=""

  if [[ "$raw_url" == git@github.com:* ]]; then
    repo_url="https://github.com/$(echo "$raw_url" | sed -E 's#git@github.com:##; s/\.git$//')"
  elif [[ "$raw_url" == https://github.com/* ]]; then
    repo_url=$(echo "$raw_url" | sed -E 's/\.git$//')
  fi

  git log -${count} --relative-date --pretty=format:'%h%x09%ad%x09%ae%x09%s' |
  awk -v repoUrl="$repo_url" -F'\t' '
    function strip_ansi(str) {
      gsub(/\033\[[0-9;]*m/, "", str)
      return str
    }

    function pad(str, width) {
      real_len = length(strip_ansi(str))
      pad_len = width - real_len
      if (pad_len > 0) return str sprintf("%" pad_len "s", "")
      return str
    }

    BEGIN {
      wrap_width = 60
      print "\033[1m" pad("HASH", 10) " | " pad("WHEN", 15) " | " pad("OWNER", 25) " | MESSAGE\033[0m"
      print "----------------------------------------------------------------------------------------------------------------------------"
    }

    {
      raw_hash = $1
      raw_when = $2
      email = $3
      msg = $4
      for (i = 5; i <= NF; i++) {
        msg = msg " " $i
      }

      is_muz = (email == "muz.ahmed@gmail.com" || email == "muz@shopwithtin.com")

      # Yellow for Muz
      hash = is_muz ? "\033[1;33m" pad(raw_hash, 10) "\033[0m" : pad(raw_hash, 10)
      when = is_muz ? "\033[1;33m" pad(raw_when, 15) "\033[0m" : pad(raw_when, 15)

      owner = is_muz ? "\033[1;31mMuz\033[0m" : email

      if (is_muz && msg ~ /Merge (pull request|branch)/) {
        split(msg, parts, " ")
        for (i = 1; i < length(parts); i++) {
          if (parts[i] == "from" || parts[i] == "branch") {
            branch = parts[i+1]
            sub(".*/", "", branch)
            owner = owner " \033[0;32m| " branch "\033[0m"
            break
          }
        }
      }

      owner = pad(owner, 25)

      pr_num = ""
      p = index(msg, "#")
      if (p > 0) {
        num = substr(msg, p + 1)
        if (num ~ /^[0-9]+/) {
          match(num, /^[0-9]+/)
          pr_num = substr(num, RSTART, RLENGTH)
        }
      }

      pr_links = ""
      if (repoUrl != "" && pr_num != "") {
        pr_base = repoUrl "/pull/" pr_num
        pr_links = "\033[34m" pr_base "\033[0m"
      }

      if (pr_links != "")
        msg = pr_links "  " msg

      cmd = "echo \"" msg "\" | fold -s -w " wrap_width
      while ((cmd | getline line) > 0) {
        lines[++n] = line
      }
      close(cmd)

      for (i = 1; i <= n; i++) {
        if (i == 1)
          printf "%s | %s | %s | %s\n", hash, when, owner, lines[i]
        else
          printf "%s | %s | %s | %s\n", pad("", 10), pad("", 15), pad("", 25), lines[i]
      }

      print "----------------------------------------------------------------------------------------------------------------------------"

      delete lines
      n = 0
    }
  '
}


function gitbranchcreate() {
    if [[ "$1" == "" ]] then
        errorMsg "no branch name"
    else
        git checkout -b "muz_$1";gitbranchlist;
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
    local force=false
    local msg=""

    # parse args
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -f|--force)
                force=true
                shift
                ;;
            *)
                msg="$1"
                shift
                ;;
        esac
    done

    local default_branch=$(getDefaultBranch)
    local current_branch="${VCS_STATUS_LOCAL_BRANCH:-$(git rev-parse --abbrev-ref HEAD)}"

    if [[ "$current_branch" == "$default_branch" && "$force" != true ]]; then
        errorMsg "on default branch ($default_branch). Use -f to override."
    else
        git add -A
        git commit -m "$msg"
    fi
}

function gitcheckout() {
    if [[ $1 ]]; then
        aa=($(git for-each-ref --sort=authordate refs/heads/ --format='%(refname:short)' | sort -k 1 -r))
        git checkout "${aa[$1]}"
    else
        default_branch=$(getDefaultBranch)
        git checkout "$default_branch"
    fi
}

function gitdeletebranch() {
    if [[ $1 ]]; then
        aa=($(git for-each-ref --sort=authordate refs/heads/ --format='%(refname:short)' | sort -k 1 -r))
        b="${aa[$1]}"
        default_branch=$(getDefaultBranch)
        if [[ "$b" == "$default_branch" ]]; then
            errorMsg "cannot delete default branch ($default_branch)"
        else
            git branch -D "$b"
            gitbranchlist
        fi
    else
        errorMsg "branch not specified"
    fi
}

function revertfile() {
    if [[ $1 ]]; then
        default_branch=$(getDefaultBranch)
        git checkout "$default_branch" -- "$1"
    else
        errorMsg "file not specified"
    fi
}

alias gits='git status'
alias gb="gitbranchlist"
alias gco="gitcheckout"
alias gdel="gitdeletebranch"
alias gac="gitaddcommit"
alias gbc='gitbranchcreate'
alias gl='gitlog 30'
alias glme="gl | GREP_COLOR='01;33' egrep --color 'muz.*|$'"
alias glmeonly="git log --author=\"muz\" --relative-date --decorate --oneline --abbrev-commit --pretty=format:\"%C(auto,yellow)%<(8)%h %C(auto,blue)%<(15)%ad %C(auto,reset)%<(100,trunc)%s %D\""

# AWS
selectAWS() {
  local profiles=()
  local profile_list=$(aws configure list-profiles)

  # Build array, omitting 'default'
  for prof in ${(f)profile_list}; do
    [[ "$prof" == "default" ]] && continue
    profiles+=("$prof")
  done

  if [[ ${#profiles[@]} -eq 0 ]]; then
    echo "No profiles found (excluding 'default')"
    return 1
  fi

  echo "Select an AWS profile:"
  for i in {1..${#profiles[@]}}; do
    echo "$i. ${profiles[$i]}"
  done

  echo -n "select profile index: "
  read -r index

  if [[ "$index" =~ '^[0-9]+$' ]] && (( index >= 1 && index <= ${#profiles[@]} )); then
    export AWS_PROFILE="${profiles[$index]}"
    infoMsg "AWS_PROFILE set to '${profiles[$index]}'"
  else
    errorMsg "Invalid selection"
    return 1
  fi
}

whichAWS() {
  if [[ -z "$AWS_PROFILE" ]]; then
    warnMsg "AWS_PROFILE is not set"
    return 1
  fi

  infoMsg "AWS_PROFILE is: $AWS_PROFILE"
  echo "pulling "
  
  if command -v aws >/dev/null 2>&1; then
    aws sts get-caller-identity --output table --no-cli-pager
  else
    errorMsg "AWS CLI not found"
  fi
}

# NPM/NVM
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

autoload -U +X compinit && compinit
autoload -U +X bashcompinit && bashcompinit

eval "$(npm completion)"


# TIN
function resim() {
  local simId=$1
  
  echo "resim $simId"
  # Run the xcrun simctl list command and capture the output
  output=$(xcrun simctl list)
  booted_device_id=$(echo "$output" | grep "(Booted)" | grep -Eo "[0-9A-F\-]{36}")
  
   # Check if a booted device was found
    if [ -z "$booted_device_id" ]; then
        if [ -n "$simId" ]; then
            booted_device_id="$simId"
            echo "No booted device found. Using provided simId: $booted_device_id"
        else
            echo "No device found, running xcrun simctl list"
            xcrun simctl list
            return
        fi
    fi
  
  echo "device to boot: $booted_device_id"

  killall "Simulator" 2> /dev/null; xcrun simctl erase all;  
  xcrun simctl boot $booted_device_id;
  open -a Simulator.app;
  osascript -e 'do shell script "afplay /System/Library/Sounds/Submarine.aiff"';
}

function deployEnsemble() {
  cd /Users/muzahmed/src/tin/ensemble;
  flutter run --dart-define=TIN_ENV=dev --flavor dev;
  popd;
}

export TIN_DENALI_ROOT_DIR=/Users/muzahmed/src/tin/tin_monorepo/denali
export TIN_ENSEMBLE_ROOT_DIR=/Users/muzahmed/src/tin/ensemble

# Google Cloud SDK.
if [ -f '/Users/muzahmed/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/muzahmed/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/Users/muzahmed/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/muzahmed/google-cloud-sdk/completion.zsh.inc'; fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
