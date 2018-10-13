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

## Install git

Install git by typing:

```bash
sudo apt install git
```

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

Now you should be able to run the example.

```bash
cd idontknowcrapaboutlinux/src/AspNetCoreExample
dotnet run
```

If all goes well, you should be able to open Firefox *on the virtual machine's desktop*
and browse to `http://localhost:5000`.

Press Ctrl+C to terminate the demo.

## Install docker and docker-compose

Ultimately, we want to run our code in a container. We need docker for that. 

You can find thorough instructions for this at [https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04) but we're just going to hit the highlights here.

To install, type:

```bash
apt install docker
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
apt-cache policy docker-ce
sudo apt install docker-ce
sudo apt install docker-compose
sudo usermod -aG docker ${USER}
```

We need to log out and back in again to make sure the permission change in the last
line above takes effect. So, log out, log back in, then test the containerized version of our app:

```bash
cd ~/idontknowcrapaboutlinux
docker-compose up
```

If all goes well, you should be able to open Firefox *on the virtual machine's desktop*
and browse to `http://localhost:5000`.

## Install and configure nginx

Install the nginx server:

```bash
sudo apt install nginx
```

This project contains a file `nginx-config`. Copy it over top of the default
nginx config file. Assuming you've cloned this repo to `~/idontknowcrapaboutlinux`,
you would type

```bash
cp ~/idontknowcrapaboutlinux/cheatsheet/nginx-config /etc/nginx/sites-available/default
sudo service nginx reload
```

The configuration we've loaded tells nginx to redirect port 80 (regular HTTP traffic) 
to localhost:37230, which is the port we expose with docker.

## Run our docker app as a service

This project contains 