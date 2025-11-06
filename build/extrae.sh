#!/bin/bash

export EXTRAE_HOME=/cluster_env_papi/extrae/ins
export EXTRAE_CONFIG_FILE=extrae.xml

export LD_LIBRARY_PATH=/cluster_env_papi/papi/papi-7.2.0b2/install/lib:$LD_LIBRARY_PATH

export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libxml2.so.2:${EXTRAE_HOME}/lib/libomptrace.so

export OMP_NUM_THREADS=8
export OMP_STACKSIZE=16M
export EXTRAE_ON=1

./degridder_pipeline

