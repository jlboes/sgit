#!/bin/bash


function merge()
{
    # @todo check on parameter
    branchToReturn=$(getCurrentBranch)
    branch=$1 && \
    git checkout "${branch}"
    if [ checkIfPullPossible ]; then
        pull  && \
        git checkout "${branchToReturn}"  && \
        git merge --no-ff --no-edit ${branch}
        return 0
        else
        sg_warn_echo  "repository is not clear for pull"
        git checkout "${branchToReturn}"
    fi
    return -1
}

function pull()
{
    sg_exec "git pull --rebase"
}