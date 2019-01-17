#!/bin/bash



_valid_cmd=('pull' 'merge', 'push')


# @todo : check encoding for every committed file
# Display Warn message + ask confirm before commit

# @todo Error management
# @todo use function read commit multi line?
# @todo check if current version is uptodate :: option in config file
# @todo check if any log message

#todo display changes to be committed

# @niceToHave : check for codingStandard 


# INFO :
# ---------------
# File encoding
#US-ASCII -- is -- a subset of UTF-8 (see Ned's answer below)
#Meaning that US-ASCII files are actually encoded in UTF-8




function confirm(){
    # call with a prompt string or use a default
    read -r -p "${1:-yes / no ? [y/N]}" answer
    case $answer in
            [yY][eE][sS]|[yY])
                true
            ;;
            *)
                false
            ;;
        esac
    }


# git log as tree with date - comment - commiter name
function gLog(){
    username=`git config user.name`
    usernameLog=`git log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all | sed /"$username"/q`

    branches=`git show-branch --list | sed -nr 's/^[\* ]*\[([a-zA-Z]*)\].*$/\1/p'`

    printf "%b\n" "$usernameLog"
}

# Fetch remote changes and display tree log
function displayFetchTreeLog(){
	sg_exec "git fetch"
}

function statusFiles(){
    # echo  "git st --porcelain |  egrep """$1"""  | cut -d \" \" -f$2"
    git st --porcelain |  egrep """$1"""  | cut -d " " -f$2 | while read param
        do
            line=$param
            fileEncoding=`file -bi $param | cut -d "=" -f2`
            if [ "$fileEncoding" = "utf-8" ] || [ "$fileEncoding" = "us-ascii" ]; then
                status="$GREEN"" ::  $fileEncoding""$NORMAL"
                linefull=$line$status
                printf "%b\n" "$linefull"
            else
                echo -e "$RED" " ::  $fileEncoding" "$NORMAL"
            fi

         done
}

function getStagedFiles(){
     if [ "`git st --porcelain |  egrep -c '^[A-Z]{1,2} '`" -gt "0" ]; then
        echo -e "Staged Files\n"
        regex="^[A-Z]{1} "
        statusFiles "$regex" 3

        regex="^[A-Z]{2} "
        statusFiles "$regex" 2
        return 0
    else
        return 1
    fi
}

function getUnstagedFiles(){
    regex="^ [A-Z]{1} "
    if [ "`git st --porcelain |  egrep -c """$regex"""`" -gt "0" ]; then
        printf "%b\n" "Unstaged Files\n"
        statusFiles "$regex" 3
        return 0
    else
        return 1
    fi
}


function displayRepositoryChanges(){
    stagedFiles=`getStagedFiles`
    exitStatusFunc1=$?
    unstagedFiles=`getUnstagedFiles`
    exitStatusFunc2=$?

    if [ $exitStatusFunc1 -eq 0 -o $exitStatusFunc2 -eq 0 ]; then
        echo "Your local changes : "
        if [ $exitStatusFunc1 -eq 0 ];then
            echo -e $stagedFiles
        fi
        if [ $exitStatusFunc2 -eq 0 ];then
            printf "%b\n" "$unstagedFiles"
        fi
    else
        echo "**No local changes**"
    fi
}

function getCurrentBranch(){
    branch=`git branch | grep \* | cut -d " " -f2`
    printf "%b\n" "$branch"
}

#Display working branch
function displayWorkingBranch(){
    local branch=$1
    local pattern="^prod.*|^int.*"
    if [[ "$branch" =~ ($pattern) ]]; then
        color=$RED
    else
        color="$GREEN"
    fi

    branch=`echo "$branch"| tr  '[:lower:]' '[:upper:]'`
    echo -e "You are working in branch :  $color" "$branch" "$NORMAL"
}

function stashAndPull(){
    confirm "Would you like to stash your current work and do a pull? [y/N] " && confirm "Please confirm one more time [y/N] "
    if [ $? -eq 0 ]; then
        sg_exec "git stash > /dev/null" && echo "Current work is now stagged"
        sg_exec "git pull --rebase > /dev/null" && echo "Pull successful" && displayFetchTreeLog
        sg_exec "git stash pop"
        displayRepositoryChanges
    fi
}

# Echo and exec a command
function sg_exec(){
    sg_info_echo "command : " $1
    eval $1
#    "$($1)"
}

validate_args ()
{
  value=$1
  shift
  arr=$@
  if [[ ! " ${arr[@]} " =~ " ${value} " ]]; then
      # when arr doesn't contain value
      echo "FATAL ERROR :: Not valid parameter : $value"
      print_help
      die
  fi
}

function checkIfPullPossible
{
    if [ `git st --porcelain -uno | wc -l` -gt 0 ]; then
        return 0
    fi
    return -1
}

# ask for commit message

# ask confirmation for commit message with current messsage
