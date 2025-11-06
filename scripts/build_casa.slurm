#!/bin/bash

HOME_DIR="$HOME"
LLVM_DIR="$HOME_DIR/llvm-install"
LOCAL_DIR="$HOME_DIR/local"
CASACORE_BUILD_DIR="$HOME_DIR/casacore/build"
CASACORE_INSTALL_DIR="$HOME_DIR/casacore-install"

cd "$CASACORE_BUILD_DIR" || { echo "Erreur: dossier $CASACORE_BUILD_DIR introuvable"; exit 1; }

make VERBOSE=1 -j1
