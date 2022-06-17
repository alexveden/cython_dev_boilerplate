import unittest
import pyximport; pyximport.install()

from cy_test.cy_module import cython_func

class MyTestCase(unittest.TestCase):
    def test_something(self):
        cython_func(1, 2)


if __name__ == '__main__':
    unittest.main()
