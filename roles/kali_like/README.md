davedittrich.utils.kali-like
============================

Version: 0.6.0

This role ensures that certain Kali Linux features and tooling
are available.

APT repository policies are set to prioritize Kali repos over Debian
repos, and to prioritize the Debian `unstable` branch to match that
followed by Kali. It also does a `dist-upgrade` to bring everything
up to date. This can cause idempotence failures when this role is
applied along with other roles, so playbooks that apply multiple
should apply `kali_like` first.

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
