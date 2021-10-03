# -*- coding: utf-8 -*-

import os
import pytest
import testinfra.utils.ansible_runner

from molecule.shared import (  # noqa
    ansible_vars,
    not_in_roles,
)


testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')
test_user = 'root'


@pytest.mark.skipif(
    not_in_roles('davedittrich.utils.visible_bell'),
    reason='role davedittrich.utils.visible_bell only'
)
def test_inputrc(host):
    assert 'visible_bell_users' in ansible_vars
    f = host.file(os.path.join(host.user(test_user).home, '.inputrc'))

    assert f.exists
    assert f.content_string.find(r'set prefer-visible-bell') > -1


@pytest.mark.skipif(
    not_in_roles('davedittrich.utils.visible_bell'),
    reason='role davedittrich.utils.visible_bell only'
)
def test_bashrc(host):
    f = host.file(os.path.join(host.user(test_user).home, '.bashrc'))

    assert f.exists
    assert f.user == test_user
    assert f.group == test_user
    assert f.content_string.find(r'set bellstyle visible') > -1


@pytest.mark.skipif(
    not_in_roles('davedittrich.utils.visible_bell'),
    reason='role davedittrich.utils.visible_bell only'
)
def test_cshrc(host):
    f = host.file(os.path.join(host.user(test_user).home, '.cshrc'))

    assert f.exists
    assert f.user == test_user
    assert f.group == test_user
    assert f.content_string.find(r'set visiblebell') > -1


@pytest.mark.skipif(
    not_in_roles('davedittrich.utils.visible_bell'),
    reason='role davedittrich.utils.visible_bell only'
)
def test_exrc(host):
    f = host.file(os.path.join(host.user(test_user).home, '.exrc'))

    assert f.exists
    assert f.user == test_user
    assert f.group == test_user
    assert r'set flash' in f.content_string


@pytest.mark.skipif(
    not_in_roles('davedittrich.utils.visible_bell'),
    reason='role davedittrich.utils.visible_bell only'
)
def test_vimrc(host):
    f = host.file(os.path.join(host.user(test_user).home, '.vimrc'))

    assert f.exists
    assert f.user == test_user
    assert f.group == test_user
    assert r'set vb t_vb=' in f.content_string


# vim: set fileencoding=utf-8 ts=4 sw=4 tw=0 et :
