# -*- coding: utf-8 -*-

from molecule.shared import (
    skip_unless_role,
)


@skip_unless_role('davedittrich.utils.swapcapslockctrl')
def test_udev_package(host):
    assert host.package('udev').is_installed


@skip_unless_role('davedittrich.utils.swapcapslockctrl')
def test_udev_hwdb_file(host):
    f = host.file('/etc/udev/hwdb.d/99-swapcapslockctrl.hwdb')
    assert f.exists
    assert f.user == 'root'
    assert r'KEYBOARD_KEY_700E0=capslock' in f.content_string


@skip_unless_role('davedittrich.utils.swapcapslockctrl')
def test_xkboptions(host):
    f = host.file('/etc/default/keyboard')
    assert f.exists
    assert f.user == 'root'
    assert r'XKBOPTIONS="ctrl:swapcaps"' in f.content_string


@skip_unless_role('davedittrich.utils.swapcapslockctrl')
def test_keyboard_configuration(host):
    with host.sudo():
        result = host.check_output("debconf-show keyboard-configuration")
        assert r'ctrl:swapcaps' in result

# vim: set fileencoding=utf-8 ts=4 sw=4 tw=0 et :
