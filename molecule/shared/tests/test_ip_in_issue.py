# -*- coding: utf-8 -*-

import pytest

from helpers import skip_unless_role


@skip_unless_role('davedittrich.utils.ip_in_issue')
def test_hosts_file(host):
    host_environment = host.environment()
    if host_environment.get('container', '') == 'docker':
        pytest.skip('/etc/hosts file managed by Docker')
    f = host.file('/etc/hosts')
    assert f.exists
    assert f.user == 'root'
    assert r'kali-' in f.content_string
    assert r'kali-' in host_environment.get('HOSTNAME')

@skip_unless_role('davedittrich.utils.ip_in_issue')
def test_issue_file(host):
    f = host.file('/etc/issue')
    assert f.exists
    assert f.user == 'root'
    assert len(f.content_string.strip()) > 1


@skip_unless_role('davedittrich.utils.ip_in_issue')
def test_issue_d(host):
    f = host.file('/etc/issue.d')
    assert f.exists
    assert f.is_directory
    assert f.user == 'root'


@skip_unless_role('davedittrich.utils.ip_in_issue')
def test_issue_d_interfaces(host):
    f = host.file('/etc/issue.d/02-interfaces.issue')
    assert f.exists
    assert f.user == 'root'
    assert r' \4{' in f.content_string


@skip_unless_role('davedittrich.utils.ip_in_issue')
def test_issue_d_fingerprints(host):
    f = host.file('/etc/issue.d/01-ssh-fingerprints.issue')
    assert f.exists
    assert f.user == 'root'
    assert r' SHA256:' in f.content_string


# vim: set fileencoding=utf-8 ts=4 sw=4 tw=0 et :
