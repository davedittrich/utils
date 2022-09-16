# -*- coding: utf-8 -*-

import os
import pytest

from helpers import (
    ansible_vars,
    get_homedir,
    skip_unless_role,
)


# System tests.


@skip_unless_role('davedittrich.utils.swapcapslockctrl')
def test_keyboard_config_packages(host):
    for package in ['keyboard-configuration', 'console-setup', 'udev']:
        assert host.package(package).is_installed


@skip_unless_role('davedittrich.utils.swapcapslockctrl')
def test_custom_load_xmodmap(host):
    f = host.file('/etc/X11/Xsession.d/40custom_load_xmodmap')
    assert f.exists
    assert f.user == 'root'
    assert r'XMODMAP="/usr/bin/xmodmap"' in f.content_string


@skip_unless_role('davedittrich.utils.swapcapslockctrl')
def test_udev_hwdb_file(host):
    f = host.file('/etc/udev/hwdb.d/99-swapcapslockctrl.hwdb')
    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'
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


@skip_unless_role('davedittrich.utils.swapcapslockctrl')
def test_hid_apple_conf(host):
    f = host.file('/etc/modprobe.d/hid_apple.conf')
    assert f.exists
    assert f.user == 'root'
    assert r'hid_apple fnmode=2 iso_layout=0' in f.content_string


@skip_unless_role('davedittrich.utils.swapcapslockctrl')
def test_hid_apple_fnmode(host):
    f = host.file('/sys/module/hid_apple/parameters/fnmode')
    try:
        assert f.exists
    except AssertionError:
        pytest.xfail('no /sys/hid_apple/parameters directory')
    assert f.user == 'root'
    assert '2\n' == f.content_string


@skip_unless_role('davedittrich.utils.swapcapslockctrl')
def test_hid_apple_iso_layout(host):
    f = host.file('/sys/module/hid_apple/parameters/iso_layout')
    try:
        assert f.exists
    except AssertionError:
        pytest.xfail('no /sys/hid_apple/parameters directory')
    assert f.user == 'root'
    assert '0\n' == f.content_string


# User tests.


@skip_unless_role('davedittrich.utils.swapcapslockctrl')
@pytest.mark.parametrize('user', ansible_vars.get('accounts', []))
def test_user_inputrc(host, user):
    f = host.file(
        os.path.join(
            get_homedir(host=host, user=user),
            '.inputrc'
        )
    )
    assert f.exists
    assert f.content_string.find(r'set prefer-visible-bell') > -1


# @skip_unless_role('davedittrich.utils.swapcapslockctrl')
# @pytest.mark.parametrize('user', ansible_vars.get('accounts', []))
# def test_user_bashrc(host, user):
#     f = host.file(
#         os.path.join(
#             get_homedir(host=host, user=user),
#             '.bashrc'
#         )
#     )
#     assert f.exists
#     assert f.user == user
#     assert f.content_string.find(r'set bellstyle visible') > -1


@skip_unless_role('davedittrich.utils.swapcapslockctrl')
@pytest.mark.parametrize('user', ansible_vars.get('accounts', []))
def test_user_cshrc(host, user):
    f = host.file(
        os.path.join(
            get_homedir(host=host, user=user),
            '.cshrc'
        )
    )
    assert f.exists
    assert f.user == user
    assert f.content_string.find(r'set visiblebell') > -1


@skip_unless_role('davedittrich.utils.swapcapslockctrl')
@pytest.mark.parametrize('user', ansible_vars.get('accounts', []))
def test_user_exrc(host, user):
    f = host.file(
        os.path.join(
            get_homedir(host=host, user=user),
            '.exrc'
        )
    )
    assert f.exists
    assert f.user == user
    assert r'set flash' in f.content_string


@skip_unless_role('davedittrich.utils.swapcapslockctrl')
@pytest.mark.parametrize('user', ansible_vars.get('accounts', []))
def test_user_vimrc(host, user):
    f = host.file(
        os.path.join(
            get_homedir(host=host, user=user),
            '.vimrc'
        )
    )
    assert f.exists
    assert f.user == user
    assert r'set vb t_vb=' in f.content_string


@skip_unless_role('davedittrich.utils.swapcapslockctrl')
@pytest.mark.parametrize('user', ansible_vars.get('accounts', []))
def test_user_xmodmap(host, user):
    homedir = get_homedir(host=host, user=user)
    f = host.file(os.path.join(homedir, '.Xmodmap'))
    assert f.exists
    assert f.user == user
    assert r'! Swap Caps_Lock and Control_L' in f.content_string


# vim: set fileencoding=utf-8 ts=4 sw=4 tw=0 et :
