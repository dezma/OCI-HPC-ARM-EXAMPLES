#!/bin/bash
set -euo pipefail
LOG_FILE="/var/log/osu-benchmark-$(date +%s).log"
exec > "$LOG_FILE" 2>&1
cd /mnt/mpi_shared || exit 1

wget https://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-7.0.1.tar.gz


tar xzf osu-micro-benchmarks-7.0.1.tar.gz
mv osu-micro-benchmarks-7.0.1 osu-benchmarks
rm osu-micro-benchmarks-7.0.1.tar.gz

cd /mnt/mpi_shared/osu-benchmarks || exit 1
# Set exact paths based on your findings
UTIL_DIR="./c/util"
PT2PT_DIR="./c/mpi/pt2pt"


# Set compiler environment
export MPICC=/usr/local/bin/mpicc
export CFLAGS="-O3 -mcpu=ampere1 -fPIC"
export LDFLAGS="-lmpi -lstdc++ -lm -latomic"

# Compile from root directory
cd /mnt/mpi_shared/osu-benchmarks || exit 1

echo "Compiling osu_bw with:"
echo "Utilities from: $UTIL_DIR"
echo "Benchmark from: $PT2PT_DIR"

$MPICC $CFLAGS \
	-I"$UTIL_DIR" \
	-I"$(dirname "$UTIL_DIR")" \
	-I./include \
	-o "$PT2PT_DIR/osu_bw" \
	"$PT2PT_DIR/osu_bw.c" \
	"$UTIL_DIR/osu_util.c" \
	"$UTIL_DIR/osu_util_mpi.c" \
	"$UTIL_DIR/osu_util_graph.c" \
	"$UTIL_DIR/osu_util_papi.c" \
	$LDFLAGS
	
$MPICC $CFLAGS \
	-I"$UTIL_DIR" \
	-I"$(dirname "$UTIL_DIR")" \
	-I./include \
	-o "$PT2PT_DIR/osu_latency" \
	"$PT2PT_DIR/osu_latency.c" \
	"$UTIL_DIR/osu_util.c" \
	"$UTIL_DIR/osu_util_mpi.c" \
	"$UTIL_DIR/osu_util_graph.c" \
	"$UTIL_DIR/osu_util_papi.c" \
	$LDFLAGS
	
# Verify compilation
if [ -f "$PT2PT_DIR/osu_bw" ] && [ -f "$PT2PT_DIR/osu_latency" ]; then
	echo "SUCCESS: Benchmarks compiled"
	sudo mkdir -p /usr/local/osu-benchmarks/bin
	sudo cp "$PT2PT_DIR/osu_bw" "$PT2PT_DIR/osu_latency" /usr/local/osu-benchmarks/bin/
	echo "Installed to /usr/local/osu-benchmarks/bin"
	
	# Verify ARM binary
	echo "Binary verification:"
	file /usr/local/osu-benchmarks/bin/osu_bw | grep -i "ARM aarch64"
else
	echo "ERROR: Compilation failed"
	echo "Files in $UTIL_DIR:"
	ls -l "$UTIL_DIR"/osu_util*
	exit 1
fi

