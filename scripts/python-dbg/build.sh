./configure --enable-shared --enable-ipv6 --prefix=$PREFIX --enable-optimizations #--with-pydebug
make
make install

cd $PREFIX/bin
ln -s python3.9 python
ln -s pydoc3.9 pydoc