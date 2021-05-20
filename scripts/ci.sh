#!/bin/bash
shopt -s extglob
ORG_DIR=$(pwd) 
$ORG_DIR/scripts/clean_up_project_repo.sh
$ORG_DIR/scripts/create_vivado_project.sh
$ORG_DIR/scripts/build_vivado_project.sh
$ORG_DIR/scripts/create_petalinux_project.sh
$ORG_DIR/scripts/build_petalinux_project.sh