#! /bin/sh

ACTION=$1

case "$ACTION" in 
    -h | help )
    echo  "-h or -help    help (tells what all this script can do) "
    ;;

    -a | add )
    echo "Lets let u some contact"
    NAME=$2
    PHONE=$3
    EMAIL=$4
    NOTE=$5
    if [ "$NAME" = "" ]
    then
        read -p " What should be the name of the contact ( ie : Rohan Khanna ) :" NAME
    fi
    if [ "$PHONE" = "" ]
    then
        read -p " What should be the PHONE of the contact ( ie : +919876543210 ) :" PHONE
    fi
    if [ "$EMAIL" = "" ]
    then
        read -p " What should be the EMAIL of the contact ( ie : user@example.com ) :" EMAIL
    fi
    if [ "$NOTE" = "" ]
    then
        read -p " What should be the NOTE of the contact ( ie : He is a Doctor ) :" NOTE
    fi


    echo "ADDING $NAME $PHONE $EMAIL $NOTE"
    ;;
    *)
    echo "-h or -help    help ( tells what all this script can do ) ";;
esac