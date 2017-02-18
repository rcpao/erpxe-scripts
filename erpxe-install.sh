#!/bin/bash -x


# Verify you have root privileges.
if [[ $EUID -ne 0 ]]; then
  echo "You do not have root privileges." 2>&1
  exit 1
fi


# ERPXE to /tftpboot
[ ! -d /tftpboot ] && cd / && git clone https://github.com/ERPXE/tftpboot.git


# openssh-server

apt-get -y install openssh-server


# tftpd-hpa

apt-get -y install tftpd-hpa

[ -f /etc/default/tftpd-hpa ] && [ ! -f /etc/default/tftpd-hpa-before-erpxe-$$ ] && mv /etc/default/tftpd-hpa /etc/default/tftpd-hpa-before-erpxe-$$

(
cat << 'EOF'
TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/tftpboot/"
TFTP_ADDRESS="0.0.0.0:69"
TFTP_OPTIONS="-m /tftpboot/erpxe.remap -vvvvv -s"
EOF
) > /etc/default/tftpd-hpa

update-rc.d tftpd-hpa defaults


# apache2

apt-get -y install apache2

cp /tftpboot/bin/setup/erpxe-httpd.conf /etc/apache2/conf-available/
a2enconf erpxe-httpd

update-rc.d apache2 defaults


# NFS

apt-get -y install nfs-kernel-server

cp /etc/exports > /etc/exports-before-erpxe-$$
cat /tftpboot/bin/setup/erpxe-exports > /etc/exports

update-rc.d nfs-kernel-server defaults


# samba

apt-get -y install samba

[ -f /etc/samba/smb.conf ] && cp /etc/samba/smb.conf /etc/samba/smb.conf-before-erpxe-$$ 
cat /tftpboot/bin/setup/erpxe-smb.conf > /etc/samba/smb.conf

update-rc.d samba defaults

useradd --no-create-home -s /dev/null erpxe
smbpasswd -a erpxe
smbpasswd -a root


# ubuntu does not include selinux by default

# restorecon -r /tftpboot


echo You should reboot your system now.
