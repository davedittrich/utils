davedittrich.utils.dropins
==========================

Version: 0.7.0-rc.103

This role ensures that specified files are set up for management using
[update-dotdee](https://pypi.org/project/update-dotdee/).

```
root@instance:~# cd /root
root@instance:~# tree .*.d .ssh/config.d
.bash_aliases.d
`-- 000-local
.bash_profile.d
`-- 000-local
.gitconfig.d
`-- 000-local
.ssh/config.d
`-- 000-local

0 directories, 4 files
```

Skeleton files that are created before running `update-dotdee` contain
help information.

```
root@instance:~# cat .bash_profile
# This is an empty file used to bootstrap management of the file
# '/root/.bash_profile' using 'update-dotdee'. To make changes to
# that file, edit '/root/.bash_profile.d/000-local' or add another file
# to that directory and then run:
#
#    $ update-dotdee /root/.bash_profile
#
```

Requirements
------------

This role must be applied *after* any other roles that use `lineinfile` or
`blockinfile` in order for idempotence tests to pass.

Role Variables
--------------

`accounts` - the list of user accounts to be set up.
`dropin_files` - the list of files to be set up for managemnt with `update-dotdee`.

Dependencies
------------

There are no dependencies.

Example Playbook
----------------

This role is applied as follows:

```
- hosts: all
  roles:
    - role: davedittrich.utils.dropins
      vars:
        dropin_files:
          - '.bash_profile'
          - '.bash_aliases'
          - '.gitconfig'
          - '.ssh/config'
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
