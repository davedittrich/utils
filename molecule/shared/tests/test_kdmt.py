# -*- coding: utf-8 -*-

import pytest

from pathlib import Path


from helpers import (
    get_homedir,
    load_ansible_vars,
    skip_unless_role,
)


ansible_vars = load_ansible_vars()
hid_apple_parameters = '/sys/module/hid_apple/paramaters'


# System tests.


@skip_unless_role('davedittrich.utils.kdmt')
def test_keyboard_config_packages(host):
    for package in ['keyboard-configuration', 'console-setup', 'udev']:
        assert host.package(package).is_installed


@skip_unless_role('davedittrich.utils.kdmt')
def test_custom_load_xmodmap(host):
    f = host.file('/etc/X11/Xsession.d/40custom_load_xmodmap')
    assert f.exists
    assert f.user == 'root'
    assert r'XMODMAP="/usr/bin/xmodmap"' in f.content_string


@skip_unless_role('davedittrich.utils.kdmt')
def test_udev_hwdb_file(host):
    f = host.file('/etc/udev/hwdb.d/99-swapcapslockctrl.hwdb')
    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'
    assert r'KEYBOARD_KEY_700E0=capslock' in f.content_string


@skip_unless_role('davedittrich.utils.kdmt')
def test_xkboptions(host):
    f = host.file('/etc/default/keyboard')
    assert f.exists
    assert f.user == 'root'
    assert r'XKBOPTIONS="ctrl:swapcaps"' in f.content_string


@skip_unless_role('davedittrich.utils.kdmt')
def test_keyboard_configuration(host):
    with host.sudo():
        result = host.check_output("debconf-show keyboard-configuration")
        assert r'ctrl:swapcaps' in result


@skip_unless_role('davedittrich.utils.kdmt')
def test_hid_apple_conf(host):
    f = host.file('/etc/modprobe.d/hid_apple.conf')
    assert f.exists
    assert f.user == 'root'
    fnmode = ansible_vars.get('kdmt__keyboard_hid_apple_fnmode')
    iso_layout = ansible_vars.get('kdmt__keyboard_hid_apple_iso_layout')
    assert (
        f'hid_apple fnmode={fnmode}' in f.content_string
        and f'iso_layout={iso_layout}' in f.content_string
    )


@skip_unless_role('davedittrich.utils.kdmt')
def test_hid_apple_fnmode(host):
    f = host.file(hid_apple_parameters)
    try:
        assert f.exists
    except AssertionError:
        pytest.xfail(f'no {hid_apple_parameters} directory')
    f = host.file(str(Path(hid_apple_parameters) / 'fnmode'))
    assert f.user == 'root'
    fnmode = ansible_vars.get('kdmt__keyboard_hid_apple_fnmode')
    assert f.content_string == f'{fnmode}\n'


@skip_unless_role('davedittrich.utils.kdmt')
def test_hid_apple_iso_layout(host):
    f = host.file(hid_apple_parameters)
    try:
        assert f.exists
    except AssertionError:
        pytest.xfail(f'no {hid_apple_parameters} directory')
    f = host.file(str(Path(hid_apple_parameters) / 'iso_layout'))
    assert f.exists
    assert f.user == 'root'
    iso_layout = ansible_vars.get('kdmt__keyboard_hid_apple_iso_layout')
    assert f'{iso_layout}\n' == f.content_string


# User tests.


@skip_unless_role('davedittrich.utils.kdmt')
@pytest.mark.parametrize('user', ansible_vars.get('accounts', []))
def test_user_inputrc(host, user):
    homedir = get_homedir(host=host, user=user)
    f = host.file(str(Path(homedir) / '.inputrc'))
    assert f.exists
    assert f.content_string.find(r'set prefer-visible-bell') > -1


# @skip_unless_role('davedittrich.utils.kdmt')
# @pytest.mark.parametrize('user', ansible_vars.get('accounts', []))
# def test_user_bashrc(host, user):
#     homedir = get_homedir(host=host, user=user)
#     f = host.file(str(Path(homedir) / '.bashrc'))
#     assert f.exists
#     assert f.user == user
#     assert f.content_string.find(r'set bellstyle visible') > -1


@skip_unless_role('davedittrich.utils.kdmt')
@pytest.mark.parametrize('user', ansible_vars.get('accounts', []))
def test_user_cshrc(host, user):
    homedir = get_homedir(host=host, user=user)
    f = host.file(str(Path(homedir) / '.cshrc'))
    assert f.exists
    assert f.user == user
    assert f.content_string.find(r'set visiblebell') > -1


@skip_unless_role('davedittrich.utils.kdmt')
@pytest.mark.parametrize('user', ansible_vars.get('accounts', []))
def test_user_exrc(host, user):
    homedir = get_homedir(host=host, user=user)
    f = host.file(str(Path(homedir) / '.exrc'))
    assert f.exists
    assert f.user == user
    assert r'set flash' in f.content_string


@skip_unless_role('davedittrich.utils.kdmt')
@pytest.mark.parametrize('user', ansible_vars.get('accounts', []))
def test_user_vimrc(host, user):
    homedir = get_homedir(host=host, user=user)
    f = host.file(str(Path(homedir) / '.vimrc'))
    assert f.exists
    assert f.user == user
    assert r'set vb t_vb=' in f.content_string


@skip_unless_role('davedittrich.utils.kdmt')
@pytest.mark.parametrize('user', ansible_vars.get('accounts', []))
def test_user_xmodmap(host, user):
    homedir = get_homedir(host=host, user=user)
    f = host.file(str(Path(homedir) / '.Xmodmap'))
    assert f.exists
    assert f.user == user
    assert r'! Swap Caps_Lock and Control_L' in f.content_string


# vim: set fileencoding=utf-8 ts=4 sw=4 tw=0 et :
