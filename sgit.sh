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
# @todo check if current version is uptodate

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



if [ "`git log --pretty=%H ...refs/heads/master^ | head -n 1`" = "`git ls-remote origin -h refs/heads/master |cut -f1`" ]; then

	echo -e "Repository is up to date... ""$BACKGREEN"" ""$NORMAL" 
	git st
else
	echo -e "Repository is ""$ROUGE""not""$NORMAL"" up to date"
	displayFetchTreeLog
	echo "Checking if pull is possible"
	if [ "`git st --porcelain -uno | wc -l`" -gt "1" ]; then
		echo -e "Unstaged file =>  ""$ROUGE""cannot""$NORMAL"" pull changes"
		#display files
		 git st --porcelain |  grep -v ?? | cut -d " " -f2,3 | while read param
		 do
		         echo -n $param
	        	 fileEncoding=`file -bi $param | cut -d "=" -f2`
	        	 if [ "$fileEncoding" = "utf-8" ] || [ "$fileEncoding" = "us-ascii" ]; then
        		         echo -e "$VERT" " ::  $fileEncoding" "$NORMAL"
		         else
	        	         echo -e "$ROUGE" " ::  $fileEncoding" "$NORMAL"
        		 fi
	
		 done

	else
		echo "OK for pull"
		# display git lg
		confirm "Would you like to do a pull? [y/N] " && git pull --rebase && git log --oneline --abbrev-commit --all --graph --decorate --color
		#git commit
	fi
fi








# ask for commit message

# ask confirmation for commit message with current messsage
