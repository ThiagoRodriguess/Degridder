#!/bin/bash
#SBATCH --job-name=llvm-build
#SBATCH --output=llvm-build-%j.log
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --partition=insa-cpu

set -e  # Stop on first error

mkdir -p ~/llvm-build2
cd ~/llvm-build2

cmake -G Ninja \
  -DLLVM_ENABLE_PROJECTS="clang;openmp" \
  -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi" \
  -DCMAKE_BUILD_TYPE=MinSizeRel \
  -DCMAKE_INSTALL_PREFIX=~/llvm-install \
  -DLIBOMP_OMPX_TASKGRAPH=1 \
  -DLLVM_PARALLEL_LINK_JOBS=2 \
  -DLLVM_PARALLEL_COMPILE_JOBS=$(nproc) \
  ../llvm-project/llvm

# Compile
ninja

ninja install

