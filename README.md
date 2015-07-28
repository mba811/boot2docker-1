# boot2docker Vagrant Box for Parallels

This Vagrant box provides an alternative to the official
[Boot2Docker](https://github.com/boot2docker/boot2docker) setup,
to easily use [Docker](https://www.docker.com/) on Mac OS X.

It is built for Parallels and makes use of
[NFS](http://en.wikipedia.org/wiki/Network_File_System),
which provides much better
[filesystem performance in virtual machines](
  http://mitchellh.com/comparing-filesystem-performance-in-virtual-machines)
than VirtualBox shared folders, which are used by the official setup.

## Requirements

Before starting the setup process, install the following software:

  * [Docker](https://docs.docker.com/installation/mac/) v1.6.2+
  * [Vagrant](https://www.vagrantup.com/) v1.7.2+
  * [Parallels Desktop](http://www.parallels.com/products/desktop/) v10.1.4+

The easiest way to install **Docker** and **Vagrant** is via
[Homebrew](http://brew.sh/):

```sh
brew install \
  docker \
  caskroom/cask/brew-cask

brew cask install \
  vagrant
```

## Setup

Execute the following commands to set up and start the vagrant box and to
load the docker host environment variables into the current shell session:

```sh
vagrant plugin install \
    vagrant-parallels \
    vagrant-triggers

vagrant init blueimp/boot2docker
vagrant up --provider parallels

source .env
```

Now the docker client is bound to the docker daemon running in the
vagrant box:

```sh
docker info && echo "Docker Host IP: $DOCKER_HOST_IP"
```

The
[hostnames.sh](https://github.com/blueimp/docker/blob/1.4.0/bin/hostnames.sh)
shell script can be used to update `/etc/hosts`
with hostname entries for the docker host IP.

To load the docker host environment variables automatically for each terminal
session and to provide `b2d` as `vagrant` alias with the boot2docker home as
working directory, execute the following commands:

```sh
printf "export B2D_HOME=%q\n" "$PWD" >> ~/.profile
echo '[[ -e "$B2D_HOME/.env" ]] && source "$B2D_HOME/.env"' >> ~/.profile
echo 'alias b2d="VAGRANT_CWD=\"\$B2D_HOME\" vagrant"' >> ~/.profile
source ~/.profile
```

Now the docker host machine can be accessed by running `b2d` from any
directory:

```sh
b2d ssh
```

## Build

If you want to build the vagrant box yourself, install the following
additional requirements:

  * [Packer](http://www.packer.io) v0.7.5+
  * [Parallels Virtualization SDK](
    http://www.parallels.com/products/desktop/download/) v10.1.4+

**Packer** can also be installed via [Homebrew](http://brew.sh/):

```sh
brew install \
  packer
```

Next you can run the following commands, to build the box and add it to the
local vagrant repository:

```sh
make
vagrant box add --name blueimp/boot2docker boot2docker.box
make clean
```

## License

Released under the [MIT license](http://www.opensource.org/licenses/MIT).

## Author

[Sebastian Tschan](https://blueimp.net/)

## Credits

Based on
[wearableintelligence/boot2docker-vagrant-box](
  https://github.com/wearableintelligence/boot2docker-vagrant-box).
