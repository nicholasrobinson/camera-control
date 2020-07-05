#!/bin/bash

# Script for controlling a Synology Surveillance Station Camera.
# Usage: bash CameraControl.sh Set <COMMAND> On true

if [ "$1" = "Get" ]; then
   # Stateless switch is always off
   echo "0"
   exit 0
fi

if [ "$1" = "Set" ]; then
   if [ "$3" = "On" ]; then
      if [ "$4" = "true" ]; then
         # Execute camera-control.sh
         ./camera-control.sh CAMERA_ID "$2"
         exit $?
      else
         # There is no turning off a command
         exit 0
      fi
   fi
fi

exit -1
