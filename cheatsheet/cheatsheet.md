# ASP.NET Core on Linux Cheat Sheet

This stuff is hard enough without having to remember it all. If you follow these instructions, you'll be up in no time.

Well, not no time, but pretty quickly. 

Let's get started.

## Install Ubuntu

These instructions assume you're installing Ubunu 18.04 "Bionic Beaver".

Start by [downloading Ubuntu](https://www.ubuntu.com/download). In the talk, I used the
desktop version, but there's no reason you can't use the server version.

Open Hyper-V and create a new VM using the ISO file you just downloaded. Make sure you choose
"Generation 2" when prompted to "Choose the generation for the new virtual machine". Choose
at least 2GB of RAM. The default settings for disk space are fine.

There's no reason you can't use another hypervisor like VMWare Workstation or VirtualBox for
this. I use Hyper-V because I'm already using it for Docker and Android Emulation.

If you're using Hyper-V, you need to disable secure boot on the VM before you start it to
begin the installation:

```powershell
Set-VMFirmware -vmname "the name of your VM" -EnableSecureBoot off
```
Once Ubuntu is installed, and you reboot, set up your credentials, etc., the next
step is to...

## Open a Terminal

And keep it open. We're going to live there for a while.

## Install SSH

Install the SSH server by typing:

```bash
sudo apt install openssh-server
```

It's possible you may see an error message related to `/var/lib/dpkg/lock`. This is normal
after a fresh installation. Wait a little bit and try again. The message will eventually
go away.

There are many config options for SSH, but for our purposes, the defaults are all
fine. They'll allow us to connect with PuTTY or WinSCP.

## Test SSH

Make sure you can connect to your VM using PuTTY or WinSCP. Start by installing net tools
so that you can actually get your IP address.

```bash
sudo apt install net-tools
```

Then type

```bash
ifconfig eth0
```

You should see output like this:

```
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.181.98  netmask 255.255.255.240  broadcast 192.168.181.111
        inet6 fe80::1741:f0c9:7b9d:ab0f  prefixlen 64  scopeid 0x20<link>
        ether 00:15:5d:34:11:19  txqueuelen 1000  (Ethernet)
        RX packets 108426  bytes 152741363 (152.7 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 40892  bytes 2811294 (2.8 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

Get your IP address. Then switch back to Windows and use PuTTY or WinSCP to try to connect
to that IP address.

## Install the .NET Core 2.1 SDK

Microsoft's [official instructions](https://www.microsoft.com/net/download/linux-package-manager/ubuntu18-04/sdk-current) for this.

Here's the short, short version. Run the following commands:

```bash
cd ~/
wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get install apt-transport-https
sudo apt-get update
sudo apt-get install dotnet-sdk-2.1
```

## Clone this repository and verify you can run the example

Clone this repository, which contains the ASP.NET app we're going to be working with.

```bash
git clone https://github.com/bslatner/idontknowcrapaboutlinux.git
```