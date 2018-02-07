#!/bin/bash


function merge()
{
    # @todo check on parameter
    branchToReturn=$(getCurrentBranch)
    branch=$1 && \
    git checkout "${branch}"
    if [ $? -ne 0 ]; then
        sg_warn_echo  "repository is not clear for checkout"
        return -1
    fi

    if [ checkIfPullPossible ]; then
        pull  && \
        git checkout "${branchToReturn}"  && \
        git merge --no-ff --no-edit ${branch}
        return 0
    fi

    git checkout "${branchToReturn}"
    sg_warn_echo  "repository is not clear for pull"
    return -1
}

function pull()
{
    sg_exec "git pull --rebase"
}