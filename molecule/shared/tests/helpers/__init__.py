# -*- coding: utf-8 -*-

import os
import testinfra
import testinfra.utils.ansible_runner
import pytest
import yaml


# https://medium.com/opsops/accessing-remote-host-at-test-discovery-stage-in-testinfra-pytest-7296235e804d

try:
    testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
        os.environ.get('MOLECULE_INVENTORY_FILE')
    ).get_hosts('all')
except RuntimeError as err:
    testinfra_hosts = []

try:
    with open('/tmp/ansible-vars.yml', 'r') as yaml_file:
        ansible_vars = yaml.safe_load(yaml_file)
except FileNotFoundError:
    ansible_vars = {}

def in_roles(role, roles=None):
    """Return boolean for inclusion of role in a list of roles."""
    if roles is None:
        roles = ansible_vars.get('ansible_role_names', [])
    return role in roles


def get_homedir(host=None, user=None):
    """Get user's home directory path in instance."""
    cmd = host.run(f'/usr/bin/getent passwd {user}')
    return cmd.stdout.split(':')[5]


def skip_unless_role(role):
    """Decorator for skipping tests when related role is not involved."""
    if in_roles(role):
        return lambda func: func
    return pytest.mark.skipif(
        not in_roles(role),
        reason=f'role {role} only'
    )


# vim: set fileencoding=utf-8 ts=4 sw=4 tw=0 et :
