import os
import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')

def test_boot_config(host):
    f = host.file('/boot/config.txt')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'
    assert r'disable_splash=1' in f.content_string


def test_boot_cmdline(host):
    f = host.file('/boot/cmdline.txt')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'
    assert r'logo.nologo' in f.content_string


def test_fbi(host):
    assert host.package('fbi').is_installed


def test_splashscreen_service(host):
    splashscreen_service = host.service('splashscreen')
    assert splashscreen_service.is_enabled is True


def test_wallpaper(host):
    f = host.file('/usr/share/lxde/wallpapers/custom-splash.jpg')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'
