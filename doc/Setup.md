# Installation and setup

* download the code

```
git clone https://github.com/Helsinki-NLP/OPUS-MT-train.git
```

* make sure that you have `pip` (for Python libraries) and `cpan` (for Perl modules) available on your system. For `cpan you may need to setup [local::lib](https://metacpan.org/pod/local::lib) to install locally in your user environment.
* install pre-requisites (manually) or via submodules:

```
git submodule update --init --recursive --remote
make install
```


## Prerequisites

The installation procedure should hopefully setup the necessary software for running the OPUS-MT recipes. Be aware that running the scripts does not work out of the box because many settings are adjusted for the local installations on our IT infrastructure at [CSC](https://docs.csc.fi/). Here is an incomplete list of prerequisites needed for running a process:

* [marian-nmt](https://github.com/marian-nmt/): The essential NMT toolkit we use in OPUS-MT; make sure you compile a version with GPU and SentencePiece support!
* [Moses scripts](https://github.com/moses-smt/mosesdecoder): various pre- and post-processing scripts from the Moses SMT toolkit (also bundled here: [marian-nmt](https://github.com/marian-nmt/moses-scripts))
* [OpusTools](https://pypi.org/project/opustools): library and tools for accessing OPUS data
* [OpusTools-perl](https://github.com/Helsinki-NLP/OpusTools-perl): additional tools for accessing OPUS data
* [iso-639](https://pypi.org/project/iso-639/): a Python package for ISO 639 language codes
* Perl modules [ISO::639::3](https://metacpan.org/pod/ISO::639::3) and [ISO::639::5](https://metacpan.org/pod/ISO::639::5)
* [jq JSON processor](https://stedolan.github.io/jq/)

Optional (recommended) software:

* [terashuf](https://github.com/alexandres/terashuf): efficiently shuffle massive data sets
* [pigz](https://zlib.net/pigz/): multithreaded gzip
* [eflomal](https://github.com/robertostling/eflomal) (needed for word alignment when transformer-align is used)
* [fast_align](https://github.com/clab/fast_align)



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

## Troubleshooting
