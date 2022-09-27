# davedittrich.utils Collection for Ansible

Version: 0.7.0-rc.82

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

The operating system distributions supported at this time by the full set of
roles in this collection for `molecule` testing are:

- Debian 11 (default distribution)
- Ubuntu 22.04 LTS

The development environment and test infrastructure that invokes `molecule`
for testing has been tested on the following (in order of most-frequently
to least-frequently used):

- Mac OS X (Darwin) 10.15.7
- Ubuntu 20.04 LTS on Windows Subsystem for Linux v2 (WSL2)
- Kali Linux (Debian 11 experimental, 2022-07-07 release)
- HypriotOS v1.12.3 (Debian 10, w/o `kali_like` role))


To help reduce the amount of time taken by all this testing, some optimization
techniques are employed:

1. Local testing during development is done against _only_ Debian 11. Once all
   tests are passing, the remaining OS distributions can then be selected for further
   compatibility testing.

2. Testing of all roles except `kali_like` (which requires Debian 11) are done
   using Raspberry Pi 3 and 4 systems using Hypriot's custom Debian 10 images
   flashed with a modified version of Hypriot's `flash` program (found in the
   [`hypriot` directory](hypriot/).

3. GitHub Action testing for release candidates on the `develop` branch and
   releases on the `main` branch are the only ones that test _all_ roles
   against multiple distributions. When you `push` to a feature branch with a
   name related to the role you are developing (e.g., `feature/branding` for
   the `davedittrich.utils.branding` role), _only_ that role is tested against
   the distribution matrix. This reduces test time by only testing role-specific
   changes.

