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
@pytest.mark.parametrize('user', ansible_vars['accounts'])
def test_user_homedir(host, user):
    homedir = get_homedir(host=host, user=user)
    f = host.file(homedir)
    assert f.exists
    assert f.user == user
    assert f.group == user


@skip_unless_role('davedittrich.utils.branding')
def test_x11_session_manager_is_lxde(host):
    f = host.file('/etc/alternatives/x-session-manager')
    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'
    assert r'XDG_CURRENT_DESKTOP="LXDE"' in f.content_string


@skip_unless_role('davedittrich.utils.branding')
def test_wallpaper_image(host):
    assert 'lxde_wallpapers_directory' in ansible_vars
    wallpapers_dir = ansible_vars['lxde_wallpapers_directory']
    f = host.file(os.path.join(wallpapers_dir, 'custom-splash.jpg'))
    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'


@skip_unless_role('davedittrich.utils.branding')
@pytest.mark.parametrize('user', ansible_vars['accounts'])
def test_user_wallpaper_setting(host, user):
    if (
        'monitors' not in ansible_vars
        or ansible_vars['monitors'] == 0
    ):
        pytest.xfail('no monitors')
    monitors = int(ansible_vars['monitors'])
    homedir = get_homedir(host=host, user=user)
    d = host.file(os.path.join(homedir, '.config/pcmanfm/LXDE'))
    assert d.exists
    assert d.is_directory
    assert d.user == user
    assert d.group == user
    for monitor in range(monitors+1):
        f = host.file(
            os.path.join(
                homedir,
                f'.config/pcmanfm/LXDE/desktop-items-{monitor}.conf'
            )
        )
        assert f.exists
        assert f.user == user
        assert f.group == user
        assert r'custom-splash.jpg' in f.content_string


@skip_unless_role('davedittrich.utils.branding')
@pytest.mark.parametrize('user', ansible_vars['accounts'])
def test_LXDE_autostart_xset(host, user):
    homedir = get_homedir(host=host, user=user)
    f = host.file(
        os.path.join(homedir, '.config/lxsession/LXDE/autostart')
    )
    assert f.exists
    assert f.user == user
    assert f.group == user
    assert r'xset' in f.content_string


@skip_unless_role('davedittrich.utils.branding')
def test_lightdm_login_background(host):
    assert 'lxde_wallpapers_directory' in ansible_vars
    wallpapers_dir = ansible_vars['lxde_wallpapers_directory']
    login_background = os.path.join(wallpapers_dir, 'custom-splash.jpg')
    f = host.file('/etc/lightdm/lightdm-gtk-greeter.conf')
    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'
    assert f'background={login_background}' in f.content_string


@skip_unless_role('davedittrich.utils.branding')
@pytest.mark.parametrize('user', ansible_vars['accounts'])
def test_LXDE_desktop_conf(host, user):
    homedir = get_homedir(host=host, user=user)
    f = host.file(
        os.path.join(homedir, '.config/lxsession/LXDE/desktop.conf')
    )
    assert f.exists
    assert f.user == user
    assert f.group == user
    assert r'Beep=0' in f.content_string
    assert r'menu_prefix=lxde-' in f.content_string


# vim: set fileencoding=utf-8 ts=4 sw=4 tw=0 et :
