# Cython coverage report builder

A very rough sample script that automatically runs all tests and produces coverage report on Cython `.pyx` files.

## Features
1. Works well with `pyximport`, no need to build `setup.py` and rebuild cython modules
2. Creates a `linetrace` version of cython code, but cleans up after execution, so this won't interfere with production versions.
3. Clean up all `*.c`, `*.o`, `*.so` files built from `.pyx` files in 

## Requirements
1. Linux OS, or you could amend the script for supporting other OS
2. Anaconda python

## Installation
1. Place [cy_test/tests/run_cython_coverage_annotations.py](cy_test/tests/run_cython_coverage_annotations.py) in your `<proj>/<cython_package>/tests` directory one level above with `.pyx` files
2. Run the script
3. Open the report file at `tests/cy_coverage__(PYX_MODULE_NAME).html` 


## Result
[run_cython_coverage_annotations.py source code](./cy_test/tests/run_cython_coverage_annotations.py)

![HTML report](./cython_coverage.png)