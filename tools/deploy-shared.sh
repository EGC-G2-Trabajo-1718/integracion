#!/bin/bash

. "/home/egc/scripts/integracion/tools/start.sh" --source-only

autenticacion="$HOME/repos/autenticacion"
adm_votaciones="$HOME/repos/adm_votaciones"
adm_censo="$HOME/repos/adm_censos"
cabina="$HOME/repos/cabina"
telegram="$HOME/repos/telegram"
almacen="$HOME/repos/almacen"
recuento="$HOME/repos/recuento"
flask="$HOME/repos/portal-votaciones"

subsistemas=($autenticacion $adm_votaciones $adm_censo $cabina $telegram $almacen $recuento $flask)

echo
echo "//////////////////////////"
echo "/Descarga de repositorios/"
echo "//////////////////////////"
echo

echo
echo "ADVERTENCIA: Este script asume que el repositorio de integración se encuentra en ~/scripts/integracion"
echo "ADVERTENCIA: Para algunas operaciones es necesario disponer de privilegios, introduce la contraseña cuando sea necesario"
echo

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

echo
echo "//////////////////////////"
echo "/Comprobaciones iniciales/"
echo "//////////////////////////"
echo

for subsistema in "${subsistemas[@]}"
do
        if [ ! -d "$subsistema" ]
        then
                echo "El directorio $subsistema no existe"
                echo "Ejecute el script de inicialización"
                echo "Saliendo"
                echo
                exit
        fi
done

echo
echo "///////////////////////"
echo "/Selecciona subsistema/"
echo "///////////////////////"
echo

echo "Introduce un número del 1 al 8"
echo "¿Qué subsistema eres?"
echo "1) Autenticación"
echo "2) Administración de votaciones"
echo "3) Administración de censos"
echo "4) Cabina de votaciones"
echo "5) Cabina de Telegram"
echo "6) Almacenamiento de votos"
echo "7) Recuento de votos"
echo "8) Visualización de resultados"
echo "*) No lo se"
read -r numSubsistema;
case $numSubsistema in
        1) echo "Has seleccionado Autenticación";;
        2) echo "Has seleccionado Administración de votaciones";;
        3) echo "Has seleccionado Administración de censos";;
        4) echo "Has seleccionado Cabina de votaciones";;
        5) echo "Has seleccionado Cabina de Telegra";;
        6) echo "Has seleccionado Almacenamiento de votos";;
        7) echo "Has seleccionado Recuento de votos";;
        8) echo "Has seleccionado Visualización de resultados";;
        *) exit
esac

echo
echo "/////////////////////////////"
echo "/Montando carpeta compartida/"
echo "/////////////////////////////"
echo
sudo mount -t vboxsf share ~/share/

echo
echo "///////////////////"
echo "/Copiando proyecto/"
echo "///////////////////"
echo

if [ "$(find ~/share ! -name . -prune -print | grep -c /)" -ne 1 ]
        then
                echo "En el directorio solo debe encontrarse la carpeta del proyecto"
                echo "Saliendo"
                echo
                exit
else
    case $numSubsistema in
            1) rm -rf "$autenticacion"/*
		    sudo cp -r ~/share/*/. "$autenticacion";;
            2) rm -rf "$adm_votaciones"/*
		    sudo cp -r ~/share/*/. "$adm_votaciones";;
            3) rm -rf "$adm_censo"/*
		    sudo cp -r ~/share/*/. "$adm_censo";;
            4) rm -rf "$cabina"/*
		    sudo cp -r ~/share/*/. "$cabina";;
            5) rm -rf "$telegram"/*
		    sudo cp -r ~/share/*/. "$telegram";;
            6) rm -rf "$almacen"/*
		    sudo cp -r ~/share/*/. "$almacen";;
            7) rm -rf "$recuento"/*
		    sudo cp -r ~/share/*/. "$recuento";;
            8) rm -rf "$flask"/*
		    sudo cp -r ~/share/*/. "$flask";;
    esac
fi

echo
echo "/////////////////////"
echo "/Desplegando modulos/"
echo "/////////////////////"
echo

echo "docker: Compilando/actualizando imágenes docker de algunos subsistemas"

compile_images

echo "mysql: Inicializando bases de datos"

deploy_dbs

echo "maven: Construyendo subsistemas maven"

mvn_compile

echo "Desplegando subsistemas restantes"

cd ~/docker

docker-compose up -d 

