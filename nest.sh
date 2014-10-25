#!/bin/bash

## I don't like --dev --force parameters. ;)
echo "You have to change your configuration and remove this line"
#exit 2

DISK='/dev/sda'
BOOT_DISK="${DISK}1"
HOME_DISK="${DISK}2"


## http://en.wikipedia.org/wiki/Characters_of_the_Final_Fantasy_VII_series#Professor_Hojo
ROOT_PASSWORD=$(/usr/bin/openssl passwd -crypt 'root')
USER_NAME='hojo'
USER_PASSWORD=$(/usr/bin/openssl passwd -crypt 'hojo')
FQDN='hojo.ko'
KEYMAP='de'
TIMEZONE='UTC+2'
LANGUAGE='en_US.UTF-8'
TARGET_DIR='/mnt'
USER_HOME="/home/${USER_NAME}"
NEST_PATH="${USER_HOME}/etc/nest"

case "$1" in
"prepare-hdd")
echo "> > > prepare hdd < < <"

/usr/bin/sgdisk --zap ${DISK}

echo ">>> set positions <<<"
/usr/bin/sgdisk --new=1:0:512M ${DISK}
/usr/bin/sgdisk --new=2:0:0 ${DISK}

echo ">>> set names <<<"
/usr/bin/sgdisk --change-name 1:boot ${DISK}
/usr/bin/sgdisk --change-name 2:root ${DISK}

echo ">>> set types <<<"
/usr/bin/sgdisk --typecode=1:ef00 ${DISK}
/usr/bin/sgdisk --typecode=2:8300 ${DISK}

echo ">>> format <<<"
/usr/bin/mkfs.fat -F32 ${BOOT_DISK}
/usr/bin/mkfs.ext3 ${HOME_DISK}

echo ">>> mount <<<"
/usr/bin/mount ${HOME_DISK} ${TARGET_DIR}
/usr/bin/mkdir ${TARGET_DIR}/boot
/usr/bin/mount ${BOOT_DISK} ${TARGET_DIR}/boot
;;
"install")
echo "> > > install < < <"

echo '>>> bootstrapping the base installation <<<'
/usr/bin/pacstrap ${TARGET_DIR} base base-devel wpa_supplicant dialog gummiboot

echo '>>> generating the filesystem table <<<'
/usr/bin/genfstab -p ${TARGET_DIR} >> "${TARGET_DIR}/etc/fstab"

;;
"configure")
echo "> > > configure < < <"

echo ${FQDN} > /etc/hostname
/usr/bin/ln -s /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
echo "KEYMAP=${KEYMAP}" > /etc/vconsole.conf
/usr/bin/sed -i "s/#${LANGUAGE}/${LANGUAGE}/" /etc/locale.gen
/usr/bin/locale-gen
/usr/bin/mkinitcpio -p linux
/usr/bin/usermod --password ${ROOT_PASSWORD} root

echo ">>> setup user <<< "
/usr/bin/groupadd ${USER_NAME}
/usr/bin/useradd --password ${USER_PASSWORD} --comment 'main user' --create-home --gid users --groups ${USER_NAME} ${USER_NAME}
echo 'Defaults env_keep += "SSH_AUTH_SOCK"' > /etc/sudoers.d/10_${USER_NAME}
echo "${USER_NAME} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/10_${USER_NAME}
/usr/bin/chmod 0440 /etc/sudoers.d/10_${USER_NAME}

echo ">>> bootloader <<< "
/usr/bin/gummiboot --path=/boot install
/usr/bin/install --mode=0755 /dev/null /boot/loader/loader.conf
cat <<-EOF > /boot/loader/loader.conf
default  arch
timeout  10
EOF

/usr/bin/install --mode=0755 /dev/null /boot/loader/entries/arch.conf
cat <<-EOF > /boot/loader/entries/arch.conf
title          Arch Linux
linux          /vmlinuz-linux
initrd         /initramfs-linux.img
options        root=${HOME_DISK} rw
EOF

echo ">>> clean up <<< "
/usr/bin/pacman -Rcns --noconfirm gptfdisk
/usr/bin/pacman -Scc --noconfirm
;;
"init-utils")
echo "> > > install utilites < < <"

echo "<<< install wget, puppet and base-devel >>>"
pacman -S wget --noconfirm
pacman -S puppet  --noconfirm
pacman -S base-devel --noconfirm
pacman -S nfs-utils --noconfirm

echo "<<< install package-query with makepkg >>>"
wget https://aur.archlinux.org/packages/pa/package-query/package-query.tar.gz
tar -xvzf package-query.tar.gz
cd package-query
makepkg -si --noconfirm --asroot

echo "<<< install yaourt with makepkg >>>"
wget https://aur.archlinux.org/packages/ya/yaourt/yaourt.tar.gz
tar -xvzf yaourt.tar.gz
cd yaourt
makepkg -si --noconfirm --asroot

echo "<<< install nest >>>"
mkdir -p ${USER_HOME}/etc
git clone git@github.com:kolibri/arch-nest.git ${NEST_PATH}

;;
"provision")
    sudo puppet apply --parser future  \
        --hiera_config="${NEST_PATH}/puppet/hiera.yaml" \
          --modulepath="${NEST_PATH}/puppet/modules" \
        --debug --verbose ${NEST_PATH}/puppet/manifests/site.pp

;;
"dump")
echo "DISK:          ${DISK}"
echo "BOOT_DISK:     ${BOOT_DISK}"
echo "HOME_DISK:     ${HOME_DISK}"
echo "TARGET_DIR:    ${TARGET_DIR}"
echo "ROOT_PASSWORD: ${ROOT_PASSWORD}"
echo "USER_NAME:     ${USER_NAME}"
echo "USER_PASSWORD: ${USER_PASSWORD}"
echo "FQDN:          ${FQDN}"
echo "TIMEZONE:      ${TIMEZONE}"
echo "KEYMAP:        ${KEYMAP}"
echo "LANGUAGE:      ${LANGUAGE}"
echo "CONFIG_DONE:   ${CONFIG_DONE}"

;;
*)
echo "choose command"
cat $0 | grep "\")"

;;
esac
