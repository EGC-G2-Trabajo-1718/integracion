#!/usr/bin/env sh


BRANCH="none"
CHECKOUT_DST="none"


function clone_repos() {
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


fucntion checkout_repos() {
    if [ "$CHECKOUT_DST" == "master" ]; then
        cd ~/repos/portal-votaciones
        git checkout master
        cd ~/repos/autenticacion
        git checkout master
        cd ~/repos/adm_censos
        git checkout master
        cd ~/repos/adm_votaciones
        git checkout master
        cd ~/repos/almacen
        git checkout master
        cd ~/repos/cabina
        git checkout master
        cd ~/repos/telegram
        git checkout master
        cd ~/repos/recuento
        git checkout master
        cd ~/repos
        mv .dev .master
        update_repos

    else [ "$CHECKOUT_DST" == "dev" ]; then
        cd ~/repos/portal-votaciones
        git checkout dev
        cd ~/repos/autenticacion
        git checkout dev
        cd ~/repos/adm_censos
        git checkout development
        cd ~/repos/adm_votaciones
        git checkout development
        cd ~/repos/almacen
        git checkout master
        cd ~/repos/cabina
        git checkout dev
        cd ~/repos/telegram
        git checkout Dev
        cd ~/repos/recuento
        git checkout master
        cd ~/repos
        mv .master .dev
        update_repos
}


function update_branch() {
    cd ~/repos
    if [ "$BRANCH" == "master" ]; then
        if [ -a ".master" ]; then
            pull_repos()
        else
            CHECKOUT_DST="dev"
            checkout_repos
        fi
    else
        if [ -a ".master" ]; then
            CHECKOUT_DST="master"
            checkout_repos
        else
            pull_repos()
        fi
    fi
}


function update_repos() {
    cd ~/repos/portal-votaciones
    git pull
    cd ~/repos/autenticacion
    git pull
    cd ~/repos/adm_censos
    git pull
    cd ~/repos/adm_votaciones
    git pull
    cd ~/repos/almacen
    git pull
    cd ~/repos/cabina
    git pull
    cd ~/repos/telegram
    git pull
    cd ~/repos/recuento
    git pull
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
    cd ~/scripts/integracion/dockerfiles/django
    docker rmi egc/django2
    docker rmi egc/django3

    docker build -t egc/django2 -f django2
    docker build -t egc/django3 -f django3

    cd ~/scripts/integracion/dockerfiles/flask
    docker rmi egc/flask
    cp ~/repos/portal-votaciones/requirements.txt .
    docker build -t egc/flask .

    cd ~/scripts/integracion/dockerfiles/maven
    docker rmi egc/maven
    docker build -t egc/maven . 

    cd ~/scripts/integracion/dockerfiles/mysql
    docker rmi egc/mysql
    docker build -t egc/mysql .

    cd ~/scripts/integracion/dockerfiles/node
    docker rmi egc/node
    docker build -t egc/node .

    cd ~/scripts/integracion/dockerfiles/flask
    cp ~/repos/almacen/requirements.txt .
    docker build -t egc/almacen .
}


function mvn_compile() {
    cd ~/repos
    if [ -d "mvn" ]; then
        rm -rf mvn/*
    else
        mkdir mvn
    fi

    if [ -d "build"]; then
        rm -rf build/*
    else
        mkdir build
    fi

    cp -r adm_votaciones/* mvn/.
    docker run --rm -v /home/egc/mvn:/usr/src/mymaven -w /usr/src/mymaven maven:3-jdk-8 mvn clean install package -DskipTests=true
    mv ~/mvn/*.war build/ROOT.war
}


function deploy_dbs() {
    cd ~/scripts/integracion/docker
    docker-compose up -d mysql-wordpress mysql-voting
    echo "Finalizando inicialización..."
    sleep 15
    echo "Inicialización terminada"
}


echo "ADVERTENCIA: Este script asume que el repositorio de integración se encuentra en ~/scripts/integracion"

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

echo "git: Descargando/Actualizando repositorios de los subsistemas"

if [ -d "~/repos" ]; then
    update_branch
else
    clone_repos
fi

echo "docker: Compilando/actualizando imágenes docker de algunos subsistemas"

compile_images

echo "mysql: Inicializando bases de datos"

deploy_dbs

echo "maven: Construyendo subsistemas maven"

mvn_compile

echo "Desplegando subsistemas restantes"

cd ~/scripts/integracion/docker

docker-compose up -d 
