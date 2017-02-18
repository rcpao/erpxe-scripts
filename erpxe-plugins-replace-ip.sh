#!/bin/bash -x

# erpxe-plugins-replace-ip.sh
#   Replaces $OLDIP with $NEWIP in all *.menu files under /tftpboot/er/plugins/.
#
# Sat Feb 18 08:06:40 PST 2017
# Roger C. Pao <erpxe-plugins-replace-ip.20.rcpao1@xoxy.net>


# OLDIP = the IP address to be replaced in all *.menu files.
# NEWIP = the IP address of this ERPXE server
#   'ip address show' or 'ifconfig' will display this host's configured IP addresses.
OLDIP=10.0.0.1
NEWIP=172.17.2.80


BACKUPEXT=.replace_ip_oldip


file_replace_ip() {
  # Make a backup of the oldip *.menu file
  #echo $OLDIP $NEWIP # DBG
  [ ! -f $1${BACKUPEXT} ] && cp $1 $1${BACKUPEXT}
  # DBG [ -f $1${BACKUPEXT} ] && echo sed ... in=$1${BACKUPEXT} out=$1
  # DBG [ -f $1${BACKUPEXT} ] && sed -e "s/$OLDIP/$NEWIP/g" $1${BACKUPEXT} 
  [ -f $1${BACKUPEXT} ] && sed -e "s/$OLDIP/$NEWIP/g" $1${BACKUPEXT} > $1
}


file_restore_oldip() {
  # Restore the oldip *.menu file
  [ -f $1${BACKUPEXT} ] && mv $1${BACKUPEXT} $1
}


# Uncomment one of the following commands:
find /tftpboot/er/plugins -name "*.menu" | while read fname; do file_replace_ip "$fname"; done
#find /tftpboot/er/plugins -name "*.menu" | while read fname; do file_restore_oldip "$fname"; done
