# ##### BEGIN GPL LICENSE BLOCK #####
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 2
#  of the License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software Foundation,
#  Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#
# ##### END GPL LICENSE BLOCK #####

#############################################
# Compiler Blender 2.80 with/without mantaflow 
# version 0.1 (tested in linux mint 19.1)
#############################################

# work directory:
MAINDIR="$HOME/buildingBlender"
# TARGETBRANCH="master"
TARGETBRANCH="fluid-mantaflow"
# TARGETBRANCH="fracture_modifier"
# TARGETBRANCH="fracture_modifier-master"

if [ ! -d "$MAINDIR" ]; then
    echo "creating the $MAINDIR directory"
    mkdir -p $MAINDIR
else
    echo "$MAINDIR it already exists, nothing is done"
fi

echo -e "\n######### Basic Dependencies #########"
sudo apt install git build-essential cmake-qt-gui

echo -e "\n######### Blender Cloning #########"
if [ ! -d "$MAINDIR/blender-git" ]; then
    cd $MAINDIR
    mkdir blender-git
    cd blender-git
    git clone https://git.blender.org/blender.git
    cd blender
    git submodule update --init --recursive
    git submodule foreach git checkout master
    git submodule foreach git pull --rebase origin master
else
    echo "$MAINDIR/blender-git It is already cloned, nothing is done."
fi


echo -e "\n######### Creating directories #########"
if [ ! -d "$MAINDIR/blender-git/master" ]; then
    mkdir $MAINDIR/blender-git/master
else
    echo "$MAINDIR/blender-git/master it already exists, nothing is done"
fi
if [ ! -d "$MAINDIR/blender-git/fluid-mantaflow" ]; then
    mkdir $MAINDIR/blender-git/fluid-mantaflow
else
    echo "$MAINDIR/blender-git/fluid-mantaflow it already exists, nothing is done"
fi

# actualizando el repo:
echo -e "\n######### Updating The Repo #########"
cd $MAINDIR/blender-git/blender
git checkout $TARGETBRANCH
make update

#echo -e "\n######### Installing Dependencies #########"

# Scorpion81 say: 
# install_deps.sp install a mashup of distro libs and selfcompiled ones... usually dynamically linked.
# make deps might be a better option for linux, in case you wanna have static libs and a shareable build... 
# given your libc is not too new for the target system (e.g 
# ubuntu 18.04 / mint 19.1 has glibc 2.27, wont likely run on systems with older glibc )

#cd $MAINDIR/blender-git/
#./blender/build_files/build_environment/install_deps.sh


echo -e "\n######### make deps #########"
cd $MAINDIR/blender-git/blender
make clean 
make deps 


echo -e "\nAutomatic cmake or gui? (Auto/gui)"
read ask

if [ "$TARGETBRANCH" == "fluid-mantaflow" ]; then
    echo -e "\n######### entering into $MAINDIR/blender-git/fluid-mantaflow #########"
    cd $MAINDIR/blender-git/fluid-mantaflow
else
    echo -e "\n######### entering into $MAINDIR/blender-git/master #########"
    cd $MAINDIR/blender-git/master
fi

if [ ! -z "$ask" ] || [ "$ask" == "gui" ] || [ "$ask" == "Gui" ] || [ "$ask" == "GUI" ]; then
    echo -e "\n######### Configuring cmake with gui #########"
    cmake-gui ../blender
else
    echo -e "\n######### Configuring cmake #########"
    # cmake -D WITH_CXX11=ON -D GUI=OFF -D WITH_FFTW3=ON -D WITH_MOD_OCEANSIM=ON -D WITH_ALEMBIC=ON ../blender 
    # cmake -WITH_STATIC_LIBS=ON -D WITH_CXX11=ON -D GUI=OFF -D WITH_FFTW3=ON -D WITH_MOD_OCEANSIM=ON -D WITH_ALEMBIC=ON ../blender
    cmake -WITH_STATIC_LIBS=ON -D WITH_CXX11=ON -D GUI=OFF -D WITH_FFTW3=ON -D WITH_MOD_OCEANSIM=ON -D WITH_ALEMBIC=ON -D WITH_INSTALL_PORTABLE=ON -D WITH_BUILDINFO=ON ../blender 
fi

echo -e "\n######### Compiling in $(pwd) #########"

if [ "$TARGETBRANCH" == "fluid-mantaflow" ]; then
    echo -e "\n######### entering into $MAINDIR/fluid-mantaflow #########"
    cd $MAINDIR/blender-git/fluid-mantaflow
else
    echo -e "\n######### entering into $MAINDIR/master #########"
    cd $MAINDIR/blender-git/master
fi

make -j3 &&
make install -j3 &&

if [ -f "bin/blender" ]; then
    echo -e "\n######### Opening Blender $(pwd) #########"
    ./bin/blender
fi

# para futuras veces:
#cd $MAINDIR/blender-git/blender
#git checkout $TARGETBRANCH
#git pull --rebase
#git submodule foreach git pull --rebase origin $TARGETBRANCH
#cd $MAINDIR/blender-git/build
#make
#make install


# conocer las librerias necesarias para compartir la build:
#objdump -x path/to/blender | grep "NEEDED"
