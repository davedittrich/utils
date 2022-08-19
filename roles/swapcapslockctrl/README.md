davedittrich.utils.swapcapslockctrl
===================================

This role configures the system to permanently swap the *CapsLock* key with
the *Left CTRL* key (for those who prefer the keyboard layout of the
original IBM keyboards.)

It does this by following examples for implementing some of the mechanisms
found in references such as:

    https://wiki.archlinux.org/title/Map_scancodes_to_keycodes
    https://github.com/10ne1/carpalx-keyboard

The mechanisms implemented are:

* An include file in the `/etc/X11/Xsession.d` directory to
  (`40custom_load_xmodmap`) load custom user `.Xmodmap` files
  and creation of said files in users' home directories.
* A key remapping file in the `/etc/udev/hwdb.d/` directory.
* Reconfiguring the keyboard by setting `ctrl:swapcaps` in
  `/etc/default/keyboard`.

See also:

* https://wiki.archlinux.org/title/Map_scancodes_to_keycodes
* https://github.com/10ne1/carpalx-keyboard
* https://aty.sdsu.edu/bibliog/latex/debian/keyboard.html

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
