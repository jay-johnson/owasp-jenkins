import os
import logging
import unittest

log = logging.getLogger("base_test")


class BaseTestCase(unittest.TestCase):

    debug = False

    def setUp(self):
        if self.debug:
            print("setUp")
    # end of setUp

    def tearDown(self):
        if self.debug:
            print("tearDown")
    # end of tearDown

    def fail_if_test_file_exists(self,
                                 test_file=None):
        assert(not os.path.exists(test_file))
    # end of fail_if_test_file_exists

# end of BaseTestCase
