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
# version 0.0 (tested in linux mint 19.1)
#############################################

# work directory:
MAINDIR="$HOME/buildingBlender"
# TARGETBRANCH="master"
TARGETBRANCH="fluid-mantaflow"

if [ ! -d "$MAINDIR" ]; then
    mkdir -p $MAINDIR
else
    echo "$MAINDIR it already exists, nothing is done"
fi

# Dependencias basicas:
echo -e "\n######### Basic Dependencies #########"
sudo apt install git build-essential cmake-gui

# comprobando si existen los directorios
# si no existen los creo:
echo -e "\n######### Creating directories #########"
if [ ! -d "$MAINDIR/blender-git" ]; then
    mkdir $MAINDIR/blender-git
else
    echo "$MAINDIR/blender-git it already exists, nothing is done"
fi
if [ ! -d "$MAINDIR/2.80" ]; then
    mkdir $MAINDIR/2.80
else
    echo "$MAINDIR/2.80 it already exists, nothing is done"
fi
if [ ! -d "$MAINDIR/mantaflow" ]; then
    mkdir $MAINDIR/mantaflow
else
    echo "$MAINDIR/mantaflow it already exists, nothing is done"
fi


echo -e "\n######### Blender Cloning #########"
CHKVOIDDIR=$(find $MAINDIR/blender-git/blender -maxdepth 0 -empty -exec echo "True" \;)
if [ "$CHKVOIDDIR" == "True" ]; then
    cd $MAINDIR/blender-git 
    git clone https://git.blender.org/blender.git
    cd blender
    git submodule update --init --recursive
    git submodule foreach git checkout master
    git submodule foreach git pull --rebase origin master
else
    echo "$MAINDIR/blender-git It's already got stuff in it, it won't clone anything.."
fi

# actualizando el repo:
echo -e "\n######### Updating The Repo #########"
cd $MAINDIR/blender-git/blender
git checkout $TARGETBRANCH
make update

# dependencias de blender:
echo -e "\n######### Installing Dependencies #########"
cd $MAINDIR/blender-git/
./blender/build_files/build_environment/install_deps.sh


echo "Automatic cmake or gui? (Auto/gui)"
read ask
if [ ! -z "$ask" ] || [ "$ask" == "gui" ] || [ "$ask" == "Gui" ] || [ "$ask" == "GUI" ]; then
    # configurar con gui:
    echo -e "\n######### Configuring cmake with gui #########"
    
    if [ "$TARGETBRANCH" == "fluid-mantaflow" ]; then
        cd $MAINDIR/mantaflow
    else
        cd $MAINDIR/2.80
    fi
    cmake-gui ../blender-git/blender
else
    # configurar sin gui:
    echo -e "\n######### Configuring cmake #########"
    
    if [ "$TARGETBRANCH" == "fluid-mantaflow" ]; then
        echo -e "\n######### entering into $MAINDIR/mantaflow #########"
        cd $MAINDIR/mantaflow
    else
        echo -e "\n######### entering into $MAINDIR/2.80 #########"
        cd $MAINDIR/2.80
    fi
    cmake ../blender-git/blender -WITH_STATIC_LIBS=ON -DWITH_CXX11=ON -DGUI=OFF -DWITH_FFTW3=ON -DWITH_MOD_OCEANSIM=ON -DWITH_ALEMBIC=ON -DWITH_INSTALL_PORTABLE=ON -DWITH_BUILDINFO=ON
fi

# compilando:
echo -e "\n######### Compiling #########"

if [ "$TARGETBRANCH" == "fluid-mantaflow" ]; then
    cd $MAINDIR/mantaflow
else
    cd $MAINDIR/2.8
fi

make
make install

echo -e "\n######### Opening Blender #########"
./bin/blender

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
