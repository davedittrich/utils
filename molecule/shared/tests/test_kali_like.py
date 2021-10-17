# -*- coding: utf-8 -*-

import os
import pytest

from molecule.shared import (
    ansible_vars,
    get_homedir,
    skip_unless_role,
)


@skip_unless_role('davedittrich.utils.kali_like')
def test_hostname(host, fixture_users):
    fhn = host.file('/etc/hostname')
    hostname = fhn.content_string.strip()
    assert hostname.startswith('kali-')
    fh = host.file('/etc/hosts')
    assert fh.content_string.find(hostname) > 0


# vim: set fileencoding=utf-8 ts=4 sw=4 tw=0 et :
