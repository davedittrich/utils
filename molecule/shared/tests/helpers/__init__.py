# -*- coding: utf-8 -*-

import os
import pytest
import testinfra
import testinfra.utils.ansible_runner
import yaml

from pathlib import Path


# https://medium.com/opsops/accessing-remote-host-at-test-discovery-stage-in-testinfra-pytest-7296235e804d

molecule_ephemeral_directory = os.environ.get('MOLECULE_EPHEMERAL_DIRECTORY')
if molecule_ephemeral_directory is None:
    raise RuntimeError(
        "[-] missing environment variable: 'MOLECULE_EPHEMERAL_DIRECTORY'"
    )
molecule_inventory_file = os.environ.get('MOLECULE_INVENTORY_FILE')
if molecule_inventory_file is None:
    raise RuntimeError(
        "[-] missing environment variable: 'MOLECULE_INVENTORY_FILE"
    )


def get_ansible_vars_file():
    """Return path to saved Ansible variables from `converge` stage."""
    ephemeral_directory = Path(molecule_ephemeral_directory)
    return ephemeral_directory / 'ansible-vars.yml'

def load_ansible_vars():
    """Load saved Ansible variables from `converge` stage."""
    yaml_file = get_ansible_vars_file()
    return yaml.safe_load(yaml_file.read_bytes())


ansible_vars = load_ansible_vars()


def in_roles(role, roles=None):
    """Return boolean for inclusion of role in a list of roles."""
    ansible_vars = load_ansible_vars()
    if roles is None:
        roles = ansible_vars.get('ansible_role_names', [])
    return role in roles


def skip_unless_role(role):
    """Decorator for skipping tests when related role is not involved."""
    if in_roles(role):
        return lambda func: func
    return pytest.mark.skipif(
        not in_roles(role),
        reason=f'role {role} only'
    )


def get_homedir(host=None, user=None):
    """Get user's home directory path in instance."""
    cmd = host.run(f'/usr/bin/getent passwd {user}')
    return cmd.stdout.split(':')[5]


def get_testinfra_hosts():
    """Get list of testinfra hosts."""
    testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
        molecule_inventory_file
    ).get_hosts('all')
    print(f"[+] found testinfra_hosts: {testinfra_hosts}")
    # except RuntimeError:
    #     print(f"[-] failed to get testinfra_hosts")
    #     testinfra_hosts = []
    return testinfra_hosts


# vim: set fileencoding=utf-8 ts=4 sw=4 tw=0 et :
