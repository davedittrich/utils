# -*- coding: utf-8 -*-

import os
import testinfra.utils.ansible_runner

from molecule.shared import (  # noqa
    ansible_vars,
    not_in_roles,
)


testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_udev_hwdb_file(host):
    f = host.file('/etc/udev/hwdb.d/99-swapcapslockctrl.hwdb')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'
    assert r'KEYBOARD_KEY_700E0=capslock' in f.content_string


# vim: set fileencoding=utf-8 ts=4 sw=4 tw=0 et :
