#############################################
# Compilandor de blender 2.80 con mantaflow 
# version 0.0 (probado en linux mint 19.1)
#############################################

# el directorio donde trabajaremos:
MAINDIR="/home/zebus3d/buildingBlender"

if [ ! -d "$MAINDIR" ]; then
    mkdir -p $MAINDIR
else
    echo "$MAINDIR ya existe no se creara"
fi

# Dependencias basicas:
echo "### DEPENDENCIAS BASICAS ###"
sudo apt install git build-essential cmake-gui

# comprobando si existen los directorios
# si no existen los creo:
echo "### Creando directorios ###"
if [ ! -d "$MAINDIR/blender-git" ]; then
    mkdir $MAINDIR/blender-git
else
    echo "$MAINDIR/blender-git ya existe no se creara"
fi
if [ ! -d "$MAINDIR/2.80" ]; then
    mkdir $MAINDIR/2.80
else
    echo "$MAINDIR/2.80 ya existe no se creara"
fi
if [ ! -d "$MAINDIR/mantaflow" ]; then
    mkdir $MAINDIR/mantaflow
else
    echo "$MAINDIR/mantaflow ya existe no se creara"
fi


echo "### clonando blender ##"
CHKVOIDDIR=$(find $MAINDIR/blender-git/blender -maxdepth 0 -empty -exec echo "True" \;)
if [ "$CHKVOIDDIR" == "True" ]; then
    cd $MAINDIR/blender-git 
    git clone https://git.blender.org/blender.git
    cd blender
    git submodule update --init --recursive
    git submodule foreach git checkout master
    git submodule foreach git pull --rebase origin master
else
    echo "$MAINDIR/blender-git ya tiene cosas dentro, no se clonara nada."
fi

# actualizando el repo:
echo "### actualizando el repo ###"
cd $MAINDIR/blender-git/blender
#make update
# usaremos mantaflow:
git checkout fluid-mantaflow
make update

# dependencias de blender:
echo "### instalando dependecias ###"
cd $MAINDIR/blender-git/
./blender/build_files/build_environment/install_deps.sh


echo "cmake automatico o por gui?"
read ask
if [[ "$ask" == "gui" ]]; then
    # configurar con gui:
    echo "### configurando cmake con gui ###"
    cd $MAINDIR/mantaflow
    cmake-gui ../blender
else
    # configurar sin gui:
    echo "### configurando cmake ###"
    cd $MAINDIR/mantaflow
    cmake ../blender -WITH_STATIC_LIBS=ON -DWITH_CXX11=ON -DGUI=OFF -DWITH_FFTW3=ON -DWITH_MOD_OCEANSIM=ON -DWITH_ALEMBIC=ON -DWITH_INSTALL_PORTABLE=ON -DWITH_BUILDINFO=ON
fi

# compilando:
echo "### compilando ###"
cd $MAINDIR/blender-git/build
make
make install




# para futuras veces:
#cd $MAINDIR/blender-git/blender
#git checkout fluid-mantaflow
#git pull --rebase
#git submodule foreach git pull --rebase origin fluid-mantaflow
#cd $MAINDIR/blender-git/build
#make
#make install


# conocer las librerias necesarias para compartir la build:
#objdump -x path/to/blender | grep "NEEDED"
