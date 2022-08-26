davedittrich.utils.teamviewer
=============================

This role installs TeamViewer and configures it to accept the EULA for a simplified
user experience on first boot.

https://stackoverflow.com/questions/32257414/how-to-accept-teamviewer-license-agreement-from-under-console-at-first-launch


Requirements
------------

There are no pre-requisites.

Role Variables
--------------

`accounts` - the list of user accounts to be set up.

Dependencies
------------

There are no dependencies.

Example Playbook
----------------

This role is applied as follows:

```
- hosts: all
  roles:
    - role: davedittrich.utils.teamviewer
```

To Do
-----

...

License
-------

Apache 2.0

Author Information
------------------

Dave Dittrich < dave.dittrich@gmail.com >
https://davedittrich.github.io/