All of this comes at a cost, however.  There is a _lot_ of
non-[DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) repetition of logic,
code, and `molecule` configuration settings. Some of the non-DRY aspects of GitHub
Actions workflows could be reduced by refactoring so as to
[share workflows](https://docs.github.com/en/actions/using-workflows/sharing-workflows-secrets-and-runners-with-your-organization).
Some repetition in `molecule` configuration and tests has been reduced by
modularity and cross-inclusion of testing code.

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

#### [`davedittrich.utils.kdmt`](roles/kdmt) role.

- Swaps Left keyboard **CapsLock** key with **CTRL**.
- Disables bell sound for keyboard, `bash`, `csh`, `ex` family editors, `vim` editor
  and instead sets visible bell.
- Enables "natural scrolling" on mouse and trackpad.
- Configures `hid_apple` keyboard devices to use function keys without needing `Fn` key.

#### [`davedittrich.utils.dropins`](roles/dropins) role.

- Ensures `update-dotdee` is installed via `pipx`.
- Create initial dropin directories with original files appearing at top.
- By default, enabled use of `update-dotdee` to control users' `~/.bash_aliases`, `~/.bashrc`,
  `~/.gitconfig`, and `~/.ssh/config` files.

## Testing

To reduce redundancy in code across multiple scenarios representing individual
roles in a larger collection, tests, variables, and functions are located in
the `molecule/shared` directory.

```
$ tree molecule/shared
molecule/shared
├── cleanup.yml
├── Dockerfile-debian_bullseye.j2
├── files
│   ├── cmdline.txt
│   ├── config.txt
│   └── Hello_World.jpg
├── __init__.py
├── prepare.yml
├── pytest.ini
├── tasks
│   └── fix_systemctl.yml
└── tests
    ├── conftest.py
    ├── helpers
    │   └── __init__.py
    ├── __init__.py
    ├── test_branding.py
    ├── test_dropins.py
    ├── test_ip_in_issue.py
    ├── test_kali_like.py
    ├── test_kdmt.py
    └── test_shared.py

4 directories, 18 files
```

The directory `molecule/shared/tests/helpers/` contains shared variables and
functions used by the tests (as opposed to using `conftest.py`) as seen here:


```python
from helpers import (
    ansible_vars,
    get_homedir,
    skip_unless_role,
)
```

The `verifier` section in files like `molecule/default/molecule.yml` are
configured as follows to allow the import to work:

```yaml
verifier:
  name: testinfra
  directory: ../shared/tests
  env:
    PYTHONPATH: "${PWD}/molecule/shared/tests"
    #PYTEST_ADDOPTS: "--debug -v -ra --trace-config"
    PYTEST_ADDOPTS: "-v -ra"
```

When debugging exceptions during the `verify` stage, you may want to swap the
`PYTEST_ADDOPTS` settings.

To further reduce redundancy and hard-coding values in tests, all Ansible
variables that were defined during the `converge` phase are dumped to a YAML
file in the `molecule` scenario's ephemeral directory so they are available to
tests in the `verify` stage. The path to the file for the `default` scenario
would be `${HOME}/.config/molecule/utils/default/ansible-vars.yml`.

It is possible to conditionally call `pytest.xfail()` based on these variables.
Tests can also be skipped by use of the `@skip_unless_role()` decorator, which
checks to see if the role for which they apply is in the `ansible_roles_names`
variable (meaning that role was applied and thus needs testing).


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

If the `ip_in_issue` scenario was being tested, which only includes the
`davedittrich.utils.ip_in_issue` role (as seen in the `ansible_role_names`
variable above), this particular test would be skipped.

```
$ make SCENARIO=ip_in_issue test
[+] using 'conda' environment 'utils' and 'psec' environment 'utils'
molecule test --destroy=never -s ip_in_issue
INFO     ip_in_issue scenario test matrix: dependency, lint, create, prepare, converge, idempotence, verify
INFO     Performing prerun with role_name_check=0...
INFO     Set ANSIBLE_LIBRARY=/home/dittrich/.cache/ansible-compat/6fd897/modules:/home/dittrich/.ansible/plugins/modules:/usr/share/ansible/plugins/modules
INFO     Set ANSIBLE_COLLECTIONS_PATH=/home/dittrich/.cache/ansible-compat/6fd897/collections:/home/dittrich/.ansible/collections:/usr/share/ansible/collections
INFO     Set ANSIBLE_ROLES_PATH=/home/dittrich/.cache/ansible-compat/6fd897/roles:roles:/home/dittrich/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles
INFO     Running ansible-galaxy collection install -v --force -p /home/dittrich/.cache/ansible-compat/6fd897/collections .
INFO     Running ip_in_issue > dependency
  . . .
INFO     Idempotence completed successfully.
INFO     Running ip_in_issue > verify
INFO     Executing Testinfra tests found in /home/dittrich/code/davedittrich/utils/molecule/ip_in_issue/../shared/tests/...
/home/dittrich/miniconda3/envs/utils/lib/python3.9/site-packages/molecule/config.py:51: DeprecationWarning: molecule.config.ansible_version is deprecated, will be removed in the future.
  warnings.warn(
============================= test session starts ==============================
platform linux -- Python 3.9.13, pytest-7.1.3, pluggy-1.0.0 -- /home/dittrich/miniconda3/envs/utils/bin/python
metadata: {'Python': '3.9.13', 'Platform': 'Linux-5.18.0-kali7-amd64-x86_64-with-glibc2.34', 'Packages': {'pytest': '7.1.3', 'py': '1.11.0', 'pluggy': '1.0.0', 'molecule': '4.0.2.dev19'}, 'Plugins': {'ansible': '2.3.0', 'metadata':
 '2.0.2', 'testinfra': '6.8.1.dev4+gd423e29', 'html': '3.1.1', 'molecule': '2.0.1.dev8+g236ac70'}, 'Tools': {'ansible': '2.13.3'}, 'env': 'ANSIBLE_COLLECTIONS_PATH=/home/dittrich/.cache/ansible-compat/6fd897/collections:/home/dittr
ich/.cache/molecule/utils/ip_in_issue/collections:/home/dittrich/.ansible/collections:/usr/share/ansible/collections:/etc/ansible/collections ANSIBLE_CONFIG=/home/dittrich/.cache/molecule/utils/ip_in_issue/ansible.cfg ANSIBLE_FILTE
R_PLUGINS=/home/dittrich/miniconda3/envs/utils/lib/python3.9/site-packages/molecule/provisioner/ansible/plugins/filter:/home/dittrich/.cache/molecule/utils/ip_in_issue/plugins/filter:/home/dittrich/code/davedittrich/utils/plugins/f
ilter:/home/dittrich/.ansible/plugins/filter:/usr/share/ansible/plugins/filter ANSIBLE_FORCE_COLOR=True ANSIBLE_LIBRARY=/home/dittrich/miniconda3/envs/utils/lib/python3.9/site-packages/molecule/provisioner/ansible/plugins/modules:/
home/dittrich/.cache/molecule/utils/ip_in_issue/library:/home/dittrich/code/davedittrich/utils/library:/home/dittrich/.ansible/plugins/modules:/usr/share/ansible/plugins/modules ANSIBLE_ROLES_PATH=/home/dittrich/.cache/ansible-comp
at/6fd897/roles:/home/dittrich/.cache/molecule/utils/ip_in_issue/roles:/home/dittrich/code/davedittrich:/home/dittrich/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles ANSIBLE_VERBOSITY=1 MOLECULE_DEBUG=False MOLECULE_DEP
ENDENCY_NAME=galaxy MOLECULE_DISTRO=debian11 MOLECULE_DRIVER_NAME=docker MOLECULE_ENV_FILE=/home/dittrich/code/davedittrich/utils/.env.yml MOLECULE_EPHEMERAL_DIRECTORY=/home/dittrich/.cache/molecule/utils/ip_in_issue MOLECULE_FILE=
/home/dittrich/.cache/molecule/utils/ip_in_issue/molecule.yml MOLECULE_INSTANCE_CONFIG=/home/dittrich/.cache/molecule/utils/ip_in_issue/instance_config.yml MOLECULE_INVENTORY_FILE=/home/dittrich/.cache/molecule/utils/ip_in_issue/in
ventory/ansible_inventory.yml MOLECULE_PROJECT_DIRECTORY=/home/dittrich/code/davedittrich/utils MOLECULE_PROVISIONER_NAME=ansible MOLECULE_SCENARIO_DIRECTORY=/home/dittrich/code/davedittrich/utils/molecule/ip_in_issue MOLECULE_SCEN
ARIO_NAME=ip_in_issue MOLECULE_STATE_FILE=/home/dittrich/.cache/molecule/utils/ip_in_issue/state.yml MOLECULE_VERIFIER_NAME=testinfra MOLECULE_VERIFIER_TEST_DIRECTORY=/home/dittrich/code/davedittrich/utils/molecule/ip_in_issue/../s
hared/tests '}
ansible: 2.13.3
rootdir: /home/dittrich/code/davedittrich/utils/molecule/shared, configfile: pytest.ini
plugins: ansible-2.3.0, metadata-2.0.2, testinfra-6.8.1.dev4+gd423e29, html-3.1.1, molecule-2.0.1.dev8+g236ac70
collecting ... collected 43 items

molecule/shared/tests/test_branding.py::test_boot_config[ansible:/debian_bullseye] SKIPPED [  2%]
molecule/shared/tests/test_branding.py::test_boot_cmdline[ansible:/debian_bullseye] SKIPPED [  4%]
molecule/shared/tests/test_branding.py::test_fbi_package[ansible:/debian_bullseye] SKIPPED [  6%]
molecule/shared/tests/test_branding.py::test_splashscreen_service[ansible:/debian_bullseye] SKIPPED [  9%]
molecule/shared/tests/test_branding.py::test_wallpaper_image[ansible:/debian_bullseye] SKIPPED [ 11%]
molecule/shared/tests/test_branding.py::test_x11_session_manager_is_lxde[ansible:/debian_bullseye] SKIPPED [ 13%]
molecule/shared/tests/test_branding.py::test_lightdm_login_background[ansible:/debian_bullseye] SKIPPED [ 16%]
molecule/shared/tests/test_branding.py::test_user_homedir[ansible:/debian_bullseye-user0] SKIPPED [ 18%]
molecule/shared/tests/test_branding.py::test_user_wallpaper_setting[ansible:/debian_bullseye-user0] SKIPPED [ 20%]
molecule/shared/tests/test_branding.py::test_user_LXDE_autostart_xset[ansible:/debian_bullseye-user0] SKIPPED [ 23%]
molecule/shared/tests/test_branding.py::test_config_files[fixture_users0-fixture_config_files0-ansible:/debian_bullseye] SKIPPED [ 25%]
molecule/shared/tests/test_dropins.py::test_etc_profile_d_dotlocal[ansible:/debian_bullseye] SKIPPED [ 27%]
molecule/shared/tests/test_dropins.py::test_bashrc_sources_aliases[fixture_users0-ansible:/debian_bullseye] SKIPPED [ 30%]
molecule/shared/tests/test_dropins.py::test_dropin_files[fixture_users0-fixture_dropin_files0-ansible:/debian_bullseye] SKIPPED [ 32%]
molecule/shared/tests/test_dropins.py::test_dropin_directories[fixture_users0-fixture_dropin_files0-ansible:/debian_bullseye] SKIPPED [ 34%]
molecule/shared/tests/test_dropins.py::test_pipx[fixture_users0-pipx-ansible:/debian_bullseye] SKIPPED [ 37%]
molecule/shared/tests/test_dropins.py::test_pipx[fixture_users0-update-dotdee-ansible:/debian_bullseye] SKIPPED [ 39%]
molecule/shared/tests/test_dropins.py::test_update_dotdee_write_bash_profile[fixture_users0-ansible:/debian_bullseye] SKIPPED [ 41%]
molecule/shared/tests/test_ip_in_issue.py::test_issue_file[ansible:/debian_bullseye] PASSED [ 44%]
molecule/shared/tests/test_ip_in_issue.py::test_issue_d[ansible:/debian_bullseye] PASSED [ 46%]
molecule/shared/tests/test_ip_in_issue.py::test_issue_d_interfaces[ansible:/debian_bullseye] PASSED [ 48%]
molecule/shared/tests/test_ip_in_issue.py::test_issue_d_fingerprints[ansible:/debian_bullseye] PASSED [ 51%]
molecule/shared/tests/test_kali_like.py::test_kali_apt_list[ansible:/debian_bullseye] SKIPPED [ 53%]
molecule/shared/tests/test_kali_like.py::test_script_files[fixture_users0-fixture_helper_script_files0-ansible:/debian_bullseye] SKIPPED [ 55%]
molecule/shared/tests/test_kali_like.py::test_kali_like_packages[fixture_kali_like_packages0-ansible:/debian_bullseye] SKIPPED [ 58%]
molecule/shared/tests/test_kali_like.py::test_gawk[ansible:/debian_bullseye] SKIPPED [ 60%]
molecule/shared/tests/test_kali_like.py::test_kali_application_menu[ansible:/debian_bullseye] SKIPPED [ 62%]
molecule/shared/tests/test_kali_like.py::test_guacamole_guacd[ansible:/debian_bullseye] SKIPPED [ 65%]
molecule/shared/tests/test_kali_like.py::test_guacamole_services[fixture_guac_services0-ansible:/debian_bullseye] SKIPPED [ 67%]
molecule/shared/tests/test_kdmt.py::test_keyboard_config_packages[ansible:/debian_bullseye] SKIPPED [ 69%]
molecule/shared/tests/test_kdmt.py::test_custom_load_xmodmap[ansible:/debian_bullseye] SKIPPED [ 72%]
molecule/shared/tests/test_kdmt.py::test_udev_hwdb_file[ansible:/debian_bullseye] SKIPPED [ 74%]
molecule/shared/tests/test_kdmt.py::test_xkboptions[ansible:/debian_bullseye] SKIPPED [ 76%]
molecule/shared/tests/test_kdmt.py::test_keyboard_configuration[ansible:/debian_bullseye] SKIPPED [ 79%]
molecule/shared/tests/test_kdmt.py::test_hid_apple_conf[ansible:/debian_bullseye] SKIPPED [ 81%]
molecule/shared/tests/test_kdmt.py::test_hid_apple_fnmode[ansible:/debian_bullseye] SKIPPED [ 83%]
molecule/shared/tests/test_kdmt.py::test_hid_apple_iso_layout[ansible:/debian_bullseye] SKIPPED [ 86%]
molecule/shared/tests/test_kdmt.py::test_user_inputrc[ansible:/debian_bullseye-user0] SKIPPED [ 88%]
molecule/shared/tests/test_kdmt.py::test_user_cshrc[ansible:/debian_bullseye-user0] SKIPPED [ 90%]
molecule/shared/tests/test_kdmt.py::test_user_exrc[ansible:/debian_bullseye-user0] SKIPPED [ 93%]
molecule/shared/tests/test_kdmt.py::test_user_vimrc[ansible:/debian_bullseye-user0] SKIPPED [ 95%]
molecule/shared/tests/test_kdmt.py::test_user_xmodmap[ansible:/debian_bullseye-user0] SKIPPED [ 97%]
molecule/shared/tests/test_shared.py::test_shared_skip SKIPPED (forc...) [100%]

=========================== short test summary info ============================
SKIPPED [1] molecule/shared/tests/test_branding.py:16: role davedittrich.utils.branding only
SKIPPED [1] molecule/shared/tests/test_branding.py:24: role davedittrich.utils.branding only
SKIPPED [1] molecule/shared/tests/test_branding.py:32: role davedittrich.utils.branding only
SKIPPED [1] molecule/shared/tests/test_branding.py:37: role davedittrich.utils.branding only
SKIPPED [1] molecule/shared/tests/test_branding.py:43: role davedittrich.utils.branding only
SKIPPED [1] molecule/shared/tests/test_branding.py:52: role davedittrich.utils.branding only
SKIPPED [1] molecule/shared/tests/test_branding.py:60: role davedittrich.utils.branding only
SKIPPED [1] molecule/shared/tests/test_branding.py:74: role davedittrich.utils.branding only
SKIPPED [1] molecule/shared/tests/test_branding.py:83: role davedittrich.utils.branding only
SKIPPED [1] molecule/shared/tests/test_branding.py:106: role davedittrich.utils.branding only
SKIPPED [1] molecule/shared/tests/test_branding.py:148: role davedittrich.utils.branding only
SKIPPED [1] molecule/shared/tests/test_dropins.py:33: role davedittrich.utils.dropins only
SKIPPED [1] molecule/shared/tests/test_dropins.py:41: role davedittrich.utils.dropins only
SKIPPED [1] molecule/shared/tests/test_dropins.py:52: role davedittrich.utils.dropins only
SKIPPED [1] molecule/shared/tests/test_dropins.py:63: role davedittrich.utils.dropins only
SKIPPED [2] molecule/shared/tests/test_dropins.py:75: role davedittrich.utils.dropins only
SKIPPED [1] molecule/shared/tests/test_dropins.py:87: role davedittrich.utils.dropins only
SKIPPED [1] molecule/shared/tests/test_kali_like.py:52: role davedittrich.utils.kali_like only
SKIPPED [1] molecule/shared/tests/test_kali_like.py:61: role davedittrich.utils.kali_like only
SKIPPED [1] molecule/shared/tests/test_kali_like.py:72: role davedittrich.utils.kali_like only
SKIPPED [1] molecule/shared/tests/test_kali_like.py:78: role davedittrich.utils.kali_like only
SKIPPED [1] molecule/shared/tests/test_kali_like.py:85: role davedittrich.utils.kali_like only
SKIPPED [1] molecule/shared/tests/test_kali_like.py:94: role davedittrich.utils.kali_like only
SKIPPED [1] molecule/shared/tests/test_kali_like.py:103: role davedittrich.utils.kali_like only
SKIPPED [1] molecule/shared/tests/test_kdmt.py:16: role davedittrich.utils.kdmt only
SKIPPED [1] molecule/shared/tests/test_kdmt.py:22: role davedittrich.utils.kdmt only
SKIPPED [1] molecule/shared/tests/test_kdmt.py:30: role davedittrich.utils.kdmt only
SKIPPED [1] molecule/shared/tests/test_kdmt.py:39: role davedittrich.utils.kdmt only
SKIPPED [1] molecule/shared/tests/test_kdmt.py:47: role davedittrich.utils.kdmt only
SKIPPED [1] molecule/shared/tests/test_kdmt.py:54: role davedittrich.utils.kdmt only
SKIPPED [1] molecule/shared/tests/test_kdmt.py:64: role davedittrich.utils.kdmt only
SKIPPED [1] molecule/shared/tests/test_kdmt.py:76: role davedittrich.utils.kdmt only
SKIPPED [1] molecule/shared/tests/test_kdmt.py:91: role davedittrich.utils.kdmt only
SKIPPED [1] molecule/shared/tests/test_kdmt.py:118: role davedittrich.utils.kdmt only
SKIPPED [1] molecule/shared/tests/test_kdmt.py:132: role davedittrich.utils.kdmt only
SKIPPED [1] molecule/shared/tests/test_kdmt.py:146: role davedittrich.utils.kdmt only
SKIPPED [1] molecule/shared/tests/test_kdmt.py:160: role davedittrich.utils.kdmt only
SKIPPED [1] molecule/shared/tests/test_shared.py:6: force skip
======================== 4 passed, 39 skipped in 1.70s =========================
INFO     Verifier completed successfully.
[+] all tests succeeded
[+] instance(s) were not destroyed: use 'molecule destroy' or 'molecule reset' manually
  . . .
```

Using the `pytest` option `-rP` instead, the output from the `verify` stage is much
shorter:

```
$ PYTEST_ADDOPTS="-rP" molecule verify -s ip_in_issue
INFO     ip_in_issue scenario test matrix: verify
INFO     Performing prerun with role_name_check=0...
INFO     Set ANSIBLE_LIBRARY=/home/dittrich/.cache/ansible-compat/6fd897/modules:/home/dittrich/.ansible/plugins/modules:/usr/share/ansible/plugins/modules
INFO     Set ANSIBLE_COLLECTIONS_PATH=/home/dittrich/.cache/ansible-compat/6fd897/collections:/home/dittrich/.ansible/collections:/usr/share/ansible/collections
INFO     Set ANSIBLE_ROLES_PATH=/home/dittrich/.cache/ansible-compat/6fd897/roles:roles:/home/dittrich/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles
INFO     Running ansible-galaxy collection install -v --force -p /home/dittrich/.cache/ansible-compat/6fd897/collections .
INFO     Running ip_in_issue > verify
INFO     Executing Testinfra tests found in /home/dittrich/code/davedittrich/utils/molecule/ip_in_issue/../shared/tests/...
/home/dittrich/miniconda3/envs/utils/lib/python3.9/site-packages/molecule/config.py:51: DeprecationWarning: molecule.config.ansible_version is deprecated, will be removed in the future.
  warnings.warn(
============================= test session starts ==============================
platform linux -- Python 3.9.13, pytest-7.1.3, pluggy-1.0.0
ansible: 2.13.3
rootdir: /home/dittrich/code/davedittrich/utils/molecule/shared, configfile: pytest.ini
plugins: ansible-2.3.0, metadata-2.0.2, testinfra-6.8.1.dev4+gd423e29, html-3.1.1, molecule-2.0.1.dev8+g236ac70
collected 43 items

molecule/shared/tests/test_branding.py sssssssssss                       [ 25%]
molecule/shared/tests/test_dropins.py sssssss                            [ 41%]
molecule/shared/tests/test_ip_in_issue.py ....                           [ 51%]
molecule/shared/tests/test_kali_like.py sssssss                          [ 67%]
molecule/shared/tests/test_kdmt.py sssssssssssss                         [ 97%]
molecule/shared/tests/test_shared.py s                                   [100%]

==================================== PASSES ====================================
======================== 4 passed, 39 skipped in 1.76s =========================
INFO     Verifier completed successfully.
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
$ molecule destroy -s ip_in_issue
INFO     ip_in_issue scenario test matrix: dependency, destroy
INFO     Performing prerun with role_name_check=0...
INFO     Set ANSIBLE_LIBRARY=/home/dittrich/.cache/ansible-compat/6fd897/modules:/home/dittrich/.ansible/plugins/modules:/usr/share/ansible/plugins/modules
INFO     Set ANSIBLE_COLLECTIONS_PATH=/home/dittrich/.cache/ansible-compat/6fd897/collections:/home/dittrich/.ansible/collections:/usr/share/ansible/collections
INFO     Set ANSIBLE_ROLES_PATH=/home/dittrich/.cache/ansible-compat/6fd897/roles:roles:/home/dittrich/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles
INFO     Running ansible-galaxy collection install -v --force -p /home/dittrich/.cache/ansible-compat/6fd897/collections .
INFO     Running ip_in_issue > dependency
WARNING  Skipping, missing the requirements file.
WARNING  Skipping, missing the requirements file.
INFO     Running ip_in_issue > destroy
INFO     Sanity checks: 'docker'
Using /home/dittrich/.cache/molecule/utils/ip_in_issue/ansible.cfg as config file

PLAY [Destroy] *****************************************************************

TASK [Destroy molecule instance(s)] ********************************************
changed: [localhost] => (item=debian_bullseye) => {"ansible_job_id": "151811718162.2756561", "ansible_loop_var": "item", "changed": true, "finished": 0, "item": {"capabilities": ["SYS_ADMIN"], "dockerfile": "../shared/Dockerfile-debian_bullseye.j2", "image": "debian:bullseye", "name": "debian_bullseye", "override_command": false, "privileged": true, "security_opts": ["seccomp=unconfined"], "tmpfs": ["/run", "/run/lock", "/tmp"]}, "results_file": "/home/dittrich/.ansible_async/151811718162.2756561", "started": 1}

TASK [Wait for instance(s) deletion to complete] *******************************
FAILED - RETRYING: [localhost]: Wait for instance(s) deletion to complete (300 retries left).
changed: [localhost] => (item=debian_bullseye) => {"ansible_job_id": "151811718162.2756561", "ansible_loop_var": "item", "attempts": 2, "changed": true, "finished": 1, "item": {"ansible_job_id": "151811718162.2756561", "ansible_loop_var": "item", "changed": true, "failed": 0, "finished": 0, "item": {"capabilities": ["SYS_ADMIN"], "dockerfile": "../shared/Dockerfile-debian_bullseye.j2", "image": "debian:bullseye", "name": "debian_bullseye", "override_command": false, "privileged": true, "security_opts": ["seccomp=unconfined"], "tmpfs": ["/run", "/run/lock", "/tmp"]}, "results_file": "/home/dittrich/.ansible_async/151811718162.2756561", "started": 1}, "results_file": "/home/dittrich/.ansible_async/151811718162.2756561", "started": 1, "stderr": "", "stderr_lines": [], "stdout": "", "stdout_lines": []}

TASK [Delete docker networks(s)] ***********************************************

PLAY RECAP *********************************************************************
localhost                  : ok=2    changed=2    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

INFO     Pruning extra files from scenario ephemeral directory
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
INFO     Running kali_like > list
INFO     Running kdmt > list
                  ╷             ╷                  ╷               ╷         ╷
  Instance Name   │ Driver Name │ Provisioner Name │ Scenario Name │ Created │ Converged
╶─────────────────┼─────────────┼──────────────────┼───────────────┼─────────┼───────────╴
  debian_bullseye │ docker      │ ansible          │ branding      │ false   │ false
  debian_bullseye │ docker      │ ansible          │ default       │ true    │ false
  delegated-host  │ delegated   │ ansible          │ delegated     │ unknown │ false
  debian_bullseye │ docker      │ ansible          │ dropins       │ false   │ false
  debian_bullseye │ docker      │ ansible          │ ip_in_issue   │ false   │ false
  debian_bullseye │ docker      │ ansible          │ kali_like     │ false   │ false
  debian_bullseye │ docker      │ ansible          │ kdmt          │ false   │ false
                  ╵             ╵                  ╵               ╵         ╵
```

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
molecule/shared/tests/test_swapcapslockctrl.py::test_inputrc[ansible:/delegated-host-root] PASSED [ 91%]
molecule/shared/tests/test_swapcapslockctrl.py::test_inputrc[ansible:/delegated-host-pirate] PASSED [ 92%]
molecule/shared/tests/test_swapcapslockctrl.py::test_bashrc[ansible:/delegated-host-root] PASSED [ 93%]
molecule/shared/tests/test_swapcapslockctrl.py::test_bashrc[ansible:/delegated-host-pirate] PASSED [ 94%]
molecule/shared/tests/test_swapcapslockctrl.py::test_cshrc[ansible:/delegated-host-root] PASSED [ 95%]
molecule/shared/tests/test_swapcapslockctrl.py::test_cshrc[ansible:/delegated-host-pirate] PASSED [ 96%]
molecule/shared/tests/test_swapcapslockctrl.py::test_exrc[ansible:/delegated-host-root] PASSED [ 97%]
molecule/shared/tests/test_swapcapslockctrl.py::test_exrc[ansible:/delegated-host-pirate] PASSED [ 98%]
molecule/shared/tests/test_swapcapslockctrl.py::test_vimrc[ansible:/delegated-host-root] PASSED [ 99%]
molecule/shared/tests/test_swapcapslockctrl.py::test_vimrc[ansible:/delegated-host-pirate] PASSED [100%]

============ 103 passed, 1 skipped, 2 xfailed in 116.30s (0:01:56) =============
INFO     Verifier completed successfully.
```

Several environment variables in the `molecule.yml` files that allow you to control the amount
of output that is produced.  These are:

- `ANSIBLE_VERBOSITY` - Controls verbosity of `ansible-playbook`, `ansible-lint`, and `pipdeptree` output.
  Set to a numeric value corresponding to output level (default `0`).
- `ANSIBLE_FORCE_COLOR` - Set to `false` to disable color output from `ansible-playbook`.


## Versioning

If you are producing collection artifacts for testing on delegated hosts,
such as a Raspberry Pi or cloud instance, you will want to bump the
version number when building artifacts.

Doing a `make build` will first do `bumpversion build` so each new
artifact will have a unique `build` version number component for the
artifact and its constituent files.

    $ cat VERSION
    0.6.0

    $ bumpversion build

    $ git diff VERSION
    diff --git a/VERSION b/VERSION
    index a918a2a..758efdb 100644
    --- a/VERSION
    +++ b/VERSION
    @@ -1 +1 @@
    -0.6.0
    +0.6.0.1

These artifacts will work for testing by manually loading them, but
they will not be published when you push to GitHub. The GitHub Actions
workflows will only run `molecule` tests, which is necessary before
any artifacts can be published via the GitHub Actions workflows.

Of course you can always manually publish the last built artifact
using `make publish` if need be.

### Publishing a release candidate

When you are preparing to publish a release candidate, specify the current
version number and manually set a new version number with the `-rc` pre-release
identifier like this:

    $ bumpversion --current-version 0.6.0.1 --new-version 0.6.1-rc.1 build
    $ git diff VERSION
    diff --git a/VERSION b/VERSION
    index a918a2a..2f12cd4 100644
    --- a/VERSION
    +++ b/VERSION
    @@ -1 +1 @@
    -0.6.0
    +0.6.1-rc.1

When you push to the `develop` branch with a tag containing the `0.6.1-rc.1`
identifier, it will be published to the Ansible Galaxy development server.

As long as you are continuing to iterate, just keep doing `make build` and
the release candidate number will increment:

    $ bumpversion build
    $ git diff VERSION
    diff --git a/VERSION b/VERSION
    index a918a2a..2f12cd4 100644
    --- a/VERSION
    +++ b/VERSION
    @@ -1 +1 @@
    -0.6.0
    +0.6.1-rc.2

### Publishing a full release

When you are satisfied that all tests work on your development servers and
GitHub, you are ready to publish a full "production" release artifact.

To do that, you need to do two things:

1. Manually remove the `-rc.N` components from the version number by doing
   the opposite of what was done above, and

2. Tag the commit with the new version number (in this case, `0.6.1`) on
   the `main` branch and the GitHub Actions workflow will publish it to
   the main Ansible Galaxy server.

Again, do frequent `make test` runs whenever making significant changes beyond
bumping version numbers and updating release history. Each push to GitHub
before pushing the tags will run tests as well, reassuring you that the
published artifacts will work.

## Using `conda`

This repo is set up assuming `miniconda` is installed for two reasons:

1. It allows you to avoid conflicts with your system's `python` installation by
   using virtual environments for managing your `python` executable and manage
   packages in its `site-packages` directory, and

2. It [sets environment variables](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#macos-and-linux)
   automatically when activating virtual environments. This allows you to
   associate the `python-secrets` environment you will be using for storing
   configuration variables, secrets like API keys and passwords, and storing
   temporary files that contain secrets (e.g., a Raspberry Pi `cloud-config` file).

Create your virtual environment. For this example, the name `utils` is used.

```
$ conda create -n utils python=3.9
```

Set environment variables for `python-secrets` to use for finding where your
secrets will be stored and which environment identifier to use.

```
$ conda env config vars set D2_SECRETS_BASEDIR=~/.secrets D2_ENVIRONMENT=utils CLIFF_FIT_WIDTH=1
To make your changes take effect please reactivate your environment
```

Follow the guidance the first time you do this to get these environment variables set. When
the values change, you will be notified of this fact.

To see what variables are set by `conda` on activation, do:

```
$ conda env config vars list
D2_SECRETS_BASEDIR = /home/dittrich/.secrets
D2_ENVIRONMENT = utils
CLIFF_FIT_WIDTH = 1
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
  the same. Pay attention to `mode` and `group` settings. You may get warnings
  from `ansible-lint` that a newly created file may end up with insecure
  settings. Use `molecule converge` to get all the plays to run, followed by
  `molecule login` to log into the instance to check file contents and/or file
  system metadata. Running `molecule verify` will run the tests again to debug
  your plays.

- "FOSS-rot". Yes, I said it. Like most popular open source projects, anything
  you write for or with Ansible will, after a few months, simply fail because of
  breaking changes in Ansible, community collections and roles, and related software
  like `molecule`, `testinfra`, and Docker is also part of this particular problem.

  I hadn't touched this collection in many months and when I came back to it to
  continue developing I got several failures in what previously was working fine.
  By pinning some packages to attempt to maintain stability, deprecations and
  non-backward compatible changes and newly set minimum versions above those
  being pinned resulted in breakages. This included operating system distributions
  reaching "end-of-life" status.

  I rat-holed for days trying to get Debian 10 to run `systemd` processes
  in Docker to install Kali Linux packages, which failed during `apt-get
  install` because of a change in `perl-base` and `libc6` that resulted in a
  dynamic library that was refactored out of a dependent package to `perl-base`
  (which `dpkg` uses to complete installation of packages, breaking the
  installation entirely in a way that requires manually re-inserting the missing
  dynamic library and using APT's `--fix-broken` flag to recover!

  After giving up on that and just moving to Debian 11 (which Kali Linux now
  uses), I ran into a cluster of issues with incompatible versions of `ansible`,
  `ansible-core`, `ansible-lint`, `ansible-compat`, and `pytest` plugins for
  `testinfra` and `ansible`.  They interact in very complex ways that are
  extremely difficult to debug.

  - `molecule` uses `ansible-compat` (behind the scenes, mind you) to run
    `ansible-playbook`, `ansible-galaxy`, `ansible`, linters, and `pytest`.

  - `pytest`, in turn, also runs `ansible` as well as `testinfra` (in my case)
    for testing. But wait, there's more!

  - `testinfra` runs `docker`, in which the Ansible collection is installed
    and tested.

  I ended up having to get `pytest` testing working under VSCode, single-step
  through process execution to see data structures at runtime, and forking
  5 repositories in which I fixed bugs in order to achieve enough stability
  to finally get everything working and the collection testable on a
  Raspberry Pi.

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
- [Advanced `bumpversion` examples](https://github.com/andrivet/ADVbumpversion/blob/master/EXAMPLES.rst)
- [Five Ansible Techniques I Wish I'd Known Sooner](https://zwischenzugs.com/2021/08/27/five-ansible-techniques-i-wish-id-known-earlier/), by zwischenzugs, August 27, 2021
- [Mastering Molecule](https://sbarnea.com/molecule/molecule-101/), by Sorin Sbarnea, January 1, 2019

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
