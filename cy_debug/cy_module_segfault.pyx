#cython: language_level=3

cdef int make_seg_fault(int *p):
    p[0] = 1

def cython_seg_fault(int a, int b):
    # Test function
    f = 1
    if a > 100:
        b += 1
    cdef int* ptr = NULL

    make_seg_fault(ptr)

    return a + b