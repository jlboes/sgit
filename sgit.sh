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

# @niceToHave : check for codingStandard 


# File encoding
#US-ASCII -- is -- a subset of UTF-8 (see Ned's answer below)
#Meaning that US-ASCII files are actually encoded in UTF-8




function confirm(){
	# call with a prompt string or use a default
	read -r -p "${1:-yes / no ? [y/N]}" anwser
	case $anwser in
            [yY][eE][sS]|[yY]) 
                true
            ;;
            *)
                false
            ;;
        esac
}






if [ "`git log --pretty=%H ...refs/heads/master^ | head -n 1`" = "`git ls-remote origin -h refs/heads/master |cut -f1`" ]; then

	echo -e "Repository is up to date... ""$BACKGREEN"" ""$NORMAL" 
	git st
else
	echo -e "Repository is ""$ROUGE""not""$NORMAL"" up to date"
	echo "Checking if pull is possible"
	if [ "`git st --porcelain -u no | wc -l`" -gt "1" ]; then
		echo "Unstaged file => cannot pull changes"
		#display files
		 git st --porcelain | grep M | cut -d " " -f3 | while read param
		 do
		         echo -n $param
	        	 fileEncoding=`file -bi $param | cut -d "=" -f2`
	        	 if [ "$fileEncoding" = "utf-8" ]; then
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
