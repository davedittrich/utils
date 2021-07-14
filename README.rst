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

Then set the ``provisioner`` in ``molecule/default/molecule.yml`` as follows:

.. literalinclude:: molecule/default/molecule.yml
    :start-after: # [molecule.yml-provisioner]
    :end-before: # ![molecule.yml-provisioner]


Dave Dittrich <dave.dittrich@gmail.com>
https://github.com/davedittrich/utils
