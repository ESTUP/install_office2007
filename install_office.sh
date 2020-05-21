#!/bin/bash

SOURCEDIR="/opt/install_office2007"
HOSTNAME=$(hostname | cut -c -15)
DEBUG=false
DEBUG=true
FREQ=10

function install_office() {
    $DEBUG && printf "$POLUSER:$GROUP:$HOMEDIR\n"
    $DEBUG && echo "Installing for $POLUSER"
    rsync -a --chown=$POLUSER:$GROUP $SOURCEDIR/PlayOnLinux/ $POLDIR
    sed -r -i "s/(Z:.?.?home.?.?)oem/\1${POLUSER}/g; \
        s/(C:.?.?users.?.?)oem/\1${POLUSER}/g; \
        s/oem-eMachines-E/${HOSTNAME}/g" \
        $POLDIR/wineprefix/Office2007/system.reg
    sed -r -i "s/(Z:.?.?home.?.?)oem/\1${POLUSER}/g; \
        s/(C:.?.?users.?.?)oem/\1${POLUSER}/g; 
        s/oem-eMachines-E/${HOSTNAME}/g; \
        s/(RSA.?.?)oem/\1${POLUSER}/g" \
        $POLDIR/wineprefix/Office2007/user.reg
    sed -r -i "s/(Z:.?.?home.?.?)oem/\1${POLUSER}/g; \
        s/(C:.?.?users.?.?)oem/\1${POLUSER}/g; \
        s/oem-eMachines-E/${HOSTNAME}/g" \
        $POLDIR/wineprefix/Office2007/userdef.reg
    $DEBUG &&  echo "Setting up shortcuts..."
    find $POLDIR/shortcuts -type f -exec sed -r -i "s|/home/oem|${HOMEDIR}|g" {} \;
    sudo -u $POLUSER mkdir -p $HOMEDIR/.local/share/applications || true
    rsync -a --chown=$POLUSER:$GROUP $SOURCEDIR/shortcuts/ $HOMEDIR/.local/share/applications
    find $HOMEDIR/.local/share/applications -type f -exec sed -r -i "s|(/home/)oem|\1${POLUSER}|g" {} \;
    sudo -u $POLUSER xdg-desktop-menu forceupdate
    #rsync $FLAGS --chown=$POLUSER:$GROUP $SOURCEDIR/desktop/* $HOMEDIR/Desktop/
    #find $HOMEDIR/Desktop/ -type f -exec sed -r -i "s|/home/oem|${HOMEDIR}|g" {} \;
    $DEBUG && echo "Installation successful.."

    return 0
}
while true; do
    for POLUSER in $(users); do
	USERID=$(id -u $POLUSER)
	GROUP=$(id -gn $POLUSER)
	GROUPID=$(id -g $POLUSER)
	HOMEDIR=$(eval echo ~$POLUSER)
	POLDIR="$HOMEDIR/.PlayOnLinux"
	$DEBUG && printf "User: $POLUSER\nGroup: $GROUP\nID: $USERID:$GROUPID\nHome dir: \
	    $HOMEDIR\nPlayOnLinux dir: $POLDIR\n"
	[[ $USERID -gt 999 ]] && \
	    [[ -f "$HOMEDIR/.install_office2007" ]] && \
	    [[ $(< $HOMEDIR/.install_office2007) == "1" ]] && \
	    install_office && \
	    printf "0" > $HOMEDIR/.install_office2007
    done
    sleep $FREQ
    FREQ=$(($FREQ * 5 / 4))
    $DEBUG && echo "SLEEP timer: $FREQ"
done
