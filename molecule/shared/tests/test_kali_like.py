# -*- coding: utf-8 -*-

import os
import pytest
import stat

from molecule.shared import (
    ansible_vars,
    get_homedir,
    skip_unless_role,
)


# TODO(dittrich): Put this back when finished with tasks.
# @skip_unless_role('davedittrich.utils.kali_like')
# def test_hostname(host, fixture_users):
#     fhn = host.file('/etc/hostname')
#     hostname = str(fhn.content_string).strip()
#     assert hostname.startswith('kali-')
#     fh = host.file('/etc/hosts')
#     assert str(fh.content_string).find(hostname) > 0


# Use one fixture to return the list of users, and another to return the
# list of helper scripts.  These are used to generate test functions
# at collection time. For more information on how this works, see:
#   https://medium.com/opsops/deepdive-into-pytest-parametrization-cb21665c05b9


@pytest.fixture(params=ansible_vars.get('accounts', []))
def fixture_users(request):
    return request.param


@pytest.fixture(params=ansible_vars.get('kali_like_script_templates', []))
def fixture_helper_script_files(request):
    return str(request.param).replace('.sh.j2', '')


@pytest.fixture(params=ansible_vars.get('kali_like_packages', []))
def fixture_kali_like_packages(request):
    return request.param


@skip_unless_role('davedittrich.utils.kali_like')
def test_script_files(host, fixture_users, fixture_helper_script_files):
    user = fixture_users
    script_file = fixture_helper_script_files
    homedir = get_homedir(host=host, user=user)
    f = host.file(os.path.join(homedir, '.local', 'bin', script_file))
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


# vim: set fileencoding=utf-8 ts=4 sw=4 tw=0 et :
