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
	git log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all | head
}

# Fetch remote changes and display tree log
function displayFetchTreeLog(){
	git fetch
	gLog
}

function statusFiles(){
	#echo  'git st --porcelain |  egrep """$1"""  | cut -d " " -f$2'
	git st --porcelain |  egrep """$1"""  | cut -d " " -f$2 | while read param
        do
            echo -n $param
            fileEncoding=`file -bi $param | cut -d "=" -f2`
            if [ "$fileEncoding" = "utf-8" ] || [ "$fileEncoding" = "us-ascii" ]; then
                echo -e "$VERT" " ::  $fileEncoding" "$NORMAL"
            else
                echo -e "$ROUGE" " ::  $fileEncoding" "$NORMAL"
            fi

         done

}

function getStagedFiles(){
	if [ "`git st --porcelain |  egrep -c '^[A-Z]{1,2} '`" -gt "0" ]; then
		regex="^[A-Z]{1} "
		statusFiles "$regex" 3
		
		regex="^[A-Z]{2} "
		statusFiles "$regex" 2
		return 1
	else
		return 0
	fi
}

function getUnstagedFiles(){
  	regex="^ [A-Z]{1} "
	if [ "`git st --porcelain |  egrep -c """$regex"""`" -gt "0" ]; then
	    statusFiles "$regex" 3
	else
	    return 0
	fi
}

#Display working branch
function displayWorkingBranch(){
	branch=`git branch | grep \* | cut -d " " -f2 | tr  '[:lower:]' '[:upper:]'`
	if [ "$branch" = "MASTER" ]; then
		color=$VERT
	else
		color="$ROUGE"
	fi

	echo -e "You are working in branch :  $color" "$branch" "$NORMAL"
}



displayWorkingBranch
if [ "`git log --pretty=%H ...refs/heads/master^ | head -n 1`" = "`git ls-remote origin -h refs/heads/master |cut -f1`" ]; then

	echo -e "Repository is up to date... ""$BACKGREEN"" ""$NORMAL" 
	
else
	echo -e "Repository is ""$ROUGE""not""$NORMAL"" up to date"
	displayFetchTreeLog
	echo "Checking if pull is possible"
	if [ "`git st --porcelain -uno | wc -l`" -gt "1" ]; then
		echo -e "Unstaged file =>  ""$ROUGE""cannot""$NORMAL"" pull changes"
		#display files
		getStagedFiles	
		
		getUnstagedFiles


		# ask to prop the files in order to pull?

	else
		echo "OK for pull"
		# display git lg
		confirm "Would you like to do a pull? [y/N] " && git pull --rebase && git log --oneline --abbrev-commit --all --graph --decorate --color | head
		#git commit
	fi
fi








# ask for commit message

# ask confirmation for commit message with current messsage
