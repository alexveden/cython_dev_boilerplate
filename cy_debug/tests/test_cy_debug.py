import unittest
from cy_debug.cy_module_valid import cython_func
from cy_debug.cy_module_segfault import cython_seg_fault

class MyTestCase(unittest.TestCase):
    def test_cython_func(self):
        self.assertEqual(3, cython_func(1, 2))

    def test_cython_seg_fault(self):
        # This unconditionally raises seg fault
        #self.assertEqual(3, cython_seg_fault(1, 2))
        pass


if __name__ == '__main__':
    unittest.main()
