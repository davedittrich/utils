davedittrich.utils.kali-like
============================

Version: 0.7.0-rc.101

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

This role installs [Kali Linux](https://www.kali.org/), which is
[based on the Debian Testing release](docs/policy/kali-linux-relationship-with-debian/).
As such, it is not compatible with Debian 10.

Role Variables
--------------

`accounts` - the list of user accounts to be set up.

Dependencies
------------

This role is dependent on Debian 11 and Kali Linux package repositories
that are configured to take priority over the standard Debian package
branch.

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
