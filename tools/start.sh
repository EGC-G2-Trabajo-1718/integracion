#!/usr/bin/env bash


BRANCH="none"
CHECKOUT_DST="none"


function clone_repos() {
    mkdir ~/repos
    cd ~/repos
    if [ "$BRANCH" == "master" ]; then
        git clone https://github.com/EGC-G2-Trabajo-1718/portal-votaciones.git
        git clone https://github.com/EGC-G2-Trabajo-1718/autenticacion.git
        git clone https://github.com/EGC-G2-Trabajo-1718/egc-censos.git adm_censos
        git clone https://github.com/EGC-G2-Trabajo-1718/AdministracionVotaciones.git adm_votaciones
        git clone https://github.com/EGC-G2-Trabajo-1718/almacenamiento.git almacen
        git clone https://github.com/EGC-G2-Trabajo-1718/cabina-de-votacion.git cabina
        git clone https://github.com/EGC-G2-Trabajo-1718/Cabina-Telegram.git telegram
        git clone https://github.com/EGC-G2-Trabajo-1718/recuento-de-votos.git recuento
        touch .master
    else
        git clone https://github.com/EGC-G2-Trabajo-1718/portal-votaciones.git -b dev
        git clone https://github.com/EGC-G2-Trabajo-1718/autenticacion.git -b dev
        git clone https://github.com/EGC-G2-Trabajo-1718/egc-censos.git -b development adm_censos
        git clone https://github.com/EGC-G2-Trabajo-1718/AdministracionVotaciones.git -b development adm_votaciones
        git clone https://github.com/EGC-G2-Trabajo-1718/almacenamiento.git almacen
        git clone https://github.com/EGC-G2-Trabajo-1718/cabina-de-votacion.git -b dev cabina
        git clone https://github.com/EGC-G2-Trabajo-1718/Cabina-Telegram.git -b Dev telegram
        git clone https://github.com/EGC-G2-Trabajo-1718/recuento-de-votos.git recuento
        touch .dev
    fi
}


function choose_branch() {
    echo "Escriba el nombre de la rama deseada"
    echo "Para salir pulse CTRL + C"
    read -p "Elige una rama: (master | dev): " BRANCH
    if [ "$BRANCH" != "master" ] && [ "$BRANCH" != "dev" ]; then
        echo "Nombre incorrecto"
    fi
}


function compile_images() {
    # Working dir for this phase is ~/compilation

    # Remove previous images, and compile them with new sources

    if [ -d "~/compilation" ]; then
        rm -rf ~/compilation
    fi

    mkdir ~/compilation
    cp -r ~/scripts/integracion/docker/dockerfiles/* ~/compilation/.

    cd ~/compilation/django

    docker rmi egc/django2
    docker rmi egc/django3

    mv django2 Dockerfile
    docker build -t egc/django2 .

    mv django3 Dockerfile
    docker build -t egc/django3 .

    # Flask apps must have main.py and prestart.sh files in root folder

    cd ~/compilation/flask

    docker rmi egc/portal
    docker rmi egc/almacen

    cp -r ~/repos/portal-votaciones/ app
    docker build --no-cache -t egc/portal .

    rm -rf app

    cp -r ~/repos/almacen/ app

    docker build --no-cache -t egc/almacen .

    cd ~/compilation/mysql
    docker rmi egc/mysql
    docker build -t egc/mysql .

    cd ~/compilation/node
    docker rmi egc/node
    docker build -t egc/node .

    cd ~/compilation/tomcat
    docker rmi egc/tomcat
    docker build -t egc/tomcat .
}


function mvn_compile() {
    cd ~/repos
    if [ -d "mvn" ]; then
        rm -rf mvn/*
    else
        mkdir mvn
    fi

    if [ -d "build" ]; then
        rm -rf build/*
    else
        mkdir build
    fi

    cp -r adm_votaciones/* mvn/.
    docker run --rm -v /home/egc/repos/mvn:/usr/src/mymaven -w /usr/src/mymaven maven:3-jdk-8 mvn clean install package -DskipTests=true
    sudo mv ~/repos/mvn/target/*.war ~/repos/build/ROOT.war
}


function deploy_dbs() {
    if [ -d "/home/egc/docker" ]; then
        rm -rf ~/docker/
    fi
    mkdir ~/docker
    cp -r ~/scripts/integracion/docker ~/
    cd ~/docker
    sed -i 's/chosen_user/variability/g' .env
    sed -i 's/chosen_pass1/4dm_j0rn4d4s/g' .env
    sed -i 's/chosen_pass2/variability_is_strong_in_you/g' .env
    sed -i 's/db_name/jornadas/g' .env
    echo .env
    docker-compose up -d mysql-wordpress mysql-voting
    echo "Finalizando inicialización de las BDs..."
    sleep 15
    echo "Inicialización terminada"
}


echo "ADVERTENCIA: Este script asume que el repositorio de integración se encuentra en ~/scripts/integracion"
echo "ADVERTENCIA: Para algunas operaciones es necesario disponer de privilegios, introduce la contraseña cuando sea necesario"

while [ "$BRANCH" != "master" ] && [ "$BRANCH" != "dev" ]; do
    choose_branch
done

echo "docker: Parando todos los contenedores"

docker stop $(docker ps -q)

echo "docker: Eliminando contenedores"

docker rm -v $(docker ps -a -q)

echo "git: Actualizando repositorio de integración"

cd ~/scripts/integracion/

git pull

echo "git: Descargando repositorios de los subsistemas"

if [ -d "/home/egc/repos" ]; then
    echo "Se necesitan permisos administrativos para eliminar algunos ficheros de los repositorios"
    sudo rm -rf ~/repos
fi

clone_repos

echo "docker: Compilando/actualizando imágenes docker de algunos subsistemas"

compile_images

echo "mysql: Inicializando bases de datos"

deploy_dbs

echo "maven: Construyendo subsistemas maven"

mvn_compile

echo "Desplegando subsistemas restantes"

cd ~/docker

docker-compose up -d 
