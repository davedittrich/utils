# -*- coding: utf-8 -*-

import os
import pytest

from helpers import (
    ansible_vars,
    get_homedir,
    skip_unless_role,
)


@skip_unless_role('davedittrich.utils.visible_bell')
@pytest.mark.parametrize('user', ansible_vars.get('accounts', []))
def test_user_inputrc(host, user):
    f = host.file(
        os.path.join(
            get_homedir(host=host, user=user),
            '.inputrc'
        )
    )
    assert f.exists
    assert f.content_string.find(r'set prefer-visible-bell') > -1


@skip_unless_role('davedittrich.utils.visible_bell')
@pytest.mark.parametrize('user', ansible_vars.get('accounts', []))
def test_user_bashrc(host, user):
    f = host.file(
        os.path.join(
            get_homedir(host=host, user=user),
            '.bashrc'
        )
    )
    assert f.exists
    assert f.user == user
    assert f.content_string.find(r'set bellstyle visible') > -1


@skip_unless_role('davedittrich.utils.visible_bell')
@pytest.mark.parametrize('user', ansible_vars.get('accounts', []))
def test_user_cshrc(host, user):
    f = host.file(
        os.path.join(
            get_homedir(host=host, user=user),
            '.cshrc'
        )
    )
    assert f.exists
    assert f.user == user
    assert f.content_string.find(r'set visiblebell') > -1


@skip_unless_role('davedittrich.utils.visible_bell')
@pytest.mark.parametrize('user', ansible_vars.get('accounts', []))
def test_user_exrc(host, user):
    f = host.file(
        os.path.join(
            get_homedir(host=host, user=user),
            '.exrc'
        )
    )
    assert f.exists
    assert f.user == user
    assert r'set flash' in f.content_string


@skip_unless_role('davedittrich.utils.visible_bell')
@pytest.mark.parametrize('user', ansible_vars.get('accounts', []))
def test_user_vimrc(host, user):
    f = host.file(
        os.path.join(
            get_homedir(host=host, user=user),
            '.vimrc'
        )
    )
    assert f.exists
    assert f.user == user
    assert r'set vb t_vb=' in f.content_string


# vim: set fileencoding=utf-8 ts=4 sw=4 tw=0 et :
