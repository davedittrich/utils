davedittrich.utils.branding
===========================

Version: 0.7.0-rc.59

This role ensures a custom boot splash and desktop background image are
set up.

* Installs LXDE and configures as default desktop environment using
  `lxsession` (ala Kali Linux).
* Disables boot splash in `/boot/config.txt` file.
* Creates `splashscreen.service` to display custom splash screen.
* Disables boot logo in `/boot/cmdline.txt` file.
* Customizes LXDE/lxsession X11 settings, etc.
* Disables `clipit` history saving (for new LXDE installations).

See also:

* https://www.thegeekstuff.com/2012/10/grub-splash-image/
* https://shop.sb-components.co.uk/blogs/posts/customising-splash-screen-on-your-raspberry-pi


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
         - { role: davedittrich.utils.branding }

To Do
-----

* Specify boot splash file path using a variable for more user control.
  (Currently, file must exist in `/root/custom-splash.jpg`.)

* Specify the wallpaper image using a variable for more user control.
  (Currently, uses the same file in `/root/custom-splash.jpg`.)

* Create multiple resolution versions of the wallpaper file from the
  one specified (using ImageMagick) to minimize distortion effects
  due to differing screen resolutions and aspect ratios.

License
-------

Apache 2.0

Author Information
------------------

Dave Dittrich < dave.dittrich@gmail.com >
https://davedittrich.github.io/
