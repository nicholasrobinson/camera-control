#!/bin/bash

###################################################################
#
# Shell script for activate/deactivate a camera in the Surveillance
# Station of the Synology Diskstation via web api
# April 2015 - voltaikprojekt at thomashof-durlach dot de
#
# Arguments:
# ID: Id of the camera
# COMMAND: "on" or "off" for activating/deactivating camera with $ID
#
# e.g.: /path_to_script/script.sh 1 off
# Deactivates the camera with ID 1
####################################################################

## Edit this ##
WEBAPIURL="https://URL_OF_DISKSTATION:PORT/webapi/" # e.g. https://192.168.1.1:5001/webapi/ or http://192.168.1.1:5000/webapi/
ACCOUNT="ADMIN_ACCOUNT" # e.g. admin
PASSWD="PASSWORD_OF_ADMIN_ACCOUNT"
COOKIE_PATH="/PATH_TO_COOKIE/COOKIE_NAME" # e.g. /tmp/webapicookie.txt
PIMATIC_VAR="" # a pimatic variable to check if everything went fine, can be used for a fallback rule in pimatic / Leave empty for not sending
PIMATIC_URL="PIMATIC IP:PIMATIC PORT" # with http:// or https://
PIMATIC_USER=""
PIMATIV_PASS=""
###############

## Script, no editing from here on if you don't know what you're doing ;-) ##
CAMID="$1"
COMMAND="$2"
USAGE="\n(De)activates a camera in Synology Diskstation Surveillance Station\n\nUsage: /path_to_script/name_of_script ID COMMAND\n\nArguments:\nID: Id of the camera\nCOMMAND: \"on\" or \"off\" for activating/deactivating camera with $ID\n\ne.g.: /path_to_script/script.sh 1 off\nDeactivates the camera with ID 1\n"

## Check for help
if [[ $1 == "--help" ]]
then
  echo -e $USAGE
  exit 0
fi

## Checking Cam Id
if ! echo $CAMID | grep -q -e "^[0-9][0-9]*$"
then
  echo "Argument 1 (camera id) musst be a number!"
  echo -e $USAGE
  exit 1
fi

## Checking on/off command
shopt -s nocasematch

if [[ "$COMMAND" == "on" ]]
then
        METHOD="Enable"
else
        if [[ "$COMMAND" == "off" ]]
        then
                METHOD="Disable"
        else
                echo "No command found, exiting!"
                echo -e $USAGE
                shopt -u nocasematch
                exit 1
        fi
fi

shopt -u nocasematch


## Login to Diskstation

url="$WEBAPIURL/auth.cgi?api=SYNO.API.Auth&version=2&method=Login&session=SurveillanceStation&account=$ACCOUNT&passwd=$PASSWD"

authRsp=$(curl --header "Accept: application/json" \
    --header "Content-Type: application/x-www-form-urlencoded"      \
    --cookie-jar $COOKIE_PATH    \
    --user-agent "Mozilla/5.0 (Windows; U; Windows NT 5.0; en-US; rv:1.7.12) Gecko/20050915 Firefox/1.0.7"    \
    --referer ";auto"    \
    --insecure   \
    --location   \
    $url 2>/dev/null)

## debug ##
#echo $authRsp  #> /tmp/dswebapi.json
#exit 0

result=$(echo $authRsp | sed -r 's/^.*("success":(true|false)).*$/\2/')

## debug ##
echo "Trying to login to Diskstation: $result . " #>> /tmp/dswebapi.json
#exit 0

if [[ $result == "false" ]]
then
        echo "Login not possible, exiting"
        exit 1
fi

## Executing command

url="$WEBAPIURL/entry.cgi?api=SYNO.SurveillanceStation.Camera&method=$METHOD&version=3&cameraIds=$CAMID"

## debug ##
#echo $url  #>> /tmp/dswebapi.json
#exit 0

camRsp=$(curl --header "Accept: application/json" \
        --header "Content-Type: application/x-www-form-urlencoded"      \
        --cookie $COOKIE_PATH    \
        --user-agent "Mozilla/5.0 (Windows; U; Windows NT 5.0; en-US; rv:1.7.12) Gecko/20050915 Firefox/1.0.7"    \
        --referer ";auto"    \
        --insecure   \
        --location   \
        $url 2>/dev/null)

result=$(echo $camRsp | sed -r 's/^.*("success":(true|false)).*$/\2/')

## debug ##
echo "Trying to $METHOD camera with id $CAMID: $result . " #>> /tmp/dswebapi.json
#exit 0

if [[ $result == "false" ]]
then
        echo "Command was not executed!"
fi

## debug ##
#echo $camRsp  #>> /tmp/dswebapi.json
#exit 0

## Store the result for later
changeResult=$result

## Logout from Diskstation

url="$WEBAPIURL/auth.cgi?api=SYNO.API.Auth&version=2&method=Logout&session=SurveillanceStation"

authRsp=$(curl --header "Accept: application/json" \
    --header "Content-Type: application/x-www-form-urlencoded"      \
    --cookie $COOKIE_PATH    \
    --user-agent "Mozilla/5.0 (Windows; U; Windows NT 5.0; en-US; rv:1.7.12) Gecko/20050915 Firefox/1.0.7"    \
    --referer ";auto"    \
    --insecure   \
    --location   \
    $url 2>/dev/null)

## debug ##
#echo $authRsp #>> /tmp/curlres.html

result=$(echo $authRsp | sed -r 's/^.*("success":(true|false)).*$/\2/')

## debug ##
echo "Trying to logout from Diskstation: $result. " #>> /tmp/dswebapi.json
#exit 0

## Send result to a variable in pimatic
if [[ $PIMATIC_VAR != "" && ( $result == "true" || $result == "false" ) ]]
then
	if [[ ( $METHOD == "Enable" && $changeResult == "true" ) || ( $METHOD == "Disable" && $changeResult == "false" ) ]]
	then
	    camStatus=1
	else
		camStatus=0
	fi
	
    pimRsp=$(curl --header "Content-Type:application/json" \
                  --insecure \
				  -X PATCH 	\
				  --data '{"type": "value", "valueOrExpression": '"${camStatus}"'}' \
				  --user "${PIMATIC_USER}:${PIMATIC_PASS}" \
				  $PIMATIC_URL/api/variables/$PIMATIC_VAR 2>/dev/null)
				  
    ## debug ##
    #echo $pimRsp

    result=$(echo $pimRsp | sed -r 's/^.*("success": (true|false)).*$/\2/')
	
	## debug ##
    echo "Trying to set variable $PIMATIC_VAR to $camStatus in pimatic: $result. " #>> /tmp/dswebapi.json
    #exit 0
fi

if [[ $result == "false" ]]
then
    echo "Logout not possible, destroying session cookie!"
    rm $COOKIE_PATH
    exit 1
fi

exit 0