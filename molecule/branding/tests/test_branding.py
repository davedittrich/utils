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


def test_wallpaper_image(host):
    f = host.file('/usr/share/lxde/wallpapers/custom-splash.jpg')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'


def test_wallpaper_setting(host):
    f = host.file('/root/.config/pcmanfm/LXDE/desktop-items-0.conf')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'
    assert r'custom-wallpaper.png' in f.content_string


def test_LXDE_autostart_xset(host):
    f = host.file('/root/.config/lxsession/LXDE/autostart')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'
    assert r'xset' in f.content_string
