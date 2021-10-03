# davedittrich.utils Collection for Ansible

[![CI](https://github.com/davedittrich/utils/workflows/release/badge.svg?event=push)](https://github.com/davedittrich/utils/actions)

Ansible collection for my opinionated development workstation configuration and
prototyping Ansible (and non-Ansible) features for other Python packages and
Ansible collections.

This collection houses roles, playbooks, and other Ansible content suitable for
setting up standardized tooling and settings for development workstations or
other systems like Raspberry Pi servers and training lab cloud instances.

Development is supported by a test-driven design that uses `molecule` to test
any or all roles, both locally and as GitHub Actions workflows on `push` actions.

The operating system distributions supported at this time are:

* Debian 10 (default distribution)
* Debian 9
* Ubuntu 20.04 LTS
* Ubuntu 18.04 LTS

To help reduce the amount of time necessary for this testing, several capabilities
are available:

1. Local testing during development is done against *only* Debian 10. Once you
   have something that appears to pass all tests, you can then chose to run tests
   against the remaining distributions.

2. Customized Docker images are used to pre-load the many packages that are expected
   to be on production workstations. This significantly reduces the amount of time
   necessary to perform frequent tests by *only* performing time-consuming package
   installations when you chose to do so (not every time a `molecule` instance is
   created.)

3. GitHub action testing for release candidates on the `develop` branch and
   releases on the `main` branch are the only ones that test *all* roles
   against *all* distributions. When you `push` to a feature branch with a
   name related to the role you are developing (e.g., `feature/branding` for
   the `davedittrich.utils.branding` role), *only* that role is tested against
   the distribution matrix. This reduces test time by only testing role-specific
   changes.

All of this comes at a cost, however. The use of custom Docker containers increases
disk storage, and there is a *lot* of non-DRY repetition of logic, code, and
`molecule` configuration settings. This is a side-effect of limitations in modularity
of GitHub Actions. Some of this repetition can be eliminated by more modularity
and cross-inclusion of some code, which is a long-term aspirational goal.


https://github.com/davedittrich/utils

## Using this collection

### Installing the Collection from Ansible Galaxy

Before using this collection, you need to install it with the Ansible Galaxy command-line tool:
```bash
ansible-galaxy collection install davedittrich.utils
```

You can also include it in a `requirements.yml` file and install it with `ansible-galaxy collection
install -r requirements.yml`, using the format:
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

You can also install a specific version of the collection, for example, if you need to downgrade
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

Then set the ``provisioner`` in ``molecule/default/molecule.yml`` as follows::

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
```

To reduce redundancy in code across multiple scenarios representing individual
roles in a larger collection, tests, variables, and functions are located in
the `molecule/shared` directory.  As seen in the code example for the `provisioner`
section, the `PYTHONPATH` environment variable is set, allowing Python code
to be able to `import` from this module directory as seen here:

```python
from molecule.shared import (
    ansible_vars,
    not_in_roles,
    users,
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
all variables that were defined during the `converge` phase are dumped so they
can be used during later phases (specifically, the `verify` phase). Tests
can be skipped by checking to see if the role for which they apply is in
the `ansible_roles_names` variable.

```python
@pytest.mark.skipif(
    not_in_roles('davedittrich.utils.branding'),
    reason='role davedittrich.utils.branding only'
)
def test_user_homedirs(host):
    assert 'branding_users' in ansible_vars
    for user in ansible_vars['branding_users']:
        homedir = os.path.expanduser(f'~{user}')
        f = host.file(homedir)
        if os.path.exists(homedir):
            assert f.user == user
            assert f.group == user
```

* Dump the Ansible variables at the end of the `converge` step for later use.
* Load the Ansible variables at the start of the `test` step.
* Use the FQCN to skip tests that are role-specific when the associated role is
  not in `ansible_roles_names` variable:

```
. . .
ansible_role_names: [davedittrich.utils.ip_in_issue]
. . .
```

See also:

* `Testing Ansible automation with molecule <https://redhatnordicssa.github.io/how-we-test-our-roles>`_
* `Question: accessing values of variables as they are being used for provisioning an instance inside Testinfra tests #151 <https://github.com/ansible-community/molecule/issues/151>`_


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
