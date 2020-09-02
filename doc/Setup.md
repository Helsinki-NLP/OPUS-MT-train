# Installation and setup


* doenload the code

```
git clone https://github.com/Helsinki-NLP/OPUS-MT-train.git
```

* install pre-requisites (manually) or via submodules:

```
git submodule update --init --recursive --remote
make install-prerequisites
```

* on Mac OSX make sure that you have Xcode, protobuf and MKL installed. Protobuf can be added using, for example Mac ports:

```
sudo port install protobuf3-cpp
```

For MKL libraries, check https://software.intel.com/content/www/us/en/develop/tools/math-kernel-library/choose-download.html

