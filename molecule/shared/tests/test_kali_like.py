# -*- coding: utf-8 -*-

import pytest
import stat

from pathlib import Path


from helpers import (
    get_homedir,
    load_ansible_vars,
    skip_unless_role,
)


ansible_vars = load_ansible_vars()


# TODO(dittrich): Put this back when finished with tasks.
# @skip_unless_role('davedittrich.utils.kali_like')
# def test_hostname(host, fixture_users):
#     fhn = host.file('/etc/hostname')
#     hostname = str(fhn.content_string).strip()
#     assert hostname.startswith('kali-')
#     fh = host.file('/etc/hosts')
#     assert str(fh.content_string).find(hostname) > 0


# For information on how fixtures are used, see:
#   https://medium.com/opsops/deepdive-into-pytest-parametrization-cb21665c05b9


@pytest.fixture(params=ansible_vars.get('accounts', []))
def fixture_users(request):
    """Return user account IDs."""
    return request.param


@pytest.fixture(params=ansible_vars.get('kali_like__script_templates', []))
def fixture_helper_script_files(request):
    """Return script template file names."""
    return str(request.param).replace('.sh.j2', '')


@pytest.fixture(params=ansible_vars.get('kali_like__packages', []))
def fixture_kali_like_packages(request):
    """Return list of desired Kali packages."""
    return request.param


@pytest.fixture(params=ansible_vars.get('guacamole_services', []))
def fixture_guacamole_services(request):
    """Return list of Guacamole related services."""
    return request.param or list()


@skip_unless_role('davedittrich.utils.kali_like')
def test_kali_apt_list(host):
    f = host.file('/etc/apt/sources.list.d/kali.list')
    assert f.exists
    assert f.user == 'root'
    assert f.mode == 0o644
    assert r'kali-rolling' in f.content_string


@skip_unless_role('davedittrich.utils.kali_like')
def test_script_files(host, fixture_users, fixture_helper_script_files):
    user = fixture_users
    script_file = fixture_helper_script_files
    homedir = Path(get_homedir(host=host, user=user))
    f = host.file(str(homedir.joinpath('.local', 'bin', script_file)))
    assert f.exists
    assert f.user == user
    assert (f.mode | stat.S_IRWXU) == 0o755


@skip_unless_role('davedittrich.utils.kali_like')
def test_kali_like_packages(host, fixture_kali_like_packages):
    package = fixture_kali_like_packages
    assert host.package(package).is_installed


@skip_unless_role('davedittrich.utils.kali_like')
def test_kali_application_menu(host):
    f = host.file('/etc/xdg/menus/applications-merged/kali-applications.menu')
    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'
    assert f.mode == 0o644


# FIX: 2024-11-19 dittrich: need to finish debugging guacamole installation.
# Until then, xfail
@pytest.mark.xfail
@skip_unless_role('davedittrich.utils.kali_like')
def test_guacamole_guacd(host):
    f = host.file('/usr/local/sbin/guacd')
    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'
    assert (f.mode | stat.S_IRWXU) == 0o755


@pytest.mark.xfail
@skip_unless_role('davedittrich.utils.kali_like')
def test_guacamole_services(host, fixture_guacamole_services):
    service = host.service(fixture_guacamole_services)
    assert service.is_running

# vim: set ts=4 sw=4 tw=0 et :
