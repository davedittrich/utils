# -*- coding: utf-8 -*-

import pytest

from pathlib import Path


from helpers import (
    get_homedir,
    load_ansible_vars,
    skip_unless_role,
)


ansible_vars = load_ansible_vars()


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
def test_etc_profile_d_dotlocal(host):
    f = host.file('/etc/profile.d/dotlocal.sh')
    assert f.exists
    assert f.user == 'root'
    assert f.mode == 0o644


@skip_unless_role('davedittrich.utils.dropins')
def test_bashrc_sources_aliases(host, fixture_users):
    user = fixture_users
    homedir = Path(get_homedir(host=host, user=user))
    f = host.file(str(homedir / '.bashrc'))
    assert f.exists
    assert f.is_file
    assert f.user == user
    assert r'. ~/.bash_aliases' in f.content_string


@skip_unless_role('davedittrich.utils.dropins')
def test_dropin_files(host, fixture_users, fixture_dropin_files):
    user = fixture_users
    homedir = Path(get_homedir(host=host, user=user))
    f = host.file(str(homedir / fixture_dropin_files))
    assert f.exists
    assert f.is_file
    assert f.user == user


@skip_unless_role('davedittrich.utils.dropins')
def test_dropin_directories(host, fixture_users, fixture_dropin_files):
    user = fixture_users
    homedir = Path(get_homedir(host=host, user=user))
    dropin_dir = str(homedir / f'{fixture_dropin_files}.d')
    d = host.file(str(dropin_dir))
    assert d.exists
    assert d.is_directory
    assert len(d.listdir()) > 0
    assert d.user == user


@skip_unless_role('davedittrich.utils.dropins')
def test_pipx(host, fixture_users, fixture_programs):
    pipx_system = host.file('/usr/bin/pipx')
    if pipx_system.exists:
        assert True
    else:
        user = fixture_users
        homedir = Path(get_homedir(host=host, user=user))
        pipx_local = host.file(
            str(homedir.joinpath(".local", "bin", fixture_programs))
        )
        assert pipx_local.exists


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
