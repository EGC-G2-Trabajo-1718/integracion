#!/usr/bin/env bash

function deploy_portal() {
    docker stop g2_"$1" && docker rm -v g2_"$1"
    cd ~/g2/repos

    if [ -d "$1" ]; then
        sudo rm -rf "$1"
    fi
    
    git clone https://github.com/EGC-G2-Trabajo-1718/portal-votaciones.git
    cd ~/g2/compilation/portal
    if [ -d "app" ]; then
        rm -rf app
    fi

    cp -r ~/g2/repos/"$1" app
    docker build --no-cache -t egc/portal .
    cd ~/g2
    docker-compose up -d "$1"
}


function deploy_autenticacion() {
    docker stop g2_"$1" && docker rm -v g2_"$1"
    cd ~/g2/repos
    if [ -d "$1" ]; then
        sudo rm -rf "$1"
    fi
    git clone https://github.com/EGC-G2-Trabajo-1718/autenticacion.git
    cd ~/g2
    docker-compose up -d "$1"
}


function deploy_censos() {
    docker stop g2_"$1" && docker rm -v g2_"$1"
    cd ~/g2/repos
    if [ -d "$1" ]; then
        sudo rm -rf "$1"
    fi
    git clone https://github.com/EGC-G2-Trabajo-1718/egc-censos.git adm_censos
    cd ~/g2
    docker-compose up -d "$1"
}


function deploy_votaciones() {
    docker stop g2_"$1" && docker rm -v g2_"$1"
    cd ~/g2/repos
    if [ -d "build" ]; then
        sudo rm -rf build/*
    fi
    mv ~/g2/tmp/ROOT.war build/.
    cd ~/g2
    docker-compose up -d "$1"
}


function deploy_almacen() {
    docker stop g2_"$1" && docker rm -v g2_"$1"
    cd ~/g2/repos

    if [ -d "almacen" ]; then
        sudo rm -rf almacen
    fi
    
    git clone https://github.com/EGC-G2-Trabajo-1718/almacenamiento.git almacen
    cd ~/g2/compilation/almacen
    if [ -d "app" ]; then
        rm -rf app
    fi

    cp -r ~/g2/repos/almacen app
    docker build --no-cache -t egc/almacen .
    cd ~/g2
    docker-compose up -d "$1"
}


function deploy_cabina() {
    docker stop g2_"$1" && docker rm -v g2_"$1"
    cd ~/g2/repos
    if [ -d "cabina" ]; then
        sudo rm -rf cabina
    fi
    git clone https://github.com/EGC-G2-Trabajo-1718/cabina-de-votacion.git cabina
    cd ~/g2
    docker-compose up -d "$1"
}


function deploy_telegram() {
    docker stop g2_"$1" && docker rm -v g2_"$1"
    cd ~/g2/repos
    if [ -d "telegram" ]; then
        sudo rm -rf telegram
    fi
    git clone https://github.com/EGC-G2-Trabajo-1718/Cabina-Telegram.git telegram
    cd ~/g2
    docker-compose up -d "$1"
}


function deploy_recuento() {
    docker stop g2_"$1" && docker rm -v g2_"$1"
    cd ~/g2/repos
    if [ -d "recuento" ]; then
        sudo rm -rf recuento
    fi
    git clone https://github.com/EGC-G2-Trabajo-1718/recuento-de-votos.git recuento
    cd ~/g2
    docker-compose up -d "$1"
}


function main() {
    case "$1" in
    "portal-votaciones")
        deploy_portal "$@";;
    "autenticacion")
        deploy_autenticacion "$@";;
    "adm_censos")
        deploy_censos "$@";;
    "adm_votaciones")
        deploy_votaciones "$@";;
    "almacen_votos")
        deploy_almacen "$@";;
    "cabina_votaciones")
        deploy_cabina "$@";;
    "cabina_votaciones_telegram")
        deploy_telegram "$@";;
    "recuento_votos")
        deploy_recuento "$@";;
    esac
}

set -e
main "$@"
