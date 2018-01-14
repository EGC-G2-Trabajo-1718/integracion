#!/usr/bin/env bash

function deploy_programa() {
    cd ~/g2/wordpress/repo-plugins/"$1"
    git pull
    rm -r ~/g2/wordpress/splc/wp-content/plugins/"$1"
    cp -r ~/g2/wordpress/repo-plugins/"$1" ~/g2/wordpress/splc/wp-content/plugins/
}


function deploy_redes() {
  cd ~/g2/wordpress/repo-plugins/"$1"
  git pull
  rm -r ~/g2/wordpress/splc/wp-content/plugins/socialhub-egc
  cp -r socialhub-egc ~/g2/wordpress/splc/wp-content/plugins/
}


function deploy_registro() {
  cd ~/g2/wordpress/repo-plugins/"$1"
  git pull
  rm -r ~/g2/wordpress/splc/wp-content/plugins/Trabajo
  cp -r Trabajo ~/g2/wordpress/splc/wp-content/plugins/
}


function main() {
    case "$1" in
    "project-program")
        deploy_programa "$@";;
    "RedesSociales")
        deploy_redes "$@";;
    "Registro")
        deploy_registro "$@";;
    esac
}

set -e
main "$@"
