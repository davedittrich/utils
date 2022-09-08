# -*- coding: utf-8 -*-

import os
import pytest

from helpers import (
    ansible_vars,
    get_homedir,
    skip_unless_role,
)


# Use one fixture to return the list of users, and another to return the
# list of dropin files.  These are used to generate test functions
# at collection time. For more information on how this works, see:
#   https://medium.com/opsops/deepdive-into-pytest-parametrization-cb21665c05b9

@pytest.fixture(params=['pipx', 'update-dotdee'])
def fixture_programs(request):
    return request.param


@pytest.fixture(params=ansible_vars.get('accounts', []))
def fixture_users(request):
    return request.param


@pytest.fixture(params=ansible_vars.get('dropin_files', []))
def fixture_dropin_files(request):
    return str(request.param).replace('.j2', '')


@skip_unless_role('davedittrich.utils.dropins')
def test_bashrc_sources_aliases(host, fixture_users):
    user = fixture_users
    homedir = get_homedir(host=host, user=user)
    f = host.file(os.path.join(homedir, '.bashrc'))
    assert f.exists
    assert f.is_file
    assert f.user == user
    assert r'. ~/.bash_aliases' in f.content_string


@skip_unless_role('davedittrich.utils.dropins')
def test_dropin_files(host, fixture_users, fixture_dropin_files):
    user = fixture_users
    homedir = get_homedir(host=host, user=user)
    dropin_file = os.path.join(homedir, fixture_dropin_files)
    f = host.file(dropin_file)
    assert f.exists
    assert f.is_file
    assert f.user == user


@skip_unless_role('davedittrich.utils.dropins')
def test_dropin_directories(host, fixture_users, fixture_dropin_files):
    user = fixture_users
    homedir = get_homedir(host=host, user=user)
    dropin_file = os.path.join(homedir, fixture_dropin_files)
    d = host.file(f'{dropin_file}.d')
    assert d.exists
    assert d.is_directory
    assert len(d.listdir) > 0
    assert d.user == user


@skip_unless_role('davedittrich.utils.dropins')
def test_pipx(host, fixture_users, fixture_programs):
    user = fixture_users
    f = host.file(
       os.path.join(
           get_homedir(host=host, user=user),
           ".local", "bin", fixture_programs
       )
    )
    assert f.exists


@skip_unless_role('davedittrich.utils.dropins')
def test_update_dotdee_write_bash_profile(host, fixture_users):
    user = fixture_users
    homedir = get_homedir(host=host, user=user)
    with host.sudo(user=user):
        result = host.check_output(
            f"{homedir}/.local/bin/update-dotdee '{homedir}/.bash_profile' 2>&1"  # noqa
        )
        assert "INFO Writing file: ~/.bash_profile" in result


# vim: set fileencoding=utf-8 ts=4 sw=4 tw=0 et :
