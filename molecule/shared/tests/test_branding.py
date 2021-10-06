# -*- coding: utf-8 -*-

import os
import pytest

from molecule.shared import (
    ansible_vars,
    get_homedir,
    skip_unless_role,
)


@skip_unless_role('davedittrich.utils.branding')
def test_boot_config(host):
    f = host.file('/boot/config.txt')
    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'
    assert r'disable_splash=1' in f.content_string


@skip_unless_role('davedittrich.utils.branding')
def test_boot_cmdline(host):
    f = host.file('/boot/cmdline.txt')
    assert f.user == 'root'
    assert f.group == 'root'
    assert r'logo.nologo' in f.content_string


@skip_unless_role('davedittrich.utils.branding')
def test_fbi(host):
    assert host.package('fbi').is_installed


@skip_unless_role('davedittrich.utils.branding')
def test_splashscreen_service(host):
    splashscreen_service = host.service('splashscreen')
    assert splashscreen_service.is_enabled is True


@skip_unless_role('davedittrich.utils.branding')
def test_user_homedirs(host):
    assert 'branding_users' in ansible_vars
    for user in ansible_vars['branding_users']:
        homedir = get_homedir(host=host, user=user)
        f = host.file(homedir)
        assert f.exists
        assert f.user == user
        assert f.group == user


@skip_unless_role('davedittrich.utils.branding')
def test_wallpaper_image(host):
    assert 'lxde_wallpapers_directory' in ansible_vars
    wallpapers_dir = ansible_vars['lxde_wallpapers_directory']
    f = host.file(os.path.join(wallpapers_dir, 'custom-splash.jpg'))
    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'


@skip_unless_role('davedittrich.utils.branding')
def test_wallpaper_setting(host):
    if (
        'monitors' not in ansible_vars
        or len(ansible_vars['monitors']) == 0
    ):
        pytest.xfail('no monitors')
    assert 'branding_users' in ansible_vars
    for user in ansible_vars['branding_users']:
        homedir = get_homedir(host=host, user=user)
        f = host.file(
            os.path.join(homedir,
                         '.config/pcmanfm/LXDE/desktop-items-0.conf'
                         )
        )
        assert f.exists
        assert f.user == user
        assert f.group == user
        assert r'custom-wallpaper.png' in f.content_string


@skip_unless_role('davedittrich.utils.branding')
def test_LXDE_autostart_xset(host):
    assert 'branding_users' in ansible_vars
    for user in ansible_vars['branding_users']:
        homedir = get_homedir(host=host, user=user)
        f = host.file(os.path.join(homedir,
                      '.config/lxsession/LXDE/autostart'))
        assert f.exists
        assert f.user == user
        assert f.group == user
        assert r'xset' in f.content_string


# vim: set fileencoding=utf-8 ts=4 sw=4 tw=0 et :
