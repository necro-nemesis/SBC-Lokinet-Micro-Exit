SBC Lokinet Micro Exit

![](https://i.imgur.com/H6cZ0TD.png)

# `SBC Lokinet Micro Exit` [![Release 1.0](https://img.shields.io/badge/Release-1.0-green.svg)](https://github.com/necro-nemesis/raspap-webgui/releases)

SBC Lokinet Micro Exit is an easy to use Lokinet Exit set up tool to rapidly configure an Exit on a Debian based Single Board Computer (SBC) utilizing .deb packages. The installer can configure an exit for Lokinet on an SBC running Debian, Raspberry OS or Armbian. This allows anyone to host their own exit using Lokinet network. After installing a fresh image, running the script and following the installers instructions the device will launch your exit providing you with your individual exit address.

## Contents

 - [Prerequisites](#prerequisites)
 - [Preparing the image](#preparing-the-image)
 - [SBC (single board computer) Instructions](#sbc-single-board-computer-instructions)
 - [Accessing the device](#accessing-the-device)
 - [Quick installer](#quick-installer)
 - [Support us](#support-us)
 - [How to contribute](#how-to-contribute)
 - [License](#license)

## Prerequisites

Start with a fresh install of Debian on your system or server.

### SBC (single board computer) Instructions

Start with a clean install of [Armbian](https://www.armbian.com/) or [Raspbian](https://www.raspberrypi.org/downloads/raspbian/) (currently Buster and Stretch are verified as working). Lite versions are recommended. If using Raspbian Buster elevate to root with ```sudo su``` before running the Micro Exit installer script. For Armbian you will start already elevated to root on login so ```sudo su``` is not required.

For Orange Pi R1 use Armbian Buster found here: https://www.armbian.com/orange-pi-r1/. Recommend using "minimal" which is available for direct download at the bottom of the page or much faster download by .torrent also linked there.

For OrangePi Zero use Armbian Buster found here": https://www.armbian.com/orange-pi-zero/

To burn the image to an SD card on your PC you can use Etcher:
https://www.balena.io/etcher/

### Preparing the image

For Raspbian you will need to remove the SD card from the computer, reinsert it, open the boot directory up and create a new textfile file named `ssh` with no .txt file extension i.e. just `ssh` in order to remotely connect. This step is not required for Armbian.

Insert the SD card into the device and power it up.

### Accessing the device

Obtain a copy of Putty and install it on your PC:
https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html

1.  Log into your router from your PC and find the address it assigned to the Pi.

2.  Start Putty up and enter this obtained address into Putty with settings:

    Host Name Address = the address obtained from router | Port `22` | connection type `SSH` | then `OPEN`

    For Raspbian the default login is `pi` password `raspberry`
    For Armbian the default login is `root` password `1234`

3.  Follow any first user password instructions provided once logged in.

4. If you want to get the lastest updates before installing Micro Exit installer:
```
sudo apt-get update
sudo apt-get upgrade
sudo reboot
```
With the prerequisites done, you can now proceed with the Quick installer.

## Quick installer

Install SBC Lokinet Micro Exit from shell prompt:
```sh
$ wget -q https://git.io/J3dYg -O /tmp/microexit && bash /tmp/microexit
```

At the end of the install process you will be presented with your Lokinet address. Either by starting the exit by answer "Y" or exiting the script "N" it will allow you to highlight the address and copy/paste this to clipboard or plug it directly into your Lokinet client to test your exit.

## Support us

SBC Lokinet Micro Exit is free software, but powered by your support. If you find it beneficial or wish to contribute to inspire ongoing development your donations of any amount; be they even symbolic, are a show of approval and are greatly appreciated.

Oxen Donation Address:
```sh
LA8VDcoJgiv2bSiVqyaT6hJ67LXbnQGpf9Uk3zh9ikUKPJUWeYbgsd9gxQ5ptM2hQNSsCaRETQ3GM9FLDe7BGqcm4ve69bh
```
![](https://i.imgur.com/HGVuijh.jpg) ![](https://i.imgur.com/6dMgBVr.jpg) ![](https://i.imgur.com/gIhGB1X.jpg)

## How to contribute

1. File an issue in the repository, using the bug tracker, describing the
   contribution you'd like to make. This will help us to get you started on the
   right foot.
2. Fork the project in your account and create a new branch:
   `your-great-feature`.
3. Commit your changes in that branch.
4. Open a pull request, and reference the initial issue in the pull request
   message.

## License
See the [LICENSE](./LICENSE) file.
