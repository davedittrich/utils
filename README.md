# davedittrich.utils Collection for Ansible

[![CI](https://github.com/davedittrich/utils/workflows/release/badge.svg?event=push)](https://github.com/davedittrich/utils/actions)

An Ansible collection for my opinionated development workstation configuration and
prototyping Ansible (and non-Ansible) features for other Python packages and
Ansible collections.

This collection houses roles, playbooks, and other Ansible content suitable for
setting up standardized tooling and settings on development workstations. It also
facilitates automated configuration of other systems, like Raspberry Pi servers
and cloud instances for training labs or "capture the flag" contests.

Development of this collection is supported by a test-driven design that uses
[`molecule`](https://molecule.readthedocs.io/en/latest/) to test any or all
roles, both locally and driven by GitHub Actions workflows on `push` actions.

The operating system distributions supported at this time are:

- Debian 10 (default distribution)
- Debian 9
- Ubuntu 20.04 LTS
- Ubuntu 18.04 LTS

To help reduce the amount of time necessary for this testing, several capabilities
are available:

1. Local testing during development is done against _only_ Debian 10. Once you
   have something that passes all tests, you can then chose to run tests again
   against the remaining distributions.

2. Customized Docker images are used to pre-load the many packages that are expected
   to be on production workstations. This significantly reduces the amount of time
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

Then set the `provisioner` in `molecule/default/molecule.yml` as follows::

```yaml
provisioner:
  name: ansible
  env:
    ANSIBLE_COLLECTIONS_PATH: "$HOME/.ansible/collections.dev:$HOME/.ansible/collections"
    # Grrr! https://github.com/ansible/ansible/issues/70750
    ANSIBLE_COLLECTIONS_PATHS: "$HOME/.ansible/collections.dev:$HOME/.ansible/collections"
    ANSIBLE_ROLES_PATH: "../../roles"
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
from molecule.shared import (
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

To further reduce redundancy in hard-coding of elements that are part of tests,
all Ansible variables that were defined during role execution in the `converge`
phase are dumped to a file so they can be used during later phases (specifically,
the `verify` phase).

Tests can be skipped by use of the `@skip_unless_role()` decorator, which checks
to see if the role for which they apply is in the `ansible_roles_names` variable
(meaning that role was applied and thus needs testing).

```
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

The file containing the Ansible variables also helps in debugging playbooks.
By running `molecule converge`, the roles are applied and the variables are
dumped into the file `/tmp/ansible-vars.yml` at the end. The `molecule converge`
run then stops, at which point you can look at the file.

To continue on to testing, you can manually run `molecule verify`, at which point
the variables are loaded and are available to tests. This allows you to
redefine some variables during development, re-run `molecule converge` to have
them take effect, and your tests can then automatically adjust.

Only when `molecule destroy` is run will the file be deleted.

```
  . . .
INFO     Running ip_in_issue > destroy
Using /Users/dittrich/.cache/molecule/utils/ip_in_issue/ansible.cfg as config file

PLAY [Destroy] *****************************************************************

TASK [Delete variables saved from converge step.] ******************************
ok: [instance -> localhost] => {"changed": false, "path": "/tmp/ansible-vars.yml", "state": "absent"}

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


## See also

- [Testing Ansible automation with molecule](https://redhatnordicssa.github.io/how-we-test-our-roles)
- [Question: accessing values of variables as they are being used for provisioning an instance inside Testinfra tests #151](https://github.com/ansible-community/molecule/issues/151)
- [Using Ansible Molecule to test roles in monorepo](https://mariarti0644.medium.com/using-ansible-molecule-to-test-roles-in-monorepo-5f711c716666>)
- [Continuous Infrastructure with Ansible, Molecule & TravisCI](https://blog.codecentric.de/en/2018/12/continuous-infrastructure-ansible-molecule-travisci/)
- [Test-driven infrastructure development with Ansible & Molecule](https://blog.codecentric.de/en/2018/12/test-driven-infrastructure-ansible-molecule/), by Jonas Hecht, 2018-12-04

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
