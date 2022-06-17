"""
Cython coverage report builder

Builds Cython .pyx file annotation HTML with line coverage

MIT Licence

Alex Veden 2022
"""

import os
import glob
import sys
import numpy as np
from Cython.Build import cythonize
from coverage.cmdline import main
clean_up_files = []

CONDA_PREFIX = os.getenv('CONDA_PREFIX')
PYTHON_STR = f'python{sys.version_info.major}.{sys.version_info.minor}'
assert os.path.exists(CONDA_PREFIX), f'$CONDA_PREFIX not exist'
MODULE_SUFFIX = f".cpython-{sys.version_info.major}{sys.version_info.minor}-x86_64-linux-gnu.so"


# Any coverage.py supported test suite, i.e. 'nose', 'pytest', etc.
TEST_SUITE = 'nose'

pyx_files = []
SOURCE_DIR = os.path.abspath('..')
CURRENT_DIR = os.path.abspath('.')

assert os.path.basename(os.path.abspath('.')).lower() == 'tests', f'This script intended to run from `tests` directory, current: {CURRENT_DIR}'

for pyx_fn in glob.glob(os.path.join(SOURCE_DIR, '**', '*.pyx'), recursive=True):
    print(f'Compiling: {pyx_fn}')

    cy_module = pyx_fn.replace('.pyx', '.so')
    cy_module_obj = pyx_fn.replace('.pyx', '.o')
    cy_source = pyx_fn.replace('.pyx', '.c')

    if not os.path.exists(cy_module):
        #  Try to check   *.cpython-39-x86_64-linux-gnu.so
        files = glob.glob(cy_module.replace('.so', '.*.so'))
        if files:
            assert len(files) == 1, f'Duplicate modules found: {files}'
            cy_module = files[0]

    if not '.cpython-' in cy_module:
        # Make sure that '.so' module contains suffix, like: .cpython-39-x86_64-linux-gnu.so
        cy_module = cy_module.replace('.so', MODULE_SUFFIX)
    #
    # Create .c source code with line traces
    #
    cythonize(pyx_fn,
              compiler_directives={'linetrace': True, 'profile': True},
              include_path=['..', pyx_fn, np.get_include()],
              force=True,
              )

    # Build object files
    os.system(f'gcc -pthread -B {CONDA_PREFIX}/compiler_compat -Wno-unused-result -Wsign-compare -DNDEBUG -O2 -Wall -fPIC -O2 '
              f'-isystem {CONDA_PREFIX}/include -I{CONDA_PREFIX}/include -fPIC -O2 -isystem {CONDA_PREFIX}/include -fPIC '
              f'-DCYTHON_TRACE_NOGIL=1 -DCYTHON_TRACE=1 '
              f'-I{CONDA_PREFIX}/lib/{PYTHON_STR}/site-packages/numpy/core/include '
              f'-I{CONDA_PREFIX}/include/{PYTHON_STR} '
              f'-c {cy_source} -o {cy_module_obj}')

    # Build module
    os.system(f'gcc -pthread -B {CONDA_PREFIX}/compiler_compat -shared -Wl,-rpath,{CONDA_PREFIX}/lib -Wl,-rpath-link,{CONDA_PREFIX}/lib '
              f'-L{CONDA_PREFIX}/lib -L{CONDA_PREFIX}/lib -Wl,-rpath,{CONDA_PREFIX}/lib -Wl,-rpath-link,{CONDA_PREFIX}/lib '
              f'-L{CONDA_PREFIX}/lib {cy_module_obj} -o {cy_module}')

    pyx_files.append(pyx_fn)
    clean_up_files.append(cy_source)
    clean_up_files.append(cy_module)
    clean_up_files.append(cy_module_obj)

#
# Run full coverage report
#
os.chdir(SOURCE_DIR)
coverage_rc_fn = os.path.join('.coverage_temp_rc')
coverage_data_fn = os.path.join('.coverage_temp_data')
coverage_xml_fn = os.path.join('.coverage_temp_xml')

with open(coverage_rc_fn, 'w') as fh:
    clean_up_files.append(coverage_rc_fn)
    fh.write("""
[run]
plugins = Cython.Coverage
    """)

# Uncomment this to set global COVERAGE debug info
#os.environ['COVERAGE_DEBUG'] = 'plugin'

main(['run', f'--data-file={coverage_data_fn}', f'--rcfile={coverage_rc_fn}', '-m', TEST_SUITE, f'./tests/'])
main(['report', f'--data-file={coverage_data_fn}', f'--rcfile={coverage_rc_fn}'])
# Add -i (to ignore coverage errors)
main(['xml', f'--data-file={coverage_data_fn}', f'--rcfile={coverage_rc_fn}', '-i', '-o', coverage_xml_fn])

clean_up_files.append(coverage_xml_fn)
clean_up_files.append(coverage_data_fn)

#
# Make Cython HTML annotation with built-in coverage information
#
for pyx_fn in pyx_files:
    os.system(f'cython --annotate-coverage={coverage_xml_fn} {pyx_fn}')
    html_file = pyx_fn.replace('.pyx', '.html')
    if os.path.exists(html_file):
        print(f'Creating coverage file for: {os.path.basename(pyx_fn)}')
        clean_up_files.append(html_file)
        os.replace(html_file, os.path.join(CURRENT_DIR, f'cy_coverage__'+os.path.basename(html_file)))

#
# Cleanup
#
for clean_fn in clean_up_files:
    if os.path.exists(clean_fn):
        os.unlink(clean_fn)
