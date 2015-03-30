# boot2docker Vagrant Box for Parallels

This Vagrant box provides an alternative to the official [boot2docker](http://boot2docker.io/) setup, to easily use [docker](https://www.docker.com/) on Mac OS X.

It is built for Parallels and makes use of [NFS](http://en.wikipedia.org/wiki/Network_File_System), which provides much better [filesystem performance in virtual machines](http://mitchellh.com/comparing-filesystem-performance-in-virtual-machines) than VirtualBox shared folders, which are used by the official setup.

## Setup

### Setup requirements

  * [Parallels Desktop](http://www.parallels.com/products/desktop/) v10.1.4+
  * [Vagrant](https://www.vagrantup.com/) v1.7.2+

### Setup commands

```sh
vagrant plugin install \
    vagrant-parallels \
    vagrant-triggers

vagrant init blueimp/boot2docker
vagrant up --provider parallels

source .env
```

## Shell helpers

Set docker environment variables automatically for each terminal session:

```sh
echo "if [ -e '$PWD/.env' ]; then source '$PWD/.env'; fi" >> ~/.profile
```

Set `b2d` as `vagrant` alias with the boot2docker working directory:

```sh
echo "alias b2d='VAGRANT_CWD=\"$PWD\" vagrant'" >> ~/.profile
```

## Build

### Build requirements

  * [Parallels Virtualization SDK](http://www.parallels.com/products/desktop/download/) v10.1.4+
  * [Packer](http://www.packer.io) v0.7.5+

### Build commands

```sh
make
vagrant box add --name blueimp/boot2docker boot2docker.box
make clean
```

## License

Released under the [MIT license](http://www.opensource.org/licenses/MIT).

## Credits

Based on [wearableintelligence/boot2docker-vagrant-box](https://github.com/wearableintelligence/boot2docker-vagrant-box).
