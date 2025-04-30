## 📊 OSU Micro-Benchmarks on OCI ARM Cluster

This guide walks you through installing and running the [OSU Micro-Benchmarks](https://mvapich.cse.ohio-state.edu/benchmarks/) on an **OpenMPI-based ARM cluster** deployed via [OpenMPI-OCI-ARM](https://github.com/dezmaIT/OpenMPI-OCI-ARM).

---

### 📁 Prerequisites

- A working MPI cluster deployed from this repository
- SSH access to the head node
- Shared `/mnt/mpi_shared` mount across nodes
- OpenMPI installed under `/usr/local/`

---

### ⚙️ Installation (Automated)

Run this script **once on the head node** to install and compile the benchmarks:

```bash
curl -sSL https://raw.githubusercontent.com/YOUR_REPO/osu-installer.sh | bash
```

Or manually:

```bash
#!/bin/bash
set -euo pipefail
LOG_FILE="/var/log/osu-benchmark-setup-$(date +%s).log"
exec > "$LOG_FILE" 2>&1

cd /mnt/mpi_shared
wget https://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-7.0.1.tar.gz
tar xzf osu-micro-benchmarks-7.0.1.tar.gz
mv osu-micro-benchmarks-7.0.1 osu-benchmarks && rm osu-micro-benchmarks-7.0.1.tar.gz
cd osu-benchmarks

MPICC=/usr/local/bin/mpicc
CFLAGS="-O3 -mcpu=ampere1 -fPIC"
LDFLAGS="-lmpi -lstdc++ -lm -latomic"

$MPICC $CFLAGS -I./c/util -I./c -I./include -o ./c/mpi/pt2pt/osu_bw ./c/mpi/pt2pt/osu_bw.c ./c/util/osu_util*.c $LDFLAGS
$MPICC $CFLAGS -I./c/util -I./c -I./include -o ./c/mpi/pt2pt/osu_latency ./c/mpi/pt2pt/osu_latency.c ./c/util/osu_util*.c $LDFLAGS

sudo mkdir -p /usr/local/osu-benchmarks/bin
sudo cp ./c/mpi/pt2pt/osu_bw ./c/mpi/pt2pt/osu_latency /usr/local/osu-benchmarks/bin/
echo "✅ OSU Benchmarks installed to /usr/local/osu-benchmarks/bin"
```

---

### 🚀 Running Benchmarks

Ensure the `/mnt/mpi_shared/hostfile` contains valid worker node hostnames or IPs.

```bash 
mpirun -np 2 --hostfile /mnt/mpi_shared/hostfile /usr/local/osu-benchmarks/bin/osu_bw 
mpirun -np 2 --hostfile /mnt/mpi_shared/hostfile /usr/local/osu-benchmarks/bin/osu_latency
```

---

### 📌 Tips

- Run with different `-np` and host configurations to evaluate scaling.
- Output can be used for GROMACS performance estimation on the same hardware.
- Consider running on isolated cores for consistent results.

