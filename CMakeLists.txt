cmake_minimum_required(VERSION 3.10.2)

# *******************************************
# ************* CMake Content ***************
# *******************************************
# This CMake creates a workspace containing the following projects
#
# Program
#  - degridder

project(degridder C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -stdlib=libc++ -g -mcmodel=large -fopenmp")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99 -g -Wall -mcmodel=large")

# Add definition for relative path into project
add_definitions(-DPROJECT_ROOT_PATH="${CMAKE_CURRENT_SOURCE_DIR}")

# Debug or Release configuration
if(NOT ${CMAKE_GENERATOR} MATCHES "Visual Studio.*")
    if(CMAKE_BUILD_TYPE MATCHES "Debug")
        message("Generate Debug project")
        set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -g -pg -Wall ${ADDITIONAL_C_FLAGS}")
    else()
        message("Generate Release project")
        set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -g -pg -Wall ${ADDITIONAL_C_FLAGS}")
    endif()
    # Add math lib
    set(CMAKE_EXTRA_LIB m)
else()
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
endif()

set(LIBS_DIR ${CMAKE_CURRENT_SOURCE_DIR}/lib)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/lib/cmake_modules/")

# *******************************************
# ************ Pthread LIBRARY **************
# *******************************************
if(WIN32)
    set(THREADS_USE_PTHREADS_WIN32 true)
    file(GLOB PTHREADDIR "${LIBS_DIR}/pthread-[\\.|0-9]*")
    list(APPEND CMAKE_PREFIX_PATH ${PTHREADDIR})
    find_package(Threads REQUIRED)
else()
    find_package(Threads REQUIRED)
endif()

if(NOT THREADS_FOUND)
    message(FATAL_ERROR "Pthread not found!")
endif()

# Windows DLL copy (if needed)
if(WIN32)
    file(GLOB PTHREADS_DLL ${CMAKE_PREFIX_PATH}/lib/*.dll)
    message("Copy Pthreads DLLs into ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
    if(NOT ${CMAKE_GENERATOR} MATCHES "Visual Studio.*")
        file(COPY ${PTHREADS_DLL} DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
    else()
        file(COPY ${PTHREADS_DLL} DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Debug)
        file(COPY ${PTHREADS_DLL} DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Release)
    endif()
endif()

# *******************************************
# ************ OpenMP LIBRARY ***************
# *******************************************
option(USE_OpenMP "Use OpenMP" ON)
if(USE_OpenMP)
    find_package(OpenMP)
    if(OPENMP_FOUND)
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
    endif()
endif()

# *******************************************
# ************ casacore LIBRARY **************
# *******************************************

# Override CASACORE_ROOT with Apptainer specific include path if not set
if(NOT DEFINED ENV{CASACORE_ROOT})
    set(CASACORE_ROOT "/cluster_env_papi/local")
else()
    set(CASACORE_ROOT $ENV{CASACORE_ROOT})
endif()

message(STATUS "Using CASACORE_ROOT = ${CASACORE_ROOT}")

include_directories(
    ${CASACORE_ROOT}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/generated
    ${THREADS_PTHREADS_INCLUDE_DIR}
)

link_directories(
    ${CASACORE_ROOT}/lib
    /usr/lib
)

# Make sure flags are consistent
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99 -g -Wall -mcmodel=large")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mcmodel=large")

add_library(casa_wrapper STATIC
    src/casacore_wrapper.cpp
    include/casacore_wrapper.h
)

target_link_libraries(casa_wrapper
    casa_casa casa_tables casa_ms casa_measures casa_fits casa_mirlib
    fftw3
)

# *******************************************
# ***** CPU Version  ***********
# *******************************************

file(GLOB source_files_CPU
    ./generated/*.c
    ./src/*.c
)

file(GLOB header_files
    ./include/*.h
    ./generated/*.h
)

set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--allow-multiple-definition")

add_executable(degridder_pipeline ${source_files_CPU} ${header_files})

target_link_libraries(degridder_pipeline
    c++
    c++abi
    unwind 
    ${CMAKE_THREAD_LIBS_INIT}
    fftw3
    fftw3f
    lapack
    m
    casa_wrapper
    casacore_casa
    casacore_tables
    casacore_ms
    casacore_measures
    casacore_fits
    casacore_scimath
    casacore_lattices
    casacore_coordinates
)

# For LLVM libc++ paths, use an environment variable LLVM_ROOT or fallback to system default
if(DEFINED ENV{LLVM_ROOT})
    set(LLVM_ROOT $ENV{LLVM_ROOT})
else()
    set(LLVM_ROOT "/usr")
endif()

target_compile_options(degridder_pipeline PRIVATE -stdlib=libc++ -fopenmp -I${LLVM_ROOT}/include/c++/v1)

target_link_options(degridder_pipeline PRIVATE
    -stdlib=libc++
    -L${LLVM_ROOT}/lib
    -L/cluster_env_papi/llvm-install/lib
    -Wl,-rpath,/cluster_env_papi/local/lib
    -Wl,-rpath,/cluster_env_papi/llvm-install/lib 
    -fopenmp
    -lc++abi
)

