#!/bin/bash


DIR="$(dirname "$(readlink -f "$0")")"
source "$DIR/gitFunc.sh"
source ${DIR}/sgit.sh
source ${DIR}/secho.sh



branch=`getCurrentBranch`
displayWorkingBranch $branch

if [ $# -gt 0 ]; then
    cmd=$1
    shift
    cmd_args="'$*'"
    validate_args ${cmd} ${_valid_cmd[@]}
    echo " > $cmd ${cmd_args}"
    eval "$cmd ${cmd_args}"

elif [ "`git log --pretty=%H ...refs/heads/$branch^ | head -n 1`" = "`git ls-remote origin -h refs/heads/$branch |cut -f1`" ]; then

    echo -e "Repository is up to date... ""$BACKGREEN"" ""$NORMAL"
    displayRepositoryChanges

else
    echo -e "Repository is ""$ROUGE""not""$NORMAL"" up to date"
    displayFetchTreeLog
    echo "Checking if pull is possible"
    if [ `git st --porcelain -uno | wc -l` -gt 0 ]; then
        echo -e "Unstaged file =>  ""$ROUGE""cannot""$NORMAL"" pull changes"
        #display files
#        displayRepositoryChanges

        # ask to prop the files in order to pull?
        stashAndPull

    else
        echo "OK for pull"
        # display git lg
        confirm "Would you like to do a pull? [y/N] " && sg_exec "git pull --rebase" && displayFetchTreeLog
        #git commit
    fi
fi
