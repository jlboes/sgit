#!/bin/bash


RED="\\033[1;31m"
GREEN="\\033[1;32m"
NORMAL="\\033[0;39m"
BLUE="\\033[1;34m"
BACKGREEN="\\033[0;42m"


function sg_echo(){
    msg="$*"
    echo " > $msg";
}


function sg_warn_echo(){
    msg="$*"
    echo -e "$RED" " >> $msg" "$NORMAL"
}