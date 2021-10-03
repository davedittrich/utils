# -*- coding: utf-8 -*-

# import testinfra.host
import yaml

# https://medium.com/opsops/accessing-remote-host-at-test-discovery-stage-in-testinfra-pytest-7296235e804d

with open('/tmp/ansible-vars.yml', 'r') as yaml_file:
    ansible_vars = yaml.safe_load(yaml_file)


# testinfra_host = testinfra.get_host('local')
# ansible_vars = yaml.load(
#     testinfra_host.file('/tmp/ansible-vars.yml').content
# )


assert 'ansible_role_names' in ansible_vars


def not_in_roles(role, roles=None):
    # if roles is None:
    #     roles = ansible_variables['ansible_role_names']
    # return role not in roles
    return False


# vim: set fileencoding=utf-8 ts=4 sw=4 tw=0 et :
