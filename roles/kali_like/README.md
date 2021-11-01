davedittrich.utils.kali-like
============================

This role ensures that specified Kali Linux features and tooling
are available.

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
    - role: davedittrich.utils.kali_like
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
