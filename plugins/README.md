# Collections Plugins Directory

This directory is where plugins for the ``davedittrich.util`` collection reside.
Each plugin is placed in a folder that is named after the type of plugin it is in.
It can also include the `module_utils` and `modules` directory that
would contain module utils and modules respectively.

Here is an example directory of the majority of plugins currently supported by Ansible
(as of v2.11):

```
└── plugins
    ├── action
    ├── become
    ├── cache
    ├── callback
    ├── cliconf
    ├── connection
    ├── filter
    ├── httpapi
    ├── inventory
    ├── lookup
    ├── module_utils
    ├── modules
    ├── netconf
    ├── shell
    ├── strategy
    ├── terminal
    ├── test
    └── vars
```

A full list of plugin types can be found at [Working With Plugins](https://docs.ansible.com/ansible/2.11/plugins/plugins.html).
