#cython: language_level=3

def cython_func(int a, int b):
    # Test function
    f = 1
    if a > 100:
        b += 1
    return a + b