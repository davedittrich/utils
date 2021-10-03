# -*- coding: utf-8 -*-

import pytest


@pytest.mark.skipif(True, reason='force skip')
def test_shared_skip():
    assert False


# vim: set fileencoding=utf-8 ts=4 sw=4 tw=0 et :
