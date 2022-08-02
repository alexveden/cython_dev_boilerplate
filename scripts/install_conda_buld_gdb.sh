git clone https://sourceware.org/git/binutils-gdb.git


# Fixing makeinfo missing error
sudo apt-get install texinfo bison flex libgmp-dev

cd binutils-gdb

make distclean
./configure  --with-python=python3
make

# Installs into /usr/local/bin
sudo make install
