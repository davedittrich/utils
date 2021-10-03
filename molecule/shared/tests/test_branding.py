# -*- coding: utf-8 -*-

import os
import pytest
import testinfra.utils.ansible_runner

from molecule.shared import (  # noqa
    ansible_vars,
    not_in_roles,
    users,
)


testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


@pytest.mark.skipif(
    not_in_roles('davedittrich.utils.branding'),
    reason='role davedittrich.utils.branding only'
)
def test_boot_config(host):
    f = host.file('/boot/config.txt')

    if not f.exists:
        pytest.skip("/boot/config.txt does not exist")
    else:
        assert f.user == 'root'
        assert f.group == 'root'
        assert r'disable_splash=1' in f.content_string


@pytest.mark.skipif(
    not_in_roles('davedittrich.utils.branding'),
    reason='role davedittrich.utils.branding only'
)
def test_boot_cmdline(host):
    f = host.file('/boot/cmdline.txt')

    if not f.exists:
        pytest.skip("/boot/cmdline.txt does not exist")
    else:
        assert f.user == 'root'
        assert f.group == 'root'
        assert r'logo.nologo' in f.content_string


@pytest.mark.skipif(
    not_in_roles('davedittrich.utils.branding'),
    reason='role davedittrich.utils.branding only'
)
def test_fbi(host):
    assert host.package('fbi').is_installed


@pytest.mark.skipif(
    not_in_roles('davedittrich.utils.branding'),
    reason='role davedittrich.utils.branding only'
)
def test_splashscreen_service(host):
    splashscreen_service = host.service('splashscreen')
    assert splashscreen_service.is_enabled is True


@pytest.mark.skipif(
    not_in_roles('davedittrich.utils.branding'),
    reason='role davedittrich.utils.branding only'
)
def test_user_homedirs(host):
    assert 'branding_users' in ansible_vars
    for user in ansible_vars['branding_users']:
        homedir = os.path.expanduser(f'~{user}')
        f = host.file(homedir)
        if os.path.exists(homedir):
            assert f.user == user
            assert f.group == user


@pytest.mark.skipif(
    not_in_roles('davedittrich.utils.branding'),
    reason='role davedittrich.utils.branding only'
)
def test_wallpaper_image(host):
    assert 'lxde_wallpapers_directory' in ansible_vars
    wallpapers_dir = ansible_vars['lxde_wallpapers_directory']
    f = host.file(os.path.join(wallpapers_dir, 'custom-splash.jpg'))
    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'


@pytest.mark.skipif(
    not_in_roles('davedittrich.utils.branding'),
    reason='role davedittrich.utils.branding only'
)
def test_wallpaper_setting(host):
    assert 'branding_users' in ansible_vars
    for user in ansible_vars['branding_users']:
        homedir = os.path.expanduser(f'~{user}')
        f = host.file(
            os.path.join(homedir,
                         '.config/pcmanfm/LXDE/desktop-items-0.conf'
                         )
        )
        assert f.exists
        assert f.user == user
        assert f.group == user
        assert r'custom-wallpaper.png' in f.content_string


@pytest.mark.skipif(
    not_in_roles('davedittrich.utils.branding'),
    reason='role davedittrich.utils.branding only'
)
def test_LXDE_autostart_xset(host):
    assert 'branding_users' in ansible_vars
    for user in ansible_vars['branding_users']:
        homedir = os.path.expanduser(f'~{user}')
        f = host.file(os.path.join(homedir,
                      '.config/lxsession/LXDE/autostart'))
        assert f.exists
        assert f.user == user
        assert f.group == user
        assert r'xset' in f.content_string


# vim: set fileencoding=utf-8 ts=4 sw=4 tw=0 et :
