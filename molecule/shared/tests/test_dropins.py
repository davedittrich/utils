# -*- coding: utf-8 -*-

import os

from molecule.shared import (
    ansible_vars,
    get_homedir,
    skip_unless_role,
)


@skip_unless_role('davedittrich.utils.dropins')
def test_dropin_directory(host):
    assert 'dropin_users' in ansible_vars
    assert 'dropin_files' in ansible_vars
    for user in ansible_vars['dropin_users']:
        for dropin_file in ansible_vars['dropin_files']:
            dropin_dir_path = os.path.join(
                get_homedir(host=host, user=user),
                f'{dropin_file}.d'
            )
            dropin_dir = host.file(dropin_dir_path)
            assert dropin_dir.exists
            assert dropin_dir.is_directory
            assert len(dropin_dir.listdir()) > 0
            assert dropin_dir.user == user
            assert dropin_dir.group == user


# vim: set fileencoding=utf-8 ts=4 sw=4 tw=0 et :
