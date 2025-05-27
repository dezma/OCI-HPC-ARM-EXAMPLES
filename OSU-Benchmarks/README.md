# 📊 OSU Micro-Benchmarks on OCI ARM HPC Cluster

This guide explains how to install, compile, and run OSU Micro-Benchmarks on an ARM-based OpenMPI cluster deployed on [Oracle Cloud Infrastructure (OCI)](https://www.oracle.com/cloud/).  
---

## ✅ Prerequisites

- OpenMPI cluster deployed via [OpenMPI-OCI-ARM](https://github.com/dezmaIT/OpenMPI-OCI-ARM)
- Shared NFS mount at `/mnt/mpi_shared` across all nodes
- Passwordless SSH set up from head node to all workers
- Hostfile available at `/mnt/mpi_shared/hostfile`
- Ubuntu 24.04 ARM (AArch64)
- OpenMPI installed on all nodes

---

## 🛠️ Installation Steps

### 1. Fetch and Prepare the Script

```bash
wget -O osu-benchmark.sh https://raw.githubusercontent.com/dezmaIT/OCI-HPC-ARM-EXAMPLES/main/OSU-Benchmarks/osu-benchmark.sh
chmod +x osu-benchmark.sh
```

### 2. Execute Installation

Run the installer script on the head node:

```bash
./osu-benchmark.sh
```

This will:
- Download OSU Micro-Benchmarks v7.0.1
- Compile `osu_bw` and `osu_latency` with `-mcpu=ampere1`
- Install binaries into `/mnt/mpi_shared/osu-benchmarks/bin/`
- Write logs to `/var/log/osu-benchmark-<timestamp>.log`

---

## 🧪 Basic Testing

```bash
mpirun -np 2 -hostfile /mnt/mpi_shared/hostfile /mnt/mpi_shared/osu-benchmarks/bin/osu_bw
mpirun -np 2 -hostfile /mnt/mpi_shared/hostfile /mnt/mpi_shared/osu-benchmarks/bin/osu_latency
```

---

## 🚀 Multi-Node Scaling Test

Test bandwidth across an increasing number of nodes (example assumes 8-node cluster):

```bash
for np in 2 4 6 8 12 16; do
  echo "🔹 Running osu_bw with $np ranks"
  mpirun -np $np -hostfile /mnt/mpi_shared/hostfile \
         --map-by ppr:1:node \
         /mnt/mpi_shared/osu-benchmarks/bin/osu_bw
  echo ""
done
```

This will:
- Launch MPI with 1 rank per node
- Vary number of total processes (`np`)
- Use the shared hostfile for node allocation

> 🔎 Adjust the `--map-by` flag to test multiple ranks per node (`ppr:2:node`, etc.)

---

## 📂 Directory Structure

| Path | Description |
|------|-------------|
| `/mnt/mpi_shared/hostfile` | MPI hostfile listing node IPs or hostnames |
| `/mnt/mpi_shared/osu-benchmarks/bin/` | Compiled benchmark binaries |
| `/var/log/osu-benchmark-*.log` | Log files for installation and compilation |

---

## 🔧 Compiler Flags Used

- `-O3 -mcpu=ampere1 -fPIC`
- Links with `-lmpi -lstdc++ -lm -latomic`
- Verified for ARM AArch64

---

## 📎 References

- [OSU Benchmarks Website](https://mvapich.cse.ohio-state.edu/benchmarks/)
- [OCI Ampere Docs](https://docs.oracle.com/en-us/iaas/Content/Compute/References/arm-processors.htm)

---

## 📌 Tips

- Use `mpirun --display-map` for debugging placement
- Increase message sizes or add `osu_mbw_mr` for multi-pair tests
- Confirm binaries are compiled for `aarch64` using:

```bash
file  /mnt/mpi_shared/osu-benchmarks/bin/osu_bw
```

---

