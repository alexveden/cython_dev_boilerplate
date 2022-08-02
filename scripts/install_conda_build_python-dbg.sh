#!/bin/bash

# This instruction is for Unix-like OS users.
# I refered to the following guide when I wrote it.
# https://conda.io/docs/user-guide/tasks/build-packages/recipe.html

# Activate an environment if needed
#conda activate myenv

if [[ -d "$CONDA_PREFIX" ]]; then
    echo "Using conda prefix: $CONDA_PREFIX"
else
    echo "$CONDA_PREFIX does not exist, possibly not initialized."
    exit 1
fi

# Python compilation dependencies
sudo apt-get install build-essential gdb lcov pkg-config \
      libbz2-dev libffi-dev libgdbm-dev libgdbm-compat-dev liblzma-dev \
      libncurses5-dev libreadline6-dev libsqlite3-dev libssl-dev \
      lzma lzma-dev tk-dev uuid-dev zlib1g-dev

# Install conda-build if you haven't. Ironically, installing conda-build
# includes installing python. This python will be effectively replaced with
# your new python binary so don't worry.
conda install conda-build

# Make a directory. You can give it any name.
#mkdir python-dbg
cd python-dbg

# Modify the downloaded files. You change them to build a different version of
# Python or to add compile flags. Refer to Python developer's guide to learn
# more about build options. https://devguide.python.org/setup/

# For example, you can make following changes in build.sh
#
#./configure --enable-shared --enable-ipv6 --prefix=$PREFIX #--with-pydebug
#make -j16
#
cd ..
## Hope that the build will succeed or you have to figure out
## how to solve the build problem on your own.
conda-build python-dbg
#
## When conda build is finished, read the log message carefully and find
## the package filename and location. In my case, it looked as below
##    ..../conda-bld/linux-64/python-3.5.0b4-0.tar.bz2
## This is what's called a package in conda
#
## Actually install the package
## This part is not documented well in the official conda tutorial so I
## figured it out by reading `conda install -h` message. I'm not sure if
## this is the official way to install, but it worked for me.
conda install --use-local $CONDA_PREFIX/conda-bld/linux-64/python-3.9.7-0.tar.bz2
#
## Make sure if python has been installed
#conda list | grep python

#
## Make sure a python-with-pydebug(ex. python3.5dm) was installed along with
## a normal python(ex. python3.5m)
which python3.9
which python3.9d
PYTHON_DBG="$CONDA_PREFIX/bin/python3.9d"

if [[ -f  "$PYTHON_DBG" ]]; then
    ln -s "$PYTHON_DBG" "$CONDA_PREFIX/bin/python-dbg"
else
    echo "$PYTHON_DBG does not exist"
    exit -1
fi
#ln -s $CONDA_PREFIX/bin/sy