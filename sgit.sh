#!/bin/bash


ROUGE="\\033[1;31m"
VERT="\\033[1;32m"
NORMAL="\\033[0;39m"
BLEU="\\033[1;34m"
BACKGREEN="\\033[0;42m"



# @todo : check encoding for every committed file
# Display Warn message + ask confirm before commit

# @todo Error management
# @todo use function read commit message sur plusieurs ligne?
# @todo check if current version is uptodate :: option in config file

#todo display changess to be committed

# @niceToHave : check for codingStandard 


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
	git fetch > /dev/null
	gLog
}

function statusFiles(){
	# echo  "git st --porcelain |  egrep """$1"""  | cut -d \" \" -f$2"
	git st --porcelain |  egrep """$1"""  | cut -d " " -f$2 | while read param
        do
            line=$param
            fileEncoding=`file -bi $param | cut -d "=" -f2`
            if [ "$fileEncoding" = "utf-8" ] || [ "$fileEncoding" = "us-ascii" ]; then
                status="$VERT"" ::  $fileEncoding""$NORMAL"
                linefull=$line$status
                printf "%b\n" "$linefull"
            else
                echo -e "$ROUGE" " ::  $fileEncoding" "$NORMAL"
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
    branch=`echo "$1"| tr  '[:lower:]' '[:upper:]'`
	if [ $branch = "MASTER" ]; then
		color=$VERT
	else
		color="$ROUGE"
	fi

	echo -e "You are working in branch :  $color" "$branch" "$NORMAL"
}


branch=`getCurrentBranch`
echo $branch
displayWorkingBranch $branch
if [ "`git log --pretty=%H ...refs/heads/dev^ | head -n 1`" = "`git ls-remote origin -h refs/heads/master |cut -f1`" ]; then

	echo -e "Repository is up to date... ""$BACKGREEN"" ""$NORMAL" 
	displayRepositoryChanges
	
else
	echo -e "Repository is ""$ROUGE""not""$NORMAL"" up to date"
	displayFetchTreeLog
	echo "Checking if pull is possible"
	if [ `git st --porcelain -uno | wc -l` -gt 0 ]; then
		echo -e "Unstaged file =>  ""$ROUGE""cannot""$NORMAL"" pull changes"
		#display files
		displayRepositoryChanges

		# ask to prop the files in order to pull?

	else
		echo "OK for pull"
		# display git lg
		confirm "Would you like to do a pull? [y/N] " && git pull --rebase && displayFetchTreeLog
		#git commit
	fi
fi








# ask for commit message

# ask confirmation for commit message with current messsage
