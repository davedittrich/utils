# -*- coding: utf-8 -*-

import os
import pytest

from molecule.shared import (
    ansible_vars,
    get_homedir,
    skip_unless_role,
)


@skip_unless_role('davedittrich.utils.dropins')
@pytest.mark.parametrize('user', ansible_vars['accounts'])
def test_dropin_directories(host, user):
    assert 'dropin_files' in ansible_vars
    for dropin_file in ansible_vars['dropin_files']:
        f = host.file(dropin_file)
        assert f.exists
        assert f.is_file
        assert f.user == user
        assert f.group == user
        dropin_dir_path = os.path.join(
            get_homedir(host=host, user=user),
            f'{dropin_file}.d'
        )
        d = host.file(dropin_dir_path)
        assert d.exists
        assert d.is_directory
        assert len(d.listdir()) > 0
        assert d.user == user
        assert d.group == user


# vim: set fileencoding=utf-8 ts=4 sw=4 tw=0 et :
