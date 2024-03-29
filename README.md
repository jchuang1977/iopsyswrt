# OpenWRT build system

## How feeds work

The OpenWRT build system contains several core packages but can be
extended and modified by using feeds. Feeds are repositories that
contain package Makefiles, i.e. descriptions on where to find the
source code for a package and how to build an OpenWRT package from
it. Feeds are defined in feeds.conf file in TOPDIR.  The layout for
the dectmngr package is shown below. That is the feeds.conf contains a
reference to a feeds git repo and a commit, then in that feed the
dectmngr git repo and commit id is specified.

feeds.conf #commit -> feeds/intenopackages/dectmngr/Makefile #commit -> dectmngr.git

feeds.conf:
src-git-full intenopackages git@iopsys.inteno.se:inteno-packages.git^e0bb62451d8b2030d84191732b42a0d3064b1c5f

feeds/intenopackages/dectmngr/Makefile:
PKG_SOURCE_URL:=http://ihgsp.inteno.se/git/dectmngr.git
PKG_SOURCE_VERSION:=6ba403663bc9cfdb8f89fb34de367f0796d68552

While the OpenWRT build system supports branch names in feeds.conf, in
Iopsys we only use commit id:s. This ensures that we can always
recreate a build at a later date by checking out a specific commit in
the top level repository.

## Iopsys initialization

After cloning the repository the iop command needs to be initialized
to install the commands for this version of iopsys.

Running iop without arguments gives the following output:

```
./iop
Usage: iop <command> [<args>]


Avaliable commands:
   bootstrap                Initial command to run to install other commands
   setup_host               Install needed packets to host machine

```

As can be seen, there is only two command avaliable. First you need to
install everything needed to your host with.

```
./iop setup_host
```

This will only work on debian based distroes. ex ubuntu. not on
fedora.

After the host is setup openwrt build needs to be populated with
packages to build.  Run this to install more commands from feeds:

```
./iop bootstrap
```

When bootstrap completes you should have more commands avaliable (some
commands can differ for your version):

```
./iop
Usage: iop <command> [<args>]

Avaliable commands:
   bootstrap                Initial command to run to install other commands
   feeds_update             Update feeds to point to commit hashes from feeds.conf
   genconfig                Genereate configuration for board and customer
   genconfig_min            Genereate configuration for board and customer (manual)
   generate_tarballs        Generate tarballs for openstk
   setup_host               Install needed packages to host machine
   status                   Display the state of your working tree
   update_package           Publish changes to packages and feeds
```

Next, all feed repositories need to be cloned and packages
installed. This is handled by running:

```
iop feeds_update 
```

This clones all feed repositories into feeds/ and installs the
packages from those repositories into the build system by creating
symlinks in packages/feeds/. 

NOTE. iop bootstrap only needs to be run once to install the commands
above. After you have installed feeds_update, running that command
will update iop commands along with all other packages.

Now, generate a .config file for the board and customer you're
building for with

```
iop genconfig <board> <customer>
```

To summarize, to intialize the repository, run:


* git clone <iopsys>
* iop bootstrap
* iop feeds_update
* iop genconfig <board> <customer>


If it's the first time you're building an image on your host, you
should run:

```
iop setup_host 
```

to install the required packages on your
host machine. After that run:

```
make
```

alt: for parallel build. 

```
make download
make -j8
```

## Updating the repository

If you run git pull in the toplevel repository you will most probably
get changes that modify feeds.conf. Now your feeds.conf points to
newer commits then what is checked out in the feed repositories and
you need to update your feeds. Do this by running:

iop feeds_update

This will pull in the latest changes in the modified feed for you. To
summarize, to update your repository, run:

```
git pull
iop feeds_update
make
```

## Working with feeds

The build system will clone and checkout the packages in build_dir in
detached head state so before you can commit you need to checkout a
branch to work on. To prevent an invalid state where you update
feeds.conf with commits that are not pushed to the remote repository,
the script pushes the new commits to the remote repos. For this to
work the script needs to know what remote branches to push to. For
that reason, always make sure to check out remote tracking branches,
for example with git checkout -t origin/mybranch.

When you have created a new commit in the package repo in the build
directory this commit needs to be pushed to two places. First the
package makefile in the feed needs to be repointed to the new
commit. This in turn creates a new commit in the feed and feeds.conf
needs to be repointed to that commit.

First you need to set the EDITOR environmental variable to your
favorite editor. Ex:

```
export EDITOR=/usr/bin/emacs
```

You probably want to add this line to your .bashrc.

```
iop update_package
```

First, it will update the toplevel remote repository and abort if it
finds that you are not on the last commit on the branch you're working
on. If you get this complaint, just merge the remote branch into your
local branch. This step is kept manual to ensure that you know that
your repository changes.

If you are on the end of your branch the script continues and checks
if any git repo in the build differs from the commit in the package
makefile. If it finds a diff it first asks you what branch to make the
new commit on since you are in detached head state in the feed
repository. You probably want to select devel here. Once you have
selected a branch to update the script autogenerates a commit message
from the commits between the old and the new commit point of the
package. The same then happens for the commit on feeds.conf.

