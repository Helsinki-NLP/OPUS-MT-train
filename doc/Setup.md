# Installation and setup


* download the code

```
git clone https://github.com/Helsinki-NLP/OPUS-MT-train.git
```

* install pre-requisites (manually) or via submodules:

```
git submodule update --init --recursive --remote
make install-prerequisites
```


## Mac OSX

* for Marian-NMT: make sure that you have Xcode, protobuf and MKL installed. Protobuf can be added using, for example Mac ports:

```
sudo port install protobuf3-cpp
```

For MKL libraries, check https://software.intel.com/content/www/us/en/develop/tools/math-kernel-library/choose-download.html

* for eflomal: compile with gcc:

```
sudo port install gcc10
gcc-mp-10 -Ofast -march=native -Wall --std=gnu99 -Wno-unused-function -g -fopenmp -c eflomal.c
gcc-mp-10 -lm -lgomp -fopenmp  eflomal.o   -o eflomal
##
sudo port install llvm-devel py-cython py-numpy
sudo port select --set python python38
sudo port select --set python3 python38
sudo port select --set cython cython38
cd tools/efmoral
sudo env python3 setup.py install
```
