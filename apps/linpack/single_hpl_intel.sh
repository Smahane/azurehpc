#!/bin/bash
set -o pipefail

AZHPC_VMSIZE=$(curl -s -H Metadata:true "http://169.254.169.254/metadata/instance/compute?api-version=2018-10-01" | jq -r '.vmSize')
AZHPC_VMSIZE=${AZHPC_VMSIZE,,}

MEMORY_MB=$(free -m | grep Mem: | xargs | cut -d' ' -f2)

MEMORY_FACTOR=0.25 # use only 50% of the memory 
case $AZHPC_VMSIZE in
    standard_hc44rs)
        HPL_NB=256
        P=1
        Q=1
    ;;
    *)
        echo "VM Size $AZHPC_VMSIZE not covered by this test"
        exit 1
    ;;
esac

# compute problem size
HPL_N=$(bc <<< "((sqrt(${MEMORY_MB}*$MEMORY_FACTOR*1024^2/8))/${HPL_NB})*${HPL_NB}")


cat <<EOF >HPL.dat
HPLinpack benchmark input file
Innovative Computing Laboratory, University of Tennessee
HPL.out      output file name (if any)
6            device out (6=stdout,7=stderr,file)
1            # of problems sizes (N)
$HPL_N        Ns
1            # of NBs
$HPL_NB          NBs
0            PMAP process mapping (0=Row-,1=Column-major)
1            # of process grids (P x Q)
$P            Ps
$Q            Qs
16.0         threshold
1            # of panel fact
2            PFACTs (0=left, 1=Crout, 2=Right)
1            # of recursive stopping criterium
4            NBMINs (>= 1)
1            # of panels in recursion
2            NDIVs
1            # of recursive panel fact.
2            RFACTs (0=left, 1=Crout, 2=Right)
1            # of broadcast
2            BCASTs (0=1rg,1=1rM,2=2rg,3=2rM,4=Lng,5=LnM)
1            # of lookahead depth
1            DEPTHs (>=0)
1            SWAP (0=bin-exch,1=long,2=mix)
$HPL_NB           swapping threshold
0            L1 in (0=transposed,1=no-transposed) form
0            U  in (0=transposed,1=no-transposed) form
1            Equilibration (0=no,1=yes)
8            memory alignment in double (> 0)
EOF

source /etc/profile
module use /usr/share/Modules/modulefiles
module load mpi/impi-2019

HPL_EXE=/opt/intel/compilers_and_libraries_2019.5.281/linux/mkl/benchmarks/mp_linpack/xhpl_intel64_static

mpirun -np 1 $HPL_EXE | tee hpl.out
