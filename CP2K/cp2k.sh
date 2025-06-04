#!/bin/bash
set -euo pipefail

LOG_FILE="/var/log/cp2k-install-$(date +%Y%m%d-%H%M%S).log"
exec > "$LOG_FILE" 2>&1

# CONFIG
CP2K_VERSION="2023.1"
INSTALL_DIR="/usr/local/cp2k"
SRC_DIR="/mnt/mpi_shared/cp2k-src"
BUILD_DIR="/mnt/mpi_shared/cp2k-build"
NUM_CORES=$(nproc)

echo "🔧 Installing dependencies..."
sudo apt update && sudo apt install -y \
  git cmake gfortran libopenblas-dev \
  libfftw3-dev liblapack-dev libscalapack-mpi-dev \
  libelpa-dev libopenmpi-dev openmpi-bin \
  libtool m4 python3 python3-pip

# Create directories
mkdir -p "$SRC_DIR" "$BUILD_DIR"
cd "$SRC_DIR"

echo "📦 Cloning CP2K source code..."
git clone --branch support/v$CP2K_VERSION https://github.com/cp2k/cp2k.git .
./tools/toolchain/install_cp2k_toolchain.sh \
  --with-openblas=system \
  --with-fftw=system \
  --with-scalapack=system \
  --with-elpa=system \
  --mpi-mode=openmpi \
  --with-openmpi=system \
  --install-dir "$BUILD_DIR"

echo "🛠 Building CP2K..."
cd "$SRC_DIR"
source "$BUILD_DIR/tools/toolchain/install/setup"
make -j"$NUM_CORES" ARCH=local VERSION="psmp"

# Optional: install to /usr/local
sudo mkdir -p "$INSTALL_DIR/bin"
sudo cp exe/local/cp2k.psmp "$INSTALL_DIR/bin/"
sudo ln -sf "$INSTALL_DIR/bin/cp2k.psmp" /usr/local/bin/cp2k

echo "✅ CP2K installed successfully to $INSTALL_DIR"

# Verify
echo "🔍 Version check:"
cp2k --version || echo "❌ cp2k not in PATH"

# Suggest next step
echo "🚀 You can now run CP2K jobs using mpirun -np <N> cp2k ..."
