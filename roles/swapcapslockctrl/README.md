davedittrich.utils.swapcapslockctrl
===================================

This role sets up permanent swapping of the Left CTRL key with CapsLock key.
Everyone knows this is the way God intended the keyboard to be layed out.

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
         - { role: davedittrich.utils.swapcapslockctrl }

License
-------

Apache 2.0

Author Information
------------------

Dave Dittrich < dave.dittrich@gmail.com >
https://davedittrich.github.io/
