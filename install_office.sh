#!/bin/bash

SOURCEDIR="/opt/install_office2007"
HOSTNAME=$(hostname | cut -c -15)
DEBUG=false
#DEBUG=true
FREQ=10

function install_office() {
    $DEBUG && printf "$USER:$GROUP:$HOMEDIR" && sleep 10
    $DEBUG && ( FLAGS="-av"; echo "Installing for $USER" ) || FLAGS="-a"
    rsync $FLAGS --chown=$USER:$GROUP $SOURCEDIR/PlayOnLinux/ $POLDIR
    sed -r -i "s/(Z:.?.?home.?.?)oem/\1${USER}/g; \
        s/(C:.?.?users.?.?)oem/\1${USER}/g; \
        s/oem-eMachines-E/${HOSTNAME}/g" \
        $POLDIR/wineprefix/Office2007/system.reg
    sed -r -i "s/(Z:.?.?home.?.?)oem/\1${USER}/g; \
        s/(C:.?.?users.?.?)oem/\1${USER}/g; 
        s/oem-eMachines-E/${HOSTNAME}/g; \
        s/(RSA.?.?)oem/\1${USER}/g" \
        $POLDIR/wineprefix/Office2007/user.reg
    sed -r -i "s/(Z:.?.?home.?.?)oem/\1${USER}/g; \
        s/(C:.?.?users.?.?)oem/\1${USER}/g; \
        s/oem-eMachines-E/${HOSTNAME}/g" \
        $POLDIR/wineprefix/Office2007/userdef.reg
    $DEBUG &&  echo "Setting up shortcuts..."
    find $POLDIR/shortcuts/ -type f -exec sed -r -i "s|/home/oem|${HOMEDIR}|g" {} \;
    mkdir -p $HOMEDIR/.local/share/applications/ || true
    rsync $FLASGS --chown=$USER:$GROUP $SOURCEDIR/shortcuts/* $HOMEDIR/.local/share/applications/
    find $HOMEDIR/.local/share/applications/ -type f -exec sed -r -i "s|(/home/)oem|\1${USER}|g" {} \;
    #rsync $FLAGS --chown=$USER:$GROUP $SOURCEDIR/desktop/* $HOMEDIR/Desktop/
    #find $HOMEDIR/Desktop/ -type f -exec sed -r -i "s|/home/oem|${HOMEDIR}|g" {} \;
    $DEBUG && echo "Installation successful.."
    return 0
}
while true; do
    for USER in $(users); do
	USERID=$(id -u $USER)
	GROUP=$(id -gn $USER)
	GROUPID=$(id -g $USER)
	HOMEDIR=$(eval echo ~$USER)
	POLDIR="$HOMEDIR/.PlayOnLinux"
	$DEBUG && printf "User: $USER\nGroup: $GROUP\nID: $USERID:$GROUPID\nHome dir: \
	    $HOMEDIR\nPlayOnLinux dir: $POLDIR\n"
	[[ $USERID -gt 999 ]] && \
	    [[ -f "$HOMEDIR/.install_office2007" ]] && \
	    [[ $(< $HOMEDIR/.install_office2007) == "1" ]] && \
	    echo "doing install" && install_office && echo "installed" && \
	    printf "0" > $HOMEDIR/.install_office2007 && echo "done"
    done
    sleep $FREQ
    FREQ=$(($FREQ * 5 / 4))
    $DEBUG && echo "SLEEP timer: $FREQ"
done