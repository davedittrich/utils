davedittrich.utils.visible_bell
===============================

This role disables auditory bell settings in various apps and system services
to make a workstation quieter for use in lab environments or other shared
spaces where constant BONK! BONK! BONK! might get you kicked out.

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
         - { role: davedittrich.utils.visible_bell }

License
-------

Apache 2.0

Author Information
------------------

Dave Dittrich < dave.dittrich@gmail.com >
https://davedittrich.github.io/
