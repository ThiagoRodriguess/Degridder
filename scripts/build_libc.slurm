#!/bin/bash
#SBATCH --job-name=libcxx
#SBATCH --output=libcxx-%j.log
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=8G
#SBATCH --time=01:00:00
#SBATCH --partition=insa-cpu

set -e

mkdir -p ~/libcxx-build
cd ~/libcxx-build

cmake -G Ninja ../llvm-project/runtimes \
  -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind" \
  -DCMAKE_C_COMPILER=$HOME/llvm-install/bin/clang \
  -DCMAKE_CXX_COMPILER=$HOME/llvm-install/bin/clang++ \
  -DCMAKE_INSTALL_PREFIX=$HOME/llvm-install \
  -DCMAKE_BUILD_TYPE=Release

ninja
ninja install
