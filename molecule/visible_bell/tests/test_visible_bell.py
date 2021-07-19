import os
import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_inputrc(host):
    f = host.file(os.path.join(host.user().home, '.inputrc'))

    assert f.exists
    assert f.content_string.find(r'set prefer-visible-bell') > -1


def test_bashrc(host):
    f = host.file(os.path.join(host.user().home, '.bashrc'))

    assert f.exists
    assert f.content_string.find(r'set bellstyle visible') > -1


def test_cshrc(host):
    f = host.file(os.path.join(host.user().home, '.cshrc'))

    assert f.exists
    assert f.content_string.find(r'set visiblebell') > -1


def test_exrc(host):
    f = host.file(os.path.join(host.user().home, '.exrc'))

    assert f.exists
    assert r'set flash' in f.content_string


def test_vimrc(host):
    f = host.file(os.path.join(host.user().home, '.vimrc'))

    assert f.exists
    assert r'set vb t_vb=' in f.content_string
