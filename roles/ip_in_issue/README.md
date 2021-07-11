davedittrich.utils.ip_in_issue
==============================

This role ensures that the system's ``/etc/issue`` file contains the host's
name, SSH public keys and IP addresses of active interfaces.

Requirements
------------

There are no pre-requisites.

Role Variables
--------------

There are no role variables. If you do not wish this role to be applied, don't include it.

Dependencies
------------

There are no dependencies.

Example Playbook
----------------

This role is applied as follows:

    - hosts: all
      roles:
         - { role: davedittrich.utils.ip_in_issue }

There is a playbook for applying this role in the ``playbooks/`` directory for this
collection.  It can be used as follows:

    ANSIBLE_COLLECTIONS_PATH=~/.ansible/collections.dev ansible-playbook -i 192.168.0.107,  playbooks/ip_in_issue.yml


License
-------

Apache 2.0

Author Information
------------------

Dave Dittrich < dave.dittrich@gmail.com >
https://davedittrich.github.io/
