# -*- coding: utf-8 -*-

import os
import pytest

from helpers import (
    ansible_vars,
    get_homedir,
    skip_unless_role,
)


# System oriented tests.


@skip_unless_role('davedittrich.utils.branding')
def test_boot_config(host):
    f = host.file('/boot/config.txt')
    assert f.exists
    assert f.user == 'root'
    assert r'disable_splash=1' in f.content_string


@skip_unless_role('davedittrich.utils.branding')
def test_boot_cmdline(host):
    f = host.file('/boot/cmdline.txt')
    assert f.exists
    assert f.user == 'root'
    assert r'logo.nologo' in f.content_string


@skip_unless_role('davedittrich.utils.branding')
def test_fbi_package(host):
    assert host.package('fbi').is_installed


@skip_unless_role('davedittrich.utils.branding')
def test_splashscreen_service(host):
    splashscreen_service = host.service('splashscreen')
    assert splashscreen_service.is_enabled is True


@skip_unless_role('davedittrich.utils.branding')
def test_wallpaper_image(host):
    assert 'lxde_wallpapers_directory' in ansible_vars
    wallpapers_dir = ansible_vars['lxde_wallpapers_directory']
    f = host.file(os.path.join(wallpapers_dir, 'custom-splash.jpg'))
    assert f.exists
    assert f.user == 'root'


@skip_unless_role('davedittrich.utils.branding')
def test_x11_session_manager_is_lxde(host):
    f = host.file('/etc/alternatives/x-session-manager')
    assert f.exists
    assert f.user == 'root'
    assert r'XDG_CURRENT_DESKTOP="LXDE"' in f.content_string


@skip_unless_role('davedittrich.utils.branding')
def test_lightdm_login_background(host):
    assert 'lxde_wallpapers_directory' in ansible_vars
    wallpapers_dir = ansible_vars['lxde_wallpapers_directory']
    login_background = os.path.join(wallpapers_dir, 'custom-splash.jpg')
    f = host.file('/etc/lightdm/lightdm-gtk-greeter.conf')
    assert f.exists
    assert f.user == 'root'
    assert f'background=#stretched:{login_background}' in f.content_string


# User oriented tests.


@skip_unless_role('davedittrich.utils.branding')
@pytest.mark.parametrize('user', ansible_vars.get('accounts', []))
def test_user_homedir(host, user):
    homedir = get_homedir(host=host, user=user)
    f = host.file(homedir)
    assert f.exists
    assert f.user == user


@skip_unless_role('davedittrich.utils.branding')
@pytest.mark.parametrize('user', ansible_vars.get('accounts', []))
def test_user_wallpaper_setting(host, user):
    monitors = int(ansible_vars.get('monitors', 0))
    if monitors == 0:
        pytest.xfail('no monitors')
    homedir = get_homedir(host=host, user=user)
    d = host.file(os.path.join(homedir, '.config', 'pcmanfm', 'LXDE'))
    assert d.exists
    assert d.is_directory
    assert d.user == user
    for monitor in range(monitors+1):
        f = host.file(
            os.path.join(
                homedir,
                '.config', 'pcmanfm', 'LXDE', f'desktop-items-{monitor}.conf'
            )
        )
        assert f.exists
        assert f.user == user
        assert r'custom-splash.jpg' in f.content_string


@skip_unless_role('davedittrich.utils.branding')
@pytest.mark.parametrize('user', ansible_vars.get('accounts', []))
def test_user_LXDE_autostart_xset(host, user):
    homedir = get_homedir(host=host, user=user)
    f = host.file(
        os.path.join(
            homedir, '.config', 'lxsession', 'LXDE', 'autostart'
        )
    )
    assert f.exists
    assert f.user == user
    assert r'lxpanel --profile LXDE' in f.content_string


# @skip_unless_role('davedittrich.utils.branding')
# @pytest.mark.parametrize('user', ansible_vars.get('accounts', []))
# def test_user_LXDE_desktop_conf(host, user):
#     homedir = get_homedir(host=host, user=user)
#     f = host.file(
#         os.path.join(homedir, '.config/lxsession/LXDE/desktop.conf')
#     )
#     assert f.exists
#     assert f.user == user
#     assert r'Beep=0' in f.content_string
#     assert r'menu_prefix=lxde-' in f.content_string

# Use one fixture to return the list of users, and another to return the
# list of configuration files.  These are used to generate test functions
# at collection time. For more information on how this works, see:
#   https://medium.com/opsops/deepdive-into-pytest-parametrization-cb21665c05b9


@pytest.fixture(params=ansible_vars.get('accounts', []))
def fixture_users(request):
    return request.param


@pytest.fixture(params=ansible_vars.get('config_templates', []))
def fixture_config_files(request):
    return str(request.param).replace('.j2', '')


@skip_unless_role('davedittrich.utils.branding')
def test_config_files(host, fixture_users, fixture_config_files):
    user = fixture_users
    config_file = fixture_config_files
    homedir = get_homedir(host=host, user=user)
    config_path = os.path.join(homedir, '.config', config_file)
    f = host.file(config_path)
    assert f.exists
    assert f.user == user


# vim: set fileencoding=utf-8 ts=4 sw=4 tw=0 et :
