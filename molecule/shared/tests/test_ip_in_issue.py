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


@pytest.mark.skipif(
    not_in_roles('davedittrich.utils.ip_in_issue'),
    reason='role davedittrich.utils.ip_in_issue only'
)
def test_issue_file(host):
    f = host.file('/etc/issue')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'
    assert len(f.content_string.strip()) > 1


@pytest.mark.skipif(
    not_in_roles('davedittrich.utils.iip_in_issue'),
    reason='role davedittrich.utils.ip_in_issue only'
)
def test_issue_d_interfaces(host):
    f = host.file('/etc/issue.d/02-interfaces.issue')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'
    assert r' \4{' in f.content_string


@pytest.mark.skipif(
    not_in_roles('davedittrich.utils.ip_in_issue'),
    reason='role davedittrich.utils.ip_in_issue only'
)
def test_issue_d_fingerprints(host):
    f = host.file('/etc/issue.d/01-ssh-fingerprints.issue')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'
    assert r' SHA256:' in f.content_string


# vim: set fileencoding=utf-8 ts=4 sw=4 tw=0 et :
