## Using the Apptainer Container

### 0. Download the .sif container
cluster_env_papi.sif foundable here until the 27/08/2025: https://filesender.renater.fr/?s=download&token=8154262d-335a-49be-a33a-0f1654297062

### 1. Launch the Container
apptainer shell cluster_env_papi.sif


## Running the project

### 1. Download the data
The input image data, stored in .csv format, with dimensions of 2560×2560, can be generated with SEP.

The input image data used for simulation can be generated via SEP.  
The measurement sets can be downloaded directly here:  
GLEAM :  
Dataset (SKA project, documentation):  
→ https://github.com/ska-telescope/sim-datasets  

Download Measurement Set (GLEAM):  
→ https://drive.google.com/drive/folders/1tq8jF0myYyk2BRgAaAyFlb4PcGzWXUtB   


Folder structure:  

-Code/  
--data/   
---input/  
----cycle_0_deconvolved_2560  
---sim_small  

### 2. Compile the DDFacet Simulator
cd [path_to_DDFacet_simulator]
cd build

cmake -DCMAKE_C_COMPILER=/env/llvm-install/bin/clang \
      -DCMAKE_CXX_COMPILER=/cluster_env_papi/llvm-install/bin/clang++ \
      -DCMAKE_CXX_FLAGS="-stdlib=libc++ -I/cluster_env_papi/llvm-install/include/c++/v1 -fopenmp" \
      -DCMAKE_EXE_LINKER_FLAGS="-stdlib=libc++ -L/cluster_env_papi/llvm-install/lib -Wl,-rpath=/cluster_env_papi/llvm-install/lib -fopenmp" \
      ..

make

### 3. Set Environment Variables
export LD_LIBRARY_PATH=/env/local/lib:$LD_LIBRARY_PATH

### 4. Run the Degridding Pipeline
./degridder_pipeline

### 5. Run with Extrae  
 ./extrae.sh  
 /cluster_env_papi/extrae/ins/bin/mpi2prv -f TRACE.mpits -o trace.prv

## Manual Compilation
The scripts folder contains the scripts used to install some of the necessary dependencies on the INSA compute cluster. However, some dependencies may be missing or require manual adjustments depending on your environment.

You may need to adapt the CMakeLists.txt file.

The project can be compiled manually using the following command:
cmake   -DCMAKE_CXX_COMPILER=$HOME/llvm-install/bin/clang++   -DCMAKE_C_COMPILER=$HOME/llvm-install/bin/clang   -DCMAKE_CXX_FLAGS="-stdlib=libc++ -I$HOME/llvm-install/include/c++/v1 -fopenmp"   -DCMAKE_EXE_LINKER_FLAGS="-stdlib=libc++ -L$HOME/llvm-install/lib -Wl,-rpath=$HOME/llvm-install/lib -fopenmp"   ..

You may need to set the LD_LIBRARY_PATH environment variable as follows:
export LD_LIBRARY_PATH=$HOME/llvm-install/lib:$LD_LIBRARY_PATH

