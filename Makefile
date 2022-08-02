PROJ_ROOT:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
all_cy:=$(wildcard $(PROJ_ROOT)/**/*.pyx)

p ?= $(PROJ_ROOT)
GDB_EXECUTABLE:=/usr/local/bin/gdb

# Python execution which should be used for building module, in debug mode
#   Typically original python is fine for debugging cython modules, but if you need more debug info (python symbols)
# 	you should build or install debug version of python
#
PY_EXEC:=python
#PY_EXEC:=python-dbg

.PHONY: build build-debug tests coverage debug-file debug-file

build-debug:
	export EXT_BUILD_DEBUG=1; $(PY_EXEC) setup.py build_ext --inplace

build:
	python setup.py build_ext --inplace

tests: build
	export PYTHONPATH=$(PROJ_ROOT):$(PYTHONPATH); python -m nose $(p)

coverage: build-debug
	coverage run -m nose $(p)
	coverage xml -i -o $(PROJ_ROOT)/make_coverage.xml
	@for f in $(shell find $(PROJ_ROOT)/ -type f -regex ".*\.pyx"); do \
		echo $${f}; \
		cython --annotate-coverage=$(PROJ_ROOT)/make_coverage.xml $${f}; \
	done
	rm -f $(PROJ_ROOT)/make_coverage.xml

debug-file: build-debug
	test -f $(p) && echo \(!!!\) File '$(p)' does not exist, you must pass p= parameter to make with valid python file.  || exit 1
	export PYTHONPATH=$(PROJ_ROOT):$(PYTHONPATH); cygdb --gdb-executable=$(GDB_EXECUTABLE) . -- --args $(PY_EXEC) $(p)


debug-tests: build-debug
	test -d $(p) && echo \(!!!\) Directory '$(p)' does not exist, you must pass p= parameter to make with valid python tests.  || exit 1
	export PYTHONPATH=$(PROJ_ROOT):$(PYTHONPATH); cygdb --gdb-executable=$(GDB_EXECUTABLE) . -- --args $(PY_EXEC) -m nose $(p)

cleanup-build:
	rm -rf $(PROJ_ROOT)/build

cleanup-debug:
	rm -rf $(PROJ_ROOT)/cython_debug

cleanup-coverage:
	rm -f $(PROJ_ROOT)/make_coverage.xml
	rm -f $(PROJ_ROOT)/.coverage

cleanup-cython:

	@for entry in $(shell find $(PROJ_ROOT)/ -type f -regex ".*\.pyx");   \
    do                                      \
    	test=`basename $${entry} | sed -e s/.pyx//g`; \
    	echo $${test}; \
    	for i in `find . -type f -name $${test}.c -o -name $${test}.cpython-*.so -o -name $${test}.cpython-*.o -o -name $${test}.html`;             \
        do                                  \
            echo "Removing $${i}";        \
            rm -f $${i};		\
        done                                \
    done

cleanup: cleanup-build cleanup-coverage cleanup-cython cleanup-debug
