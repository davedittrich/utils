davedittrich.utils.kdmt
=======================

Version: 0.7.0-rc.96

This role can be used to configure the system's *keyboard*, *displays*,
*mouse*, and *trackpad* (hence the acronym *kdmt*).

It allows you to swap the *CapsLock* key with the *Left CTRL* key (for those
who prefer the keyboard layout of the original IBM keyboards), enable "natural
scrolling" for the mouse and trackpad, and configure `hid_apple` keyboard
devices to use function keys without needing `Fn` key.

Included in this collection are (will be: WIP) scripts for toggling some of
these features on and off (for when the system is used by multiple people with
different preferences).

- The CapsLock and CTRL keys are configured following examples for
  implementing several different mechanisms found in the references
  below such as:

      * An include file in the `/etc/X11/Xsession.d` dropin directory
        (`40custom_load_xmodmap`) to load custom user `.Xmodmap` files
        and creation of said files in users' home directories.
      * A key remapping file in the `/etc/udev/hwdb.d/` directory.
      * Configuring the keyboard by setting `ctrl:swapcaps` in
        `/etc/default/keyboard`.

- Use of Apple keyboard function keys directly is configured by creating
  a dropin configuration file ('/etc/modprobe.d/hid_apple.conf') and
  running `update-initramfs -u -k all`.

Role task structure
-------------------

This role is a bit complicated in that (a) some configuration takes
place at the system level, (b) some must take place at the user level,
and (c) there must be a dropin-style connection between the two in
specific cases.

The `main.yml` task file includes setup and configuration task files for each
high-level component. Each of these in turn either performs system-level
tasks and/or include user-level tasks in a loop.

The calling hierarchy looks like this:

```
main.yml
├─> setup_xsessiond_dropin.yml
├─> configure_keyboard_hid_apple.yml
├─> configure_keyboard_capslockctrl.yml
│   └─> user_xmodmap_capslockctrl.yml
├─> configure_keyboard_visible_bell.yml
│   └─> user_visible_bell.yml
└─> configure_natural_scrolling.yml
    └─> user_xmodmap_natural_scrolling.yml
```

References
----------

- https://wiki.archlinux.org/title/Map_scancodes_to_keycodes
- https://github.com/10ne1/carpalx-keyboard
- https://wiki.archlinux.org/title/Map_scancodes_to_keycodes
- https://github.com/10ne1/carpalx-keyboard
- https://aty.sdsu.edu/bibliog/latex/debian/keyboard.html

Requirements
------------

There are no pre-requisites.

Role Variables
--------------

! Variable | Type | Purpose |
| `keyboard_hid_apple` | Boolean | Configure Apple keyboard to enable function keys |
| `keyboard_hid_apple_iso_layout` | String | ISO keyboard layout setting |
| `keyboard_hid_apple_fnmode` | String | Function key mode |
| `keyboard_swapcapslockctrl` | Boolean | Swap Left CapsLock and CTRL keys |
| `keyboard_visible_bell`| Boolean | Enable visible bell to silence the system's bell |
| `natural_scrolling` | Boolean | Enable natural scrolling on the mouse and trackpad |

Dependencies
------------

There are no dependencies.

Example Playbook
----------------

This role can be applied as follows:

    - hosts: all
      vars:
        keyboard_hid_apple: true
        keyboard_swapcapslockctrl: true
        keyboard_visible_bell: true
        natural_scrolling: true
      roles:
         - { role: davedittrich.utils.kdmt }

License
-------

Apache 2.0

Author Information
------------------

Dave Dittrich < dave.dittrich@gmail.com >
https://davedittrich.github.io/
