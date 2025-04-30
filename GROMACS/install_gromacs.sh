#!/bin/bash

# Exit on error
set -e

# Variables
GROMACS_VERSION=2023.3
INSTALL_DIR=/opt/gromacs
BUILD_DIR=/tmp/gromacs-build

# Load modules if using environment modules (optional)
# module load cmake gcc openmpi fftw

# Update system and install dependencies
sudo apt update && sudo apt install -y \
  cmake build-essential git \
  libfftw3-dev libgsl-dev \
  libhwloc-dev libnuma-dev \
  openmpi-bin libopenmpi-dev

# Download and extract GROMACS
mkdir -p $BUILD_DIR
cd $BUILD_DIR
wget ftp://ftp.gromacs.org/pub/gromacs/gromacs-$GROMACS_VERSION.tar.gz
tar -xzf gromacs-$GROMACS_VERSION.tar.gz
cd gromacs-$GROMACS_VERSION

# Create build directory
mkdir build && cd build

# Configure with ARM optimizations
cmake .. -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
         -DGMX_BUILD_OWN_FFTW=OFF \
         -DGMX_MPI=ON \
         -DGMX_OPENMP=ON \
         -DCMAKE_C_COMPILER=mpicc \
         -DCMAKE_CXX_COMPILER=mpicxx \
         -DGMX_SIMD=ARM_NEON \
         -DCMAKE_C_FLAGS="-mcpu=ampere1" \
         -DCMAKE_CXX_FLAGS="-mcpu=ampere1"

# Build and install
make -j$(nproc)
sudo make install

# Add GROMACS to bashrc for current user
echo "source $INSTALL_DIR/bin/GMXRC" >> ~/.bashrc
source ~/.bashrc

echo "✅ GROMACS installed successfully at $INSTALL_DIR"
