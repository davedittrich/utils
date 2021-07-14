Ansible Collection - davedittrich.utils
=======================================

Ansible collection for my opinionated development workstation configuration.

Testing
-------

For molecule tests to work on this collection, without interfering with existing
collections, set up an alternate collections directory as follows::

    $ tree -L 2 ~/.ansible/collections*
    /Users/dittrich/.ansible/collections
    └── ansible_collections
        ├── ansible
        └── community
    /Users/dittrich/.ansible/collections.dev
    └── ansible_collections
        └── davedittrich -> /Users/dittrich/code/davedittrich

    6 directories, 0 files

Then set the ``provisioner`` in ``molecule/default/molecule.yml`` as follows::

    provisioner:
      name: ansible
      env:
        ANSIBLE_COLLECTIONS_PATH: "$HOME/.ansible/collections.dev:$HOME/.ansible/collections"
        # Grrr! https://github.com/ansible/ansible/issues/70750
        ANSIBLE_COLLECTIONS_PATHS: "$HOME/.ansible/collections.dev:$HOME/.ansible/collections"
        ANSIBLE_ROLES_PATH: "../../roles"
        ANSIBLE_VERBOSITY: ${ANSIBLE_VERBOSITY:-1}
        TESTS_PATH: "../../tests"
      playbooks:
        converge: ${MOLECULE_PLAYBOOK:-converge.yml}

Dave Dittrich <dave.dittrich@gmail.com>
https://github.com/davedittrich/utils
