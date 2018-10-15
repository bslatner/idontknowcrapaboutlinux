# ASP.NET Core on Linux Cheat Sheet

This stuff is hard enough without having to remember it all. If you follow these instructions, you'll be up in no time.

Well, not no time, but pretty quickly. 

Let's get started.

## Install Ubuntu

These instructions assume you're installing Ubuntu 18.04 "Bionic Beaver".

Start by [downloading Ubuntu](https://www.ubuntu.com/download). In the talk, I used the
desktop version, but there's no reason you can't use the server version. It might even
be a better choice, especially if you want to focus on CLI stuff.

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

NOTE: When installing on a UEFI system these [UEFI Tips](https://help.ubuntu.com/community/UEFI) might come in handy.

Once Ubuntu is installed, and you reboot, set up your credentials, etc., the next
step is to...

## Open a Terminal

And keep it open. We're going to live there for a while. Terminal is life.

## Install SSH

Install the SSH server by typing:

```bash
sudo apt install openssh-server
```

It's possible you may see an error message related to `/var/lib/dpkg/lock`. This is normal
after a fresh installation. Wait a little bit and try again. The message will eventually
go away; it means some Ubuntu maintenance processes are using the package database.

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

NOTE: You may also use these commands to get your interfaces' addresses.

```bash
ip addr
```

Write down your IP address. Then switch back to Windows and use PuTTY or WinSCP to try to connect
to that IP address.


## Install git

Install git by typing:

```bash
sudo apt install git
```

NOTE: If you get tired of being asked "Yes/No", you can add the '-y' switch to apt arguments.

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

*NOTE*: All instructions from here on out assume that this repo has been cloned to
the default location of `~/idontknowcrapaboutlinux`.

Now you should be able to run the example.

```bash
cd ~/idontknowcrapaboutlinux/src/AspNetCoreExample
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
nginx config file. Type:

```bash
cp ~/idontknowcrapaboutlinux/cheatsheet/nginx-config /etc/nginx/sites-available/default
sudo service nginx reload
```

The configuration we've loaded tells nginx to redirect port 80 (regular HTTP traffic) 
to localhost:37230, which is the port we expose with docker.

## Run our docker app as a service

This project contains a file called `helloworld-docker.service`. We want to register
that with `systemctl`. Copy that into the list of services like so:

```bash
cp ~/idontknowcrapaboutlinux/cheatsheet/helloworld-docker.service /etc/systemd/system
```

Enable the service:

```bash
sudo systemctl enable helloworld-docker.service
```

Before we start the service up, we have to build it. This project includes a simple script to do that. To run it:

```bash
cd ~/idontknowcrapaboutlinux/cheatsheet
chmod +x *.sh
./copy-helloworld-docker.sh
```

The above *builds* but does not *run* the docker-compose app we used earlier. It copies
the .yml files that docker-compose needs to `/var/aspnetcore/helloworld-docker`, which
is where the service we created expects to find them.

Now let's start the service and verify that it's running:

```bash
sudo systemctl start helloworld-docker.service
sudo systemctl status helloworld-docker.service
```

Once the service is running, you should be able to browse from your Windows machine to
port 80 on the virtual machine. We're almost done!

Final steps:

* Edit `C:\Windows\System32\drivers\etc\hosts` and add a mapping for www.contoso.com to your VM's IP address (see above where we used `ifconfig` to get it)
* Open your browser and browse to `http://www.contoso.com`
* If all goes well, you should see the example app in your browser.

## The End

Really. It is.

