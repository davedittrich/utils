import os
import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_hosts_file(host):
    f = host.file('/etc/hosts')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'


# TODO(dittrich): NOT DRY. Shared with ip_in_issue tests.
# Figure out how to include in common/ directory.


def test_issue_file(host):
    f = host.file('/etc/issue')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'
    assert r'This is \n.\O' in f.content_string


def test_issue_d_interfaces(host):
    f = host.file(os.path.join("/etc/issue.d/02-interfaces.issue"))

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'
    assert r' \4{' in f.content_string


def test_issue_d_fingerprints(host):
    f = host.file(os.path.join("/etc/issue.d/01-ssh-fingerprints.issue"))

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'
    assert r' SHA256:' in f.content_string


# TODO(dittrich): NOT DRY. Shared with ip_in_issue tests.
# Figure out how to include in common/ directory.


def test_udev_hwdb_file(host):
    f = host.file('/etc/udev/hwdb.d/99-swapcapslockctrl.hwdb')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'
    assert r'KEYBOARD_KEY_700E0=capslock' in f.content_string

