# Motivation

I wanted to control a PTZ synology surveillance station camera via homebridge.

# Example config.json

```
...
    {
        "platform": "Cmd4",
        "name": "Cmd4",
        "accessories": [
            {
                "type": "Switch",
                "displayName": "on",
                "on": "FALSE",
                "name": "Man Cave Camera - On",
                "state_cmd": "/homebridge/Cmd4Scripts/camera-control.sh",
                "polling": true,
                "interval": 5,
                "timeout": 60000
            },
            {
                "type": "Switch",
                "displayName": "off",
                "on": "FALSE",
                "name": "Man Cave Camera - Off",
                "state_cmd": "/homebridge/Cmd4Scripts/camera-control.sh",
                "polling": true,
                "interval": 5,
                "timeout": 60000
            },
            {
                "type": "Switch",
                "displayName": "door",
                "on": "FALSE",
                "name": "Man Cave Camera - Door",
                "state_cmd": "/homebridge/Cmd4Scripts/camera-control.sh",
                "polling": true,
                "interval": 5,
                "timeout": 60000
            },
            {
                "type": "Switch",
                "displayName": "battery",
                "on": "FALSE",
                "name": "Man Cave Camera - Battery",
                "state_cmd": "/homebridge/Cmd4Scripts/camera-control.sh",
                "polling": true,
                "interval": 5,
                "timeout": 60000
            },
            {
                "type": "Switch",
                "displayName": "privacy",
                "on": "FALSE",
                "name": "Man Cave Camera - Privacy",
                "state_cmd": "/homebridge/Cmd4Scripts/camera-control.sh",
                "polling": true,
                "interval": 5,
                "timeout": 60000
            }
        ]
   }
...
```

# Example camera-control.sh

Change:
```
./camera-control.sh CAMERA_ID "$2"
```

to (your camera id - discovered using `camera-control.sh 1 list`):
```
./camera-control.sh 5 "$2"
```

# Example camera-control.sh

Numerous changes are required to:
```
- PRESET_ID
- WEBAPIURL
- ACCOUNT
- PASSWD
- COOKIE_PATH
```

# References
https://forum.pimatic.org/topic/382/controlling-a-camera-of-surveillance-station-with-web-api-of-the-synology-diskstation/2
