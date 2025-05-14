# 🚀 CP2K on OCI A2 ARM Cluster

This guide explains how to install and run [CP2K](https://www.cp2k.org/) on an OCI Ampere A1 (ARM-based) HPC cluster deployed using [OpenMPI-OCI-ARM](https://github.com/dezmaIT/OpenMPI-OCI-ARM). CP2K is a powerful and scalable quantum chemistry and solid-state physics simulation package.

---

## 📦 What is CP2K?

CP2K performs atomistic simulations using various methods such as:

* Density Functional Theory (DFT)
* Hartree-Fock
* Classical Force Fields
* Molecular Dynamics (MD)

It supports **massively parallel MPI-based workloads**, making it ideal for your ARM cluster.

---

## 💾 Cluster Requirements

* Ubuntu 22.04+ (64-bit, ARM)
* Shared NFS volume (`/mnt/mpi_shared`)
* Passwordless SSH between all nodes
* OpenMPI with ARM support installed

---

## 💪 Installation Steps

1. **SSH into the head node:**

```bash
ssh ubuntu@<head-node-public-ip>
```

2. **Download and run the installer script:**

```bash
wget https://raw.githubusercontent.com/dezmaIT/OCI-HPC-ARM-EXAMPLES/main/CP2K/install_cp2k.sh
chmod +x install_cp2k.sh
./install_cp2k.sh
```

> 🔐 Output will be logged to `/var/log/cp2k-install-<timestamp>.log`

---

## 🤖 Optional: Automate Install to All Nodes

After provisioning, from the head node:

```bash
for node in $(< /mnt/mpi_shared/hosts); do
  ssh "$node" 'bash -s' < install_cp2k.sh
done
```

---

## ✅ Post-Install Check

Verify installation:

```bash
cp2k --version
```

Sample output:

```
CP2K version 2023.1 (git:ab12345...)
```

---

## 🚀 Running a CP2K Job (Example)

Create a sample input (e.g. `H2O.inp`) and run:

```bash
mpirun -np 4 cp2k.psmp -i H2O.inp -o H2O.out
```

For multi-node scaling:

```bash
mpirun --hostfile /mnt/mpi_shared/hosts -np 40 cp2k.psmp -i H2O.inp -o H2O.out
```

---

## 📂 Installation Summary

* Binaries installed at: `/usr/local/cp2k/bin/cp2k.psmp`
* Symbolic link: `/usr/local/bin/cp2k`
* Build dir: `/mnt/mpi_shared/cp2k-build`
* Source dir: `/mnt/mpi_shared/cp2k-src`

---

## 🧪 Benchmarking and Scaling

You can benchmark with standard CP2K test cases, and use different `-np` and `--hostfile` configurations to evaluate performance scaling.

---

