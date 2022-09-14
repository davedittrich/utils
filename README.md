# davedittrich.utils Collection for Ansible

Version: 0.6.0

[![CI](https://github.com/davedittrich/utils/workflows/release/badge.svg?event=push)](https://github.com/davedittrich/utils/actions)

An Ansible collection for my opinionated development workstation configuration and
prototyping Ansible (and non-Ansible) features for other Python packages and
Ansible collections.

This collection houses roles, playbooks, and other Ansible content suitable for
setting up standardized tooling and settings on development workstations. It also
facilitates automated configuration of other systems, like Raspberry Pi servers
and cloud instances for training labs or "capture the flag" contests.

The original design was influenced by the blog posts listed below in the
**See also** section by
[Jonas Hecht](https://blog.codecentric.de/en/author/jonas-hecht/) and
[Jeff Geerling](https://www.ansible.com/blog/author/jeff-geerling).

Development of this collection is supported by a test-driven design that uses
[`molecule`](https://molecule.readthedocs.io/en/latest/) to test any or all
roles, both locally and driven by GitHub Actions workflows on `push` actions.

The operating system distributions supported at this time by this collection
and its playbooks for `molecule` testing are:

- Debian 11 (default distribution)
- Ubuntu 22.04 LTS

The development environment and test infrastructure that invokes `molecule`
for testing has been tested on the following (in order of most-frequently
to least-frequently used):

- Mac OS X (Darwin) 10.15.7
- Ubuntu 20.04 LTS on Windows Subsystem for Linux (WSL) 2
- Kali (Debian 11) Linux (2022-07-07 release)

To help reduce the amount of time taken by all this testing, several optimization
techniques are employed:

1. Local testing during development is done against _only_ Debian 11. Once all
   tests are passing, the remaining OS distributions can then be selected for further
   compatibility testing.

2. Customized Docker images are used to pre-load packages expected to be on
   "production" systems. This significantly reduces the amount of time
   necessary to perform frequent tests by _only_ performing time-consuming package
   package installations and setup when you chose to do so (not every time a
   `molecule` instance is created.)

3. GitHub Action testing for release candidates on the `develop` branch and
   releases on the `main` branch are the only ones that test _all_ roles
   against _all_ distributions. When you `push` to a feature branch with a
   name related to the role you are developing (e.g., `feature/branding` for
   the `davedittrich.utils.branding` role), _only_ that role is tested against
   the distribution matrix. This reduces test time by only testing role-specific
   changes.

All of this comes at a cost, however. The use of custom Docker containers increases
your local disk storage, and there is a _lot_ of
non-[DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) repetition of logic,
code, and `molecule` configuration settings. This is partly a side-effect of the
limitations in modularity of GitHub Actions. Some repetition in `molecule`
configuration and tests has been reduced by modularity and cross-inclusion of code.

https://github.com/davedittrich/utils

## Using this collection

### Installing the Collection from Ansible Galaxy

Before using this collection, you need to install it with the Ansible Galaxy command-line tool:

```bash
ansible-galaxy collection install davedittrich.utils
```

You can also include it in a `requirements.yml` file and install it with
`ansible-galaxy collection install -r requirements.yml`, using the format:

```yaml
---
collections:
  - name: davedittrich.utils
```

Note that if you install the collection from Ansible Galaxy, it will not be upgraded automatically
when you upgrade the `ansible` package. To upgrade the collection to the latest available version,
run the following command:

```bash
ansible-galaxy collection install davedittrich.utils --upgrade
```

You can also install a specific version of the collection, for example if you need to downgrade
when something is broken in the latest version (please report an issue in this repository). Use
the following syntax to install version `0.1.0`:

```bash
ansible-galaxy collection install davedittrich.utils:==0.1.0
```

See [Ansible Using collections](https://docs.ansible.com/ansible/devel/user_guide/collections_using.html)
for more details.

### Tasks performed by role

Following is a high-level breakdown of tasks performed by role. This is not an
exhaustive list of all tasks, but rather a summary of the general topics:

#### [`davedittrich.utils.kali_like`](roles/kali_like/) role.

- Install base OS packages necessary for Kali tooling.
- Set up for installing packages from Kali repo.
- Install a specific subset of Kali packages.
- Hush the Kali developer login message.
- Install templated helper scripts for user convenience.
- Set up `~/.local/bin` directories in accounts for local add-on programs.
- Pre-configure Kali menus and desktop.
- Set host name based on system serial number.
- Install and configure system for Apache Guacamole (RDP in browser).
- Set custom timezone.

#### [`davedittrich.utils.branding`](roles/branding/) role.

- Make LXDE/`lightdm` default X11 session manager.
- Customize LXDE and `lightdm` settings and menus.
- Customize display wallpaper, login greeter background, and boot splash images.
- Disable boot logo (e.g., on Raspberry Pi devices.)
- Disable `clipit` history.

#### [`davedittrich.utils.ip_in_issue`](roles/ip_in_issue) role.

- Ensure SSH host key fingerprints are visible on console login screen.
- Ensure Ethernet device and IP addressing information is visible on console login screen.

#### [`davedittrich.utils.swapcapslockctrl`](roles/swapcapslockctrl) role.

- Swaps Left keyboard **CapsLock** key with **CTRL**.

#### [`davedittrich.utils.visible_bell`](roles/visible_bell) role.

- Disables bell sound for keyboard, `bash`, `csh`, `ex` family editors, `vim` editor
  and instead sets visible bell.

#### [`davedittrich.utils.dropins`](roles/dropins) role.

- Ensures `update-dotdee` is installed via `pipx`.
- Create initial dropin directories with original files appearing at top.
- By default, enabled use of `update-dotdee` to control users' `~/.bash_aliases`, `~/.bashrc`,
  `~/.gitconfig`, and `~/.ssh/config` files.

## Testing

For `molecule` tests to work on this collection without interfering with existing collections,
set up an alternate collections directory as follows:

```bash
$ tree -L 2 ~/.ansible/collections*
/Users/dittrich/.ansible/collections
└── ansible_collections
    ├── ansible
    └── community
/Users/dittrich/.ansible/collections.dev
└── ansible_collections
    └── davedittrich -> /Users/dittrich/code/davedittrich

6 directories, 0 files
```

You can create this link using the command `make create-collections-dev-link`.

The `provisioner` section in files like `molecule/default/molecule.yml` are then
configured as follows:

```yaml
provisioner:
  name: ansible
  env:
    ANSIBLE_VERBOSITY: ${ANSIBLE_VERBOSITY:-1}
    PYTHONPATH: "${PWD}"
  playbooks:
    converge: ${MOLECULE_PLAYBOOK:-converge.yml}
    prepare: ../shared/prepare.yml
    destroy: ../shared/destroy.yml
```

To reduce redundancy in code across multiple scenarios representing individual
roles in a larger collection, tests, variables, and functions are located in
the `molecule/shared` directory. As seen in the code example for the `provisioner`
section, the `PYTHONPATH` environment variable is set, allowing Python code
to be able to `import` from this module directory as seen here:

```python
from helpers import (
    ansible_vars,
    get_homedir,
    skip_unless_role,
)
```

The `verifier` phase includes everything from the shared directory by way
of relative paths, as seen here in a `molecule.yml` file:

```yaml
verifier:
  name: testinfra
  directory: ../shared/tests
  options:
    # Add a -v so you see the individual test names.
    v: true
  additional_files_or_dirs:
    - ../shared/*
```

To further reduce redundancy and hard-coding values in tests, all Ansible variables
that were defined during the `converge` phase are dumped to a file in the
`molecule` ephemeral directory for the scenario so they are available for use
by tests in the `verify` phase. The path to the file for the `default` scenario
would be `${HOME}/.config/molecule/utils/default/ansible-vars.yml`.


Tests can be skipped by use of the `@skip_unless_role()` decorator, which checks
to see if the role for which they apply is in the `ansible_roles_names` variable
(meaning that role was applied and thus needs testing).

```yaml
. . .
ansible_role_names: [davedittrich.utils.ip_in_issue]
. . .
```

Here is an example with a simple test.

```python
@skip_unless_role('davedittrich.utils.branding')
def test_boot_config(host):
    f = host.file('/boot/config.txt')
    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'
    assert r'disable_splash=1' in f.content_string
```

If the `ip_in_issue` role was being tested (as seen in the `ansible_role_names`
variable above), this particular test would be skipped.

```
$ make SCENARIO=ip_in_issue test
molecule test -s ip_in_issue
INFO     ip_in_issue scenario test matrix: dependency, lint, cleanup, destroy, syntax, create, prepare, converge, idempotence, side_effect, verify, cleanup, destroy
INFO     Performing prerun...
INFO     Guessed /Users/dittrich/git/davedittrich/utils as project root directory
INFO     Added ANSIBLE_LIBRARY=plugins/modules
INFO     Added ANSIBLE_COLLECTIONS_PATH=/Users/dittrich/.cache/ansible-lint/6dd05e/collections
INFO     Added ANSIBLE_ROLES_PATH=~/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles:roles
INFO     Running ip_in_issue > dependency
  . . .
INFO     Running ip_in_issue > verify                                                                                                                      [25/10379]
INFO     Executing Testinfra tests found in /Users/dittrich/git/davedittrich/utils/molecule/ip_in_issue/../shared/tests/...
============================= test session starts ==============================
platform darwin -- Python 3.9.5, pytest-6.2.4, py-1.10.0, pluggy-0.13.1 -- /usr/local/Caskroom/miniconda/base/envs/ansible/bin/python
metadata: {'Python': '3.9.5', 'Platform': 'macOS-10.14.6-x86_64-i386-64bit', 'Packages': {'pytest': '6.2.4', 'py': '1.10.0', 'pluggy': '0.13.1'}, 'Plugins':
{'cov': '2.12.1', 'metadata': '1.11.0', 'helpers-namespace': '0.0.0', 'xdist': '2.3.0', 'html': '3.1.1', 'mock': '3.6.1', 'plus': '0.2', 'verbose-parametrize':
'1.7.0', 'forked': '1.3.0', 'testinfra': '6.4.0'}}
rootdir: /Users/dittrich/git/davedittrich/utils, configfile: pytest.ini
plugins: cov-2.12.1, metadata-1.11.0, helpers-namespace-0.0.0, xdist-2.3.0, html-3.1.1, mock-3.6.1, plus-0.2, verbose-parametrize-1.7.0, forked-1.3.0, testinfra-6.4.0
collecting ... collected 20 items

molecule/shared/tests/test_branding.py::test_boot_config[ansible://instance] SKIPPED [  5%]
molecule/shared/tests/test_branding.py::test_boot_cmdline[ansible://instance] SKIPPED [ 10%]
molecule/shared/tests/test_branding.py::test_fbi[ansible://instance] SKIPPED [ 15%]
molecule/shared/tests/test_branding.py::test_splashscreen_service[ansible://instance] SKIPPED [ 20%]
molecule/shared/tests/test_branding.py::test_user_homedirs[ansible://instance] SKIPPED [ 25%]
molecule/shared/tests/test_branding.py::test_wallpaper_image[ansible://instance] SKIPPED [ 30%]
molecule/shared/tests/test_branding.py::test_wallpaper_setting[ansible://instance] SKIPPED [ 35%]
molecule/shared/tests/test_branding.py::test_LXDE_autostart_xset[ansible://instance] SKIPPED [ 40%]
molecule/shared/tests/test_dropins.py::test_dropin_directory[ansible://instance] SKIPPED [ 45%]
molecule/shared/tests/test_ip_in_issue.py::test_issue_file[ansible://instance] PASSED [ 50%]
molecule/shared/tests/test_ip_in_issue.py::test_issue_d[ansible://instance] PASSED [ 55%]
molecule/shared/tests/test_ip_in_issue.py::test_issue_d_interfaces[ansible://instance] PASSED [ 60%]
molecule/shared/tests/test_ip_in_issue.py::test_issue_d_fingerprints[ansible://instance] PASSED [ 65%]
molecule/shared/tests/test_shared.py::test_shared_skip SKIPPED (forc...) [ 70%]
molecule/shared/tests/test_swapcapslockctrl.py::test_udev_hwdb_file[ansible://instance] SKIPPED [ 75%]
molecule/shared/tests/test_visible_bell.py::test_inputrc[ansible://instance] SKIPPED [ 80%]
molecule/shared/tests/test_visible_bell.py::test_bashrc[ansible://instance] SKIPPED [ 85%]
molecule/shared/tests/test_visible_bell.py::test_cshrc[ansible://instance] SKIPPED [ 90%]
molecule/shared/tests/test_visible_bell.py::test_exrc[ansible://instance] SKIPPED [ 95%]
molecule/shared/tests/test_visible_bell.py::test_vimrc[ansible://instance] SKIPPED [100%]

=================== 4 passed, 16 skipped in 84.47s (0:01:24) ===================
INFO     Verifier completed successfully.
  . . .
```

The file containing the Ansible variables from the `converge` phase also help
in debugging playbooks. They provide "ground truth" of the Ansible runtime state
and help you identify variables to use in playbooks and tests, or to watch
while running tests in a debugger. (There is a `pytest` launch rule for
VSCode defined in the `.vscode/launch.json` file.)

To continue on to testing in `molecule`, you can manually run `molecule
verify`.  The variables are loaded from the cached file and are available to
tests. This allows you to redefine some variables during development, re-run
`molecule converge` to have them take effect, and your tests can then
automatically adjust.

Only when `molecule destroy` is run will the file be deleted.

```
  . . .
INFO     Running ip_in_issue > destroy
Using /Users/dittrich/.cache/molecule/utils/ip_in_issue/ansible.cfg as config file

PLAY [Destroy] *****************************************************************

TASK [Delete variables saved from converge step.] ******************************
ok: [instance -> localhost] => {"changed": false, "path": "/Users/dittrich/.cache/molecule/utils/ip_in_issue/ansible-vars.yml", "state": "absent"}

PLAY RECAP *********************************************************************
instance                   : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
  . . .
```

You can see the defined scenarios and state information about related instances
with `molecule list`:

```
$ molecule list
INFO     Running branding > list
INFO     Running default > list
INFO     Running delegated > list
INFO     Running dropins > list
INFO     Running ip_in_issue > list
INFO     Running swapcapslockctrl > list
INFO     Running visible_bell > list
                 ╷             ╷                  ╷                  ╷         ╷
  Instance Name  │ Driver Name │ Provisioner Name │ Scenario Name    │ Created │ Converged
╶────────────────┼─────────────┼──────────────────┼──────────────────┼─────────┼───────────╴
  instance       │ docker      │ ansible          │ branding         │ false   │ false
  instance       │ docker      │ ansible          │ default          │ true    │ false
  delegated-host │ delegated   │ ansible          │ delegated        │ unknown │ true
  instance       │ docker      │ ansible          │ dropins          │ false   │ false
  instance       │ docker      │ ansible          │ ip_in_issue      │ false   │ false
  instance       │ docker      │ ansible          │ swapcapslockctrl │ false   │ false
  instance       │ docker      │ ansible          │ visible_bell     │ false   │ false
                 ╵             ╵                  ╵                  ╵         ╵
```

(Hint: The above shows the `default` scenario is running, with the instance `created`,
but not yet `converged`.)

When using the `delegated` scenario--in this case against a Raspberry Pi with users
`root` and `pirate`--all of the roles and their associated tests for all users
will be applied:

```
$ make SCENARIO=delegated verify
molecule verify -s delegated
INFO     delegated scenario test matrix: verify
INFO     Performing prerun...
INFO     Guessed /Users/dittrich/git/davedittrich/utils as project root directory
INFO     Added ANSIBLE_LIBRARY=plugins/modules
INFO     Added ANSIBLE_COLLECTIONS_PATH=/Users/dittrich/.cache/ansible-lint/6dd05e/collections
INFO     Added ANSIBLE_ROLES_PATH=~/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles:roles
INFO     Running delegated > verify
INFO     Executing Testinfra tests found in /Users/dittrich/git/davedittrich/utils/molecule/delegated/../shared/tests/...
============================= test session starts ==============================
platform darwin -- Python 3.9.5, pytest-6.2.4, py-1.10.0, pluggy-0.13.1 -- /usr/local/Caskroom/miniconda/base/envs/ansible/bin/python
metadata: {'Python': '3.9.5', 'Platform': 'macOS-10.14.6-x86_64-i386-64bit', 'Packages': {'pytest': '6.2.4', 'py': '1.10.0', 'pluggy':
'0.13.1'}, 'Plugins': {'cov': '2.12.1', 'metadata': '1.11.0', 'helpers-namespace': '0.0.0', 'xdist': '2.3.0', 'html': '3.1.1', 'mock':
'3.6.1', 'plus': '0.2', 'verbose-parametrize': '1.7.0', 'forked': '1.3.0', 'testinfra': '6.4.0'}}
rootdir: /Users/dittrich
plugins: cov-2.12.1, metadata-1.11.0, helpers-namespace-0.0.0, xdist-2.3.0, html-3.1.1, mock-3.6.1, plus-0.2, verbose-parametrize-1.7.0,
forked-1.3.0, testinfra-6.4.0
collecting ... collected 106 items

molecule/shared/tests/test_branding.py::test_boot_config[ansible:/delegated-host] PASSED [  0%]
molecule/shared/tests/test_branding.py::test_boot_cmdline[ansible:/delegated-host] PASSED [  1%]
molecule/shared/tests/test_branding.py::test_fbi_package[ansible:/delegated-host] PASSED [  2%]
molecule/shared/tests/test_branding.py::test_splashscreen_service[ansible:/delegated-host] PASSED [  3%]
molecule/shared/tests/test_branding.py::test_user_homedir[ansible:/delegated-host-root] PASSED [  4%]
molecule/shared/tests/test_branding.py::test_user_homedir[ansible:/delegated-host-pirate] PASSED [  5%]
molecule/shared/tests/test_branding.py::test_x11_session_manager_is_lxde[ansible:/delegated-host] PASSED [  6%]
molecule/shared/tests/test_branding.py::test_wallpaper_image[ansible:/delegated-host] PASSED [  7%]
molecule/shared/tests/test_branding.py::test_user_wallpaper_setting[ansible:/delegated-host-root] XFAIL [  8%]
molecule/shared/tests/test_branding.py::test_user_wallpaper_setting[ansible:/delegated-host-pirate] XFAIL [  9%]
molecule/shared/tests/test_branding.py::test_lightdm_login_background[ansible:/delegated-host] PASSED [ 10%]
molecule/shared/tests/test_branding.py::test_config_files[root-user-dirs.dirs.j20-ansible:/delegated-host] PASSED [ 11%]
molecule/shared/tests/test_branding.py::test_config_files[root-user-dirs.locale.j20-ansible:/delegated-host] PASSED [ 12%]
molecule/shared/tests/test_branding.py::test_config_files[root-gtk-3.0/bookmarks.j20-ansible:/delegated-host] PASSED [ 13%]
molecule/shared/tests/test_branding.py::test_config_files[root-qt5ct/qt5ct.conf.j20-ansible:/delegated-host] PASSED [ 14%]
molecule/shared/tests/test_branding.py::test_config_files[root-lxterminal/lxterminal.conf.j20-ansible:/delegated-host] PASSED [ 15%]
molecule/shared/tests/test_branding.py::test_config_files[root-lxsession/LXDE/desktop.conf.j20-ansible:/delegated-host] PASSED [ 16%]
molecule/shared/tests/test_branding.py::test_config_files[root-lxsession/LXDE/autostart.j20-ansible:/delegated-host] PASSED [ 16%]
molecule/shared/tests/test_branding.py::test_config_files[root-pcmanfm/LXDE/desktop-items-0.conf.j20-ansible:/delegated-host] PASSED [ 17%]
molecule/shared/tests/test_branding.py::test_config_files[root-lxpanel/launchtaskbar.cfg.j20-ansible:/delegated-host] PASSED [ 18%]
molecule/shared/tests/test_branding.py::test_config_files[root-lxpanel/LXDE/panels/panel.j20-ansible:/delegated-host] PASSED [ 19%]
molecule/shared/tests/test_branding.py::test_config_files[root-openbox/lxde-rc.xml.j20-ansible:/delegated-host] PASSED [ 20%]
molecule/shared/tests/test_branding.py::test_config_files[root-clipit/disabled.j20-ansible:/delegated-host] PASSED [ 21%]
molecule/shared/tests/test_branding.py::test_config_files[root-libfm/libfm.conf.j20-ansible:/delegated-host] PASSED [ 22%]
molecule/shared/tests/test_branding.py::test_config_files[root-user-dirs.dirs.j21-ansible:/delegated-host] PASSED [ 23%]
molecule/shared/tests/test_branding.py::test_config_files[root-user-dirs.locale.j21-ansible:/delegated-host] PASSED [ 24%]
molecule/shared/tests/test_branding.py::test_config_files[root-gtk-3.0/bookmarks.j21-ansible:/delegated-host] PASSED [ 25%]
molecule/shared/tests/test_branding.py::test_config_files[root-qt5ct/qt5ct.conf.j21-ansible:/delegated-host] PASSED [ 26%]
molecule/shared/tests/test_branding.py::test_config_files[root-lxterminal/lxterminal.conf.j21-ansible:/delegated-host] PASSED [ 27%]
molecule/shared/tests/test_branding.py::test_config_files[root-lxsession/LXDE/desktop.conf.j21-ansible:/delegated-host] PASSED [ 28%]
molecule/shared/tests/test_branding.py::test_config_files[root-lxsession/LXDE/autostart.j21-ansible:/delegated-host] PASSED [ 29%]
molecule/shared/tests/test_branding.py::test_config_files[root-pcmanfm/LXDE/desktop-items-0.conf.j21-ansible:/delegated-host] PASSED [ 30%]
molecule/shared/tests/test_branding.py::test_config_files[root-lxpanel/launchtaskbar.cfg.j21-ansible:/delegated-host] PASSED [ 31%]
molecule/shared/tests/test_branding.py::test_config_files[root-lxpanel/LXDE/panels/panel.j21-ansible:/delegated-host] PASSED [ 32%]
molecule/shared/tests/test_branding.py::test_config_files[root-openbox/lxde-rc.xml.j21-ansible:/delegated-host] PASSED [ 33%]
molecule/shared/tests/test_branding.py::test_config_files[root-clipit/disabled.j21-ansible:/delegated-host] PASSED [ 33%]
molecule/shared/tests/test_branding.py::test_config_files[root-libfm/libfm.conf.j21-ansible:/delegated-host] PASSED [ 34%]
molecule/shared/tests/test_branding.py::test_config_files[pirate-user-dirs.dirs.j20-ansible:/delegated-host] PASSED [ 35%]
molecule/shared/tests/test_branding.py::test_config_files[pirate-user-dirs.locale.j20-ansible:/delegated-host] PASSED [ 36%]
molecule/shared/tests/test_branding.py::test_config_files[pirate-gtk-3.0/bookmarks.j20-ansible:/delegated-host] PASSED [ 37%]
molecule/shared/tests/test_branding.py::test_config_files[pirate-qt5ct/qt5ct.conf.j20-ansible:/delegated-host] PASSED [ 38%]
molecule/shared/tests/test_branding.py::test_config_files[pirate-lxterminal/lxterminal.conf.j20-ansible:/delegated-host] PASSED [ 39%]
molecule/shared/tests/test_branding.py::test_config_files[pirate-lxsession/LXDE/desktop.conf.j20-ansible:/delegated-host] PASSED [ 40%]
molecule/shared/tests/test_branding.py::test_config_files[pirate-lxsession/LXDE/autostart.j20-ansible:/delegated-host] PASSED [ 41%]
molecule/shared/tests/test_branding.py::test_config_files[pirate-pcmanfm/LXDE/desktop-items-0.conf.j20-ansible:/delegated-host] PASSED [ 42%]
molecule/shared/tests/test_branding.py::test_config_files[pirate-lxpanel/launchtaskbar.cfg.j20-ansible:/delegated-host] PASSED [ 43%]
molecule/shared/tests/test_branding.py::test_config_files[pirate-lxpanel/LXDE/panels/panel.j20-ansible:/delegated-host] PASSED [ 44%]
molecule/shared/tests/test_branding.py::test_config_files[pirate-openbox/lxde-rc.xml.j20-ansible:/delegated-host] PASSED [ 45%]
molecule/shared/tests/test_branding.py::test_config_files[pirate-clipit/disabled.j20-ansible:/delegated-host] PASSED [ 46%]
molecule/shared/tests/test_branding.py::test_config_files[pirate-libfm/libfm.conf.j20-ansible:/delegated-host] PASSED [ 47%]
molecule/shared/tests/test_branding.py::test_config_files[pirate-user-dirs.dirs.j21-ansible:/delegated-host] PASSED [ 48%]
molecule/shared/tests/test_branding.py::test_config_files[pirate-user-dirs.locale.j21-ansible:/delegated-host] PASSED [ 49%]
molecule/shared/tests/test_branding.py::test_config_files[pirate-gtk-3.0/bookmarks.j21-ansible:/delegated-host] PASSED [ 50%]
molecule/shared/tests/test_branding.py::test_config_files[pirate-qt5ct/qt5ct.conf.j21-ansible:/delegated-host] PASSED [ 50%]
molecule/shared/tests/test_branding.py::test_config_files[pirate-lxterminal/lxterminal.conf.j21-ansible:/delegated-host] PASSED [ 51%]
molecule/shared/tests/test_branding.py::test_config_files[pirate-lxsession/LXDE/desktop.conf.j21-ansible:/delegated-host] PASSED [ 52%]
molecule/shared/tests/test_branding.py::test_config_files[pirate-lxsession/LXDE/autostart.j21-ansible:/delegated-host] PASSED [ 53%]
molecule/shared/tests/test_branding.py::test_config_files[pirate-pcmanfm/LXDE/desktop-items-0.conf.j21-ansible:/delegated-host] PASSED [ 54%]
molecule/shared/tests/test_branding.py::test_config_files[pirate-lxpanel/launchtaskbar.cfg.j21-ansible:/delegated-host] PASSED [ 55%]
molecule/shared/tests/test_branding.py::test_config_files[pirate-lxpanel/LXDE/panels/panel.j21-ansible:/delegated-host] PASSED [ 56%]
molecule/shared/tests/test_branding.py::test_config_files[pirate-openbox/lxde-rc.xml.j21-ansible:/delegated-host] PASSED [ 57%]
molecule/shared/tests/test_branding.py::test_config_files[pirate-clipit/disabled.j21-ansible:/delegated-host] PASSED [ 58%]
molecule/shared/tests/test_branding.py::test_config_files[pirate-libfm/libfm.conf.j21-ansible:/delegated-host] PASSED [ 59%]
molecule/shared/tests/test_dropins.py::test_bashrc_sources_aliases[root-ansible:/delegated-host] PASSED [ 60%]
molecule/shared/tests/test_dropins.py::test_bashrc_sources_aliases[pirate-ansible:/delegated-host] PASSED [ 61%]
molecule/shared/tests/test_dropins.py::test_dropin_files[root-.bash_profile-ansible:/delegated-host] PASSED [ 62%]
molecule/shared/tests/test_dropins.py::test_dropin_files[root-.bash_aliases-ansible:/delegated-host] PASSED [ 63%]
molecule/shared/tests/test_dropins.py::test_dropin_files[root-.gitconfig-ansible:/delegated-host] PASSED [ 64%]
molecule/shared/tests/test_dropins.py::test_dropin_files[root-.ssh/config-ansible:/delegated-host] PASSED [ 65%]
molecule/shared/tests/test_dropins.py::test_dropin_files[pirate-.bash_profile-ansible:/delegated-host] PASSED [ 66%]
molecule/shared/tests/test_dropins.py::test_dropin_files[pirate-.bash_aliases-ansible:/delegated-host] PASSED [ 66%]
molecule/shared/tests/test_dropins.py::test_dropin_files[pirate-.gitconfig-ansible:/delegated-host] PASSED [ 67%]
molecule/shared/tests/test_dropins.py::test_dropin_files[pirate-.ssh/config-ansible:/delegated-host] PASSED [ 68%]
molecule/shared/tests/test_dropins.py::test_dropin_directories[root-.bash_profile-ansible:/delegated-host] PASSED [ 69%]
molecule/shared/tests/test_dropins.py::test_dropin_directories[root-.bash_aliases-ansible:/delegated-host] PASSED [ 70%]
molecule/shared/tests/test_dropins.py::test_dropin_directories[root-.gitconfig-ansible:/delegated-host] PASSED [ 71%]
molecule/shared/tests/test_dropins.py::test_dropin_directories[root-.ssh/config-ansible:/delegated-host] PASSED [ 72%]
molecule/shared/tests/test_dropins.py::test_dropin_directories[pirate-.bash_profile-ansible:/delegated-host] PASSED [ 73%]
molecule/shared/tests/test_dropins.py::test_dropin_directories[pirate-.bash_aliases-ansible:/delegated-host] PASSED [ 74%]
molecule/shared/tests/test_dropins.py::test_dropin_directories[pirate-.gitconfig-ansible:/delegated-host] PASSED [ 75%]
molecule/shared/tests/test_dropins.py::test_dropin_directories[pirate-.ssh/config-ansible:/delegated-host] PASSED [ 76%]
molecule/shared/tests/test_dropins.py::test_pipx[root-pipx-ansible:/delegated-host] PASSED [ 77%]
molecule/shared/tests/test_dropins.py::test_pipx[root-update-dotdee-ansible:/delegated-host] PASSED [ 78%]
molecule/shared/tests/test_dropins.py::test_pipx[pirate-pipx-ansible:/delegated-host] PASSED [ 79%]
molecule/shared/tests/test_dropins.py::test_pipx[pirate-update-dotdee-ansible:/delegated-host] PASSED [ 80%]
molecule/shared/tests/test_dropins.py::test_update_dotdee_write_bash_profile[root-ansible:/delegated-host] PASSED [ 81%]
molecule/shared/tests/test_dropins.py::test_update_dotdee_write_bash_profile[pirate-ansible:/delegated-host] PASSED [ 82%]
molecule/shared/tests/test_ip_in_issue.py::test_issue_file[ansible:/delegated-host] PASSED [ 83%]
molecule/shared/tests/test_ip_in_issue.py::test_issue_d[ansible:/delegated-host] PASSED [ 83%]
molecule/shared/tests/test_ip_in_issue.py::test_issue_d_interfaces[ansible:/delegated-host] PASSED [ 84%]
molecule/shared/tests/test_ip_in_issue.py::test_issue_d_fingerprints[ansible:/delegated-host] PASSED [ 85%]
molecule/shared/tests/test_shared.py::test_shared_skip SKIPPED (forc...) [ 86%]
molecule/shared/tests/test_swapcapslockctrl.py::test_udev_package[ansible:/delegated-host] PASSED [ 87%]
molecule/shared/tests/test_swapcapslockctrl.py::test_udev_hwdb_file[ansible:/delegated-host] PASSED [ 88%]
molecule/shared/tests/test_swapcapslockctrl.py::test_xkboptions[ansible:/delegated-host] PASSED [ 89%]
molecule/shared/tests/test_swapcapslockctrl.py::test_keyboard_configuration[ansible:/delegated-host] PASSED [ 90%]
molecule/shared/tests/test_visible_bell.py::test_inputrc[ansible:/delegated-host-root] PASSED [ 91%]
molecule/shared/tests/test_visible_bell.py::test_inputrc[ansible:/delegated-host-pirate] PASSED [ 92%]
molecule/shared/tests/test_visible_bell.py::test_bashrc[ansible:/delegated-host-root] PASSED [ 93%]
molecule/shared/tests/test_visible_bell.py::test_bashrc[ansible:/delegated-host-pirate] PASSED [ 94%]
molecule/shared/tests/test_visible_bell.py::test_cshrc[ansible:/delegated-host-root] PASSED [ 95%]
molecule/shared/tests/test_visible_bell.py::test_cshrc[ansible:/delegated-host-pirate] PASSED [ 96%]
molecule/shared/tests/test_visible_bell.py::test_exrc[ansible:/delegated-host-root] PASSED [ 97%]
molecule/shared/tests/test_visible_bell.py::test_exrc[ansible:/delegated-host-pirate] PASSED [ 98%]
molecule/shared/tests/test_visible_bell.py::test_vimrc[ansible:/delegated-host-root] PASSED [ 99%]
molecule/shared/tests/test_visible_bell.py::test_vimrc[ansible:/delegated-host-pirate] PASSED [100%]

============ 103 passed, 1 skipped, 2 xfailed in 116.30s (0:01:56) =============
INFO     Verifier completed successfully.
```

## Gotchas

When developing and testing your new roles, you may find that some Ansible plays
cause idempotence tests to fail. Here are some of the causes and solutions.

- More than one role may attempt to manage the same file in the file system. This
  can cause problems when one play copies or templates an entire file, while another
  uses `ansible.builtin.blockinfile` or `ansible.builtin.lineinfile`. This can cause
  the file _contents_ to change back and forth. Closely examine the plays that fail
  idempotence tests to see what file the change and how. You may need to change the
  order of the roles, change the way the file contents are modified, change the
  markers in `blockinfile` plays to be more unique.

- Idempotence failures can also be caused by changes in file _metadata_ rather than
  contents. The most common reason for this is different `mode` values in two or
  more plays that manage the same file. This can result in the mode changing
  back and forth between the different values, even when the content remains exactly
  the same. Avoid setting the `mode` or `group` unless you know it is necessary (e.g.,
  when `ansible-lint` tells you that a newly created file may end up with insecure
  settings.) Use `molecule converge` to get all the plays to be run, followed by
  `molecule login` to log into the instance to check file contents and/or file
  system metadata. Running `molecule verify` will run the tests again to debug
  your plays.

- "FOSS-rot". Yes, I said it. Like most popular open source projects, anything
  you write for or with Ansible will, after a few months, simply fail because of
  breaking changes in Ansible, community collections and roles, and related software
  like `molecule`, `testinfra`, and Docker is also part of this particular problem.

  I hadn't touched this collection in many months and when I came back to it to
  continue developing, several things failed that used to work perfectly fine. The
  most critical of these was the installation of packages with APT in `molecule`'s
  Docker containers. This collection custom-builds Docker images from `geerlingguy`'s
  Docker images that supported everyone's most favorite (for this same reason!)
  Linux love-child, `systemd`.

  As of 2022-07-02, tasks using the `ansible.builtin.apt` module or
  `ansible.builtin.shell` running `apt` or `apt-get` began to fail with::

      E: Sub-process /usr/bin/dpkg returned an error code (1)
      . . .
      Failed to connect to bus: No such file or directory
      dpkg: error processing package libc6:amd64 (--configure): installed libc6:amd64 package post-installation script subprocess returned error exit status 1
      Errors were encountered while processing: libc6:amd64

  While many people suggest adding `"deprecatedCgroupv1": true` to (on a Mac) the
  `~/Library/Group Containers/group.com.docker/settings.json` file, disabling `cgroupv2`
  and sticking with the previously working `cgroupv1`. While this may work, generally
  staying behind on versions can be a security risk or eventually fail entirely due to
  deprecated features finally being removed, so the more optimal solution appears to be
  adding `"default-cgroupns-mode": "host",` to the Docker Engine configuration settings
  and restarting the Docker daemon.

  See:

      * https://github.com/docker/for-mac/issues/6073#issuecomment-990718272
      * https://github.com/Rosa-Luxemburgstiftung-Berlin/ansible-role-unbound/blob/main/molecule/default/Dockerfile-debian-bullseye.j2
      * https://github.com/geerlingguy/docker-debian11-ansible/issues/4

  P.S. [2022-08-26] It turns out there were _several_ inter-related issues that
  conspired to break things and cost weeks in debugging, partly due to the
  requirement of 10-15 minutes per test cycle to run the full test suite to
  resolve the Debian+`systemd`+`libcrypt1`+Docker+... issues. These were
  (for historical and SEO purposes):

  - Debian packages changed such that updates completely broke package
    installation due to `libcrypt.so.1` being deleted while `dpkg`
    was updating packages using `perl-base`, which depends on it still
    being there.

        + https://www.youtube.com/watch?v=bbuoHXaNsUg

    While trying to debug this issue, errors about failures to connect to
    `dbus` occured, but it wasn't clear exactly why. At first it seemed
    to be a result of...

  - Docker on Mac switched to using `cgroupns` V2, which required configuring
    Docker's `daemon.json` file to include setting `cgroupns` to `host`. Not
    only that, but...

  - `systemd` v248 broke Docker's volume mounts of `/sys/fs/cgroup`, requiring
    changes to `molecule` to allow setting `cgroupns=host` and changing the
    mounts from `ro` to `rw`.

        + https://github.com/geerlingguy/docker-ubuntu2204-ansible/issues/2#issuecomment-1110602354
        + https://github.com/johanssone/ansible-unbound/commit/ec3cbb8440109f13d33a057801c7b65bb1b58095
        + https://github.com/ansible-collections/community.docker/issues/338

  - Around the same time, `molecule` changed its package dependencies, causing
    `pytest` and `testinfra` to break. Updating `molecule` only to the version
    that fixed the `cgroupns` problem broke the `lint` and `verify` stages.

  There is a also a number of issues with incompatible versions of `ansible`,
  `ansible-core`, `ansible-lint`, and maybe also `testinfra` and `pytest`?
  It is always frustrating to see responses from RedHat like the closing
  comment on [this thread](https://github.com/ansible-community/ansible-lint-action/issues/41#issuecomment-933663572),
  but it seems to mean you have to avoid (at all cost?) pinning specific
  versions of any of the above listed `pip` packages and instead _only_
  specify the version number of `ansible` (in this case, `==2.9.26`) and
  and follow `thestevenbell`'s recommendation. Using `2.9.27` fails
  with the error described and the RedHat response doesn't really help
  explain "best-practice" for avoiding this problem.

  Sigh. (At least everything seems to be stable again. For now...)

## See also

- [Test-driven infrastructure development with Ansible & Molecule](https://blog.codecentric.de/en/2018/12/test-driven-infrastructure-ansible-molecule/), by Jonas Hecht, December 4, 2018
- [Continuous Infrastructure with Ansible, Molecule & TravisCI](https://blog.codecentric.de/en/2018/12/continuous-infrastructure-ansible-molecule-travisci/), by Jonas Hecht, December 11, 2018
- [Make your Ansible Playbooks flexible, maintainable, and scalable](https://www.ansible.com/blog/make-your-ansible-playbooks-flexible-maintainable-and-scalable),
  by Jeff Geerling, September 28, 2018
- [Testing Ansible automation with molecule](https://redhatnordicssa.github.io/how-we-test-our-roles), by Peter Gustafsson, March 4, 2019
- [Question: accessing values of variables as they are being used for provisioning an instance inside Testinfra tests #151](https://github.com/ansible-community/molecule/issues/151), April 5, 2016
- [Using Ansible Molecule to test roles in monorepo](https://mariarti0644.medium.com/using-ansible-molecule-to-test-roles-in-monorepo-5f711c716666), by Maria Kotlyarevskaya, Mar 13, 2021
- [`test infra` modules](https://testinfra.readthedocs.io/en/latest/modules.html)

## Release notes

See the [changelog](https://github.com/davedittrich/utils/tree/main/CHANGELOG.rst).

## Code of Conduct

We follow the [Ansible Code of
Conduct](https://docs.ansible.com/ansible/devel/community/code_of_conduct.html)
in all our interactions within this project.

If you encounter abusive behavior, please refer to the [policy
violations](https://docs.ansible.com/ansible/devel/community/code_of_conduct.html#policy-violations)
section of the Code for information on how to raise a complaint.

## Licensing

Apache 2.0 License

See [LICENSE](LICENSE.txt) to see the full text.

## Author

Dave Dittrich < dave.dittrich@gmail.com > (https://github.com/davedittrich/utils)
