#Arch-Linux-install-doc
unstructured_doc
Planungsphase, Vorbereitung, Ideen für die Installation

##wipe disk
# use vendor-secific or commom-sense documented save mechanisms to securely erase all past data on the disc
#
##disable secure boot
# disable secure boot for as long as installing Arch Linux until you are ready to set secure boot up for the Arch installation

##boot into live environment
## first commands to help us work in the live environment
loadkeys de-latin1 	# german keyboard layout ( "y" = "z" and "-" = "ß")
wifi-menu		# dialog for connecting to nearby wlan if no ethernet cable is around

## create partitions and create filesystems:
fdisk /dev/nvme0n1	# commands within fdisk are found with 'm', it's quite intuitive, but if this is already too much or too confusing, consider using Ubuntu or Debian ;)
			# I quote the shortcuts, but you should really consider to understand, what you're doing here, this is the base of the overall installation.
##	create new gpt-partitiontable for UEFI-boot ('g')
##	1st partition=EFI 550MiB ('n' > 'Enter' > 'Enter' > +550M > 'Enter' > 't' > '1')
##	2nd partition=cryptswap Linux filesystem type (RAM+2GB) for encrypted swap ('n' > 'Enter' > 'Enter' > '+16G' > 'Enter') NOTE: +16G = (16GiB - 2GiB (for integrated Graphics on Lenovo ThinkPad E495)) + 2 GiB
##	3rd partition=cryptroot (root+home+snapshots) Linux filesystem type rest of space available ('n' > 'Enter' > 'Enter' > 'Enter' > 'Enter')
## 	'p' to show the changes to the disk
## 	if you feel comfortable with your job you can type 'w' to write the changes to the disk 

## Create Filesystems to our new fresh partitions
mkfs.fat -F32 -n EFI /dev/nvme0n1p1 (/dev/sda1 on non-nvme) # EFI system partition, must not be encrypted!
mkfs.btrfs -l btrfs_main /dev/nvme0n1p3 (/dev/sda3 on non-nvme) # encrypted Btrfs-partition homing root, home and .snapshots

## Encrypt the cryptroot partition; NOTE: GRUB only supports luks1 as of dec2019! The default for cryptsetup, using cryptsetup without type is already luks2
cryptsetup -v --type luks1 --cipher aes-xts-plain64 --key-size 256 --hash sha256 --iter-time 2000 --use-urandom --verify-passphrase luksFormat /dev/nvme0n1p3
	# encrypt the 3rd partition with given parameters, note: for GRUB compatibility it must be type luks1, since GRUB does not support luks2 as of december 2019
	# you will be prompted twice for a password

##now open the encrypted partition and mount it to create the subvolumes:
cryptsetup open /dev/nvme0n1p3 cryptroot 	# this opens the encrypted device; cryptroot is the device-mapper name, device will further occur as /dev/mapper/cryptroot
	# you will be prompted for passphrase

mount /dev/mapper/cryptroot /mnt 		# this will mount the decrypted device to /mnt

## create subvolumes on /mnt, at least root and home:
btrfs subvolume create /mnt/@ 			# this will be the root-subvolume
btrfs subvolume create /mnt/@home		# this will be the home-subvolume
btrfs subvolume create /mnt/@snapshots		# guess what... this will contain our snapshots later

## create the mount-points and mount the subvolumes
mount -o compress=lzo,subvol=@ /dev/mapper/cryptroot /mnt
mkdir /mnt/home
mount -o compress=lzo,subvol=@home /dev/mapper/cryptroot /mnt/home
mkdir /mnt/.snapshots
mount -o compress=lzo,subvol=@home /dev/mapper/cryptroot /mnt/.snapshots

## now we can install our packages into root
pacstrap /mnt base base-devel efibootmgr grub-efi-x86_64 cryptsetup btrfs-progs bash-completion vim dkms git linux-headers mesa xf86-video-amdgpu dialog amd-ucode linux linux-firmware dosfstools netctl
	# these packages where chosen for my lenovo e495 and depend on the hardware and the overall setup

## modify mkinitcpio.conf for encryption
vim /etc/mkinitcpio.conf

	# examples will follow

## format USB-Stick for cryptkey
fdisk /dev/sdb
	# format as fat32 (you will need "dosfstools")
## create Filesystem 
mkfs.fat -F32 -n CRYPTUSB /dev/sdb1
## create mount-point and mount
mkdir /mnt/CRYPTUSB
mount /dev/sdb1 /mnt/CRYPTUSB

## create key for nvme0n1p3 and write it onto the stick
dd bs=512 count=4 if=/dev/random of=/mnt/CRYPTUSB/crypto_keyfile iflag=fullblock
## permit the readability only to root
chmod 600 /mnt/CRYPTUSB/crypto_keyfile
## add the Keyfile to the LUKS-Keys for nvme0n1p3
cryptsetup luksAddKey /dev/nvme0n1p3 /mnt/CRYPTUSB/crypto_keyfile

## modify GRUB to handle encrypted devices and unlock the cryptroot with given Keyfile
vim /etc/default/grub
	# example will follow

## install GRUB
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=arch_grub --recheck --debug
	# control for errors, this is one crucial step

## genreate the grub-menu-entries
grub-mkconfig -o /boot/grub/grub.cfg
	# control again for errors, as this is the next crucial step

## useful tool for handling pacman-mirrors: reflector, see examples

## set root-password
passwd

## configure encrypted swap, it will not support hibernation or suspend to disk in this scenario
## create a small partition on swappartition just for creating a persistent UUID and/or LABEL for the following swap, which will be recreated and reencrypted on every bootup
mkfs.ext2 -L cryptswap /dev/nvme0n1p2 1M 	# note, the 1M indicates, that this partition is just 1MiB, leaving enough space for swap behind it

## if /dev/nvme0n1p2 was accidentally encrypted with LUKS, the LUKS-header has to be wiped first
head -c 1052672 /dev/urandom > /dev/nvme0n1p2
sync

## then recreate the small LABEL or UUID-placeholder

## uncomment line "swap" in /etc/crypttab
# place example of /etc/crypttab here

## modify the fstab for the new cryptswap
# place example of /etc/fstab here

## finally generate the initramfs with modified mkinitcpio.conf
mkinitcpio -p linux

	# look for errors as this is crucial
