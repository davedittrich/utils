# -*- coding: utf-8 -*-

from molecule.shared import (
    skip_unless_role,
)


@skip_unless_role('davedittrich.utils.swapcapslockctrl')
def test_udev_hwdb_file(host):
    f = host.file('/etc/udev/hwdb.d/99-swapcapslockctrl.hwdb')
    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'
    assert r'KEYBOARD_KEY_700E0=capslock' in f.content_string


# vim: set fileencoding=utf-8 ts=4 sw=4 tw=0 et :
