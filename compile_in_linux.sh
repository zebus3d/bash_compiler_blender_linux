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
# Compilandor de blender 2.80 con mantaflow 
# version 0.0 (probado en linux mint 19.1)
#############################################

# el directorio donde trabajaremos:
MAINDIR='$HOME/buildingBlender'
# TARGETBRANCH='master'
TARGETBRANCH='fluid-mantaflow'

if [ ! -d '$MAINDIR' ]; then
    mkdir -p $MAINDIR
else
    echo '$MAINDIR ya existe no se hace nada'
fi

# Dependencias basicas:
echo '######### DEPENDENCIAS BASICAS #########'
sudo apt install git build-essential cmake-gui

# comprobando si existen los directorios
# si no existen los creo:
echo '######### Creando directorios #########'
if [ ! -d '$MAINDIR/blender-git' ]; then
    mkdir $MAINDIR/blender-git
else
    echo '$MAINDIR/blender-git ya existe no se hace nada'
fi
if [ ! -d '$MAINDIR/2.80' ]; then
    mkdir $MAINDIR/2.80
else
    echo '$MAINDIR/2.80 ya existe no se hace nada'
fi
if [ ! -d '$MAINDIR/mantaflow' ]; then
    mkdir $MAINDIR/mantaflow
else
    echo '$MAINDIR/mantaflow ya existe no se hace nada'
fi


echo '######### clonando blender #########'
CHKVOIDDIR=$(find $MAINDIR/blender-git/blender -maxdepth 0 -empty -exec echo 'True' \;)
if [ '$CHKVOIDDIR' == 'True' ]; then
    cd $MAINDIR/blender-git 
    git clone https://git.blender.org/blender.git
    cd blender
    git submodule update --init --recursive
    git submodule foreach git checkout master
    git submodule foreach git pull --rebase origin master
else
    echo '$MAINDIR/blender-git ya tiene cosas dentro, no se clonara nada.'
fi

# actualizando el repo:
echo '######### actualizando el repo #########'
cd $MAINDIR/blender-git/blender
git checkout $TARGETBRANCH
make update

# dependencias de blender:
echo '######### instalando dependecias #########'
cd $MAINDIR/blender-git/
./blender/build_files/build_environment/install_deps.sh


echo 'cmake automatico o por gui? (Auto/gui)'
read ask
if [ ! -z '$ask' ] || [ '$ask' == 'gui' ] || [ '$ask' == 'Gui' ] || [ '$ask' == 'GUI' ]; then
    # configurar con gui:
    echo '######### configurando cmake con gui #########'
    
    if [ '$TARGETBRANCH' == 'fluid-mantaflow' ]; then
        cd $MAINDIR/mantaflow
    else
        cd $MAINDIR/2.80
    fi
    cmake-gui ../blender-git/blender
else
    # configurar sin gui:
    echo '######### configurando cmake #########'
    
    if [ '$TARGETBRANCH' == 'fluid-mantaflow' ]; then
        echo '######### entrando en $MAINDIR/mantaflow #########'
        cd $MAINDIR/mantaflow
    else
        echo '######### entrando en $MAINDIR/2.80 #########'
        cd $MAINDIR/2.80
    fi
    cmake ../blender-git/blender -WITH_STATIC_LIBS=ON -DWITH_CXX11=ON -DGUI=OFF -DWITH_FFTW3=ON -DWITH_MOD_OCEANSIM=ON -DWITH_ALEMBIC=ON -DWITH_INSTALL_PORTABLE=ON -DWITH_BUILDINFO=ON
fi

# compilando:
echo '######### compilando #########'

if [ '$TARGETBRANCH' == 'fluid-mantaflow' ]; then
    cd $MAINDIR/mantaflow
else
    cd $MAINDIR/blender-git/2.8
fi

make
make install

echo '######### abriendo blender #########'
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
#objdump -x path/to/blender | grep 'NEEDED'
