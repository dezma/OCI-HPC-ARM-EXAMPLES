# 🧬 GROMACS Deployment on OCI ARM-Based HPC Cluster

This guide explains how to install and test [GROMACS](https://www.gromacs.org/) on an ARM-based high-performance computing cluster on [Oracle Cloud Infrastructure (OCI)](https://www.oracle.com/cloud/)

It leverages the [install_gromacs.sh](https://github.com/dezmaIT/OCI-HPC-ARM-EXAMPLES/blob/main/GROMACS/install_gromacs.sh) script provided in this repository.

---

## ✅ Prerequisites

- A functional ARM-based OpenMPI cluster provisioned using [OpenMPI-OCI-ARM](https://github.com/dezmaIT/OpenMPI-OCI-ARM)
- Passwordless SSH from the head node to all worker nodes
- Shared `/mnt/mpi_shared/hostfile` listing all worker hostnames
- Ubuntu 24.04 ARM64 across all nodes

---

## 🚀 Step-by-Step: GROMACS Post-Provisioning Installation (Option 2)

### 1. SSh to the Head Node and Copy the Installer Script to it

Make sure this script is available on the head node:

```bash
wget -O install_gromacs.sh https://raw.githubusercontent.com/dezmaIT/OCI-HPC-ARM-EXAMPLES/main/GROMACS/install_gromacs.sh
chmod +x install_gromacs.sh
```

### 2. Run the Installation on All Worker Nodes

Use the following loop to deploy GROMACS to all nodes listed in your `/mnt/mpi_shared/hostfile`:

```bash
#!/bin/bash

INSTALL_SCRIPT="/home/ubuntu/install_gromacs.sh"
HOSTFILE="/mnt/mpi_shared/hostfile"

for node in $(awk '{print $1}' "$HOSTFILE"); do
  echo "🔧 Installing GROMACS on $node..."
  scp "$INSTALL_SCRIPT" ubuntu@"$node":/tmp/
  ssh ubuntu@"$node" 'bash /tmp/install_gromacs.sh'
done
```

Save the above as `deploy_gromacs.sh`, make it executable, and run it from your head node:

```bash
chmod +x deploy_gromacs.sh
./deploy_gromacs.sh
```

---

## 🧪 Testing GROMACS

After installation:

1. Log into any node (e.g., the head node or a worker)
2. Source GROMACS environment:

```bash
source /opt/gromacs/bin/GMXRC
```

3. Run a simple benchmark test (example with 2 MPI ranks):

```bash
mpirun -np 2 -hostfile /mnt/mpi_shared/hostfile gmx_mpi mdrun -v -s benchMEM.tpr
```

Replace `benchMEM.tpr` with any test `.tpr` file (GROMACS input format). You can generate this from a `.mdp` file using `gmx grompp`.

---

## 📂 File Summary

- `install_gromacs.sh`: GROMACS build + install script
- `deploy_gromacs.sh`: Orchestrates install across nodes

---

## 📎 References

- [GROMACS Official Documentation](https://manual.gromacs.org/)
- [OCI ARM Compute](https://www.oracle.com/cloud/compute/arm/)
