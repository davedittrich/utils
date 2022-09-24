davedittrich.utils.ip_in_issue
==============================

Version: 0.7.0-rc.52

This role ensures that the system's ``/etc/issue`` file contains the host's
name, SSH public keys and IP addresses of active interfaces.


```
TASK [davedittrich.utils.ip_in_issue : Debug SSH host fingerprints.] ***********
task path: /Users/dittrich/.ansible/collections.dev/ansible_collections/davedittrich/utils/roles/ip_in_issue/tasks/main.yml:75
ok: [instance] => {
    "msg": {
        "/etc/ssh/ssh_host_ecdsa_key.pub": "256 SHA256:trN9Mf9KNG+J4ARPtIA8UfUmtuTyN/atJlOjk5FI4/A root@32e5a3399247 (ECDSA)",
        "/etc/ssh/ssh_host_ed25519_key.pub": "256 SHA256:Y0yRyMj8Wcq/JS2mSsItmubyOHil/kpKRfLVhj8KKM4 root@32e5a3399247 (ED25519)",
        "/etc/ssh/ssh_host_rsa_key.pub": "2048 SHA256:FpOkOewudptRYr1C/nJjZTT7Bq1rVKPcVKtc8rijwjQ root@32e5a3399247 (RSA)"
    }
}
```

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
         - { role: davedittrich.utils.ip_in_issue }

There is a playbook for applying this role in the ``playbooks/`` directory for this
collection.  It can be used as follows:

    ANSIBLE_COLLECTIONS_PATH=~/.ansible/collections.dev ansible-playbook -i 192.168.0.107,  playbooks/ip_in_issue.yml


License
-------

Apache 2.0

Author Information
------------------

Dave Dittrich < dave.dittrich@gmail.com >
https://davedittrich.github.io/
