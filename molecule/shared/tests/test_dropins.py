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
    not_in_roles('davedittrich.utils.dropins'),
    reason='role davedittrich.utils.dropins only'
)
def test_dropin_directory(host):
    assert 'branding_users' in ansible_vars
    for user in ansible_vars['branding_users']:
        for dropin_file in host_vars.dropin_files:
            dropin_dir_path = os.path.join(
                user,
                f'{dropin_file}.d'
            )
            assert dropin_dir_path == ''


# vim: set fileencoding=utf-8 ts=4 sw=4 tw=0 et :
