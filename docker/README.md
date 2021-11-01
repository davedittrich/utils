# Docker images supporting davedittrich.utils molecule testing

This directory is used for building Docker containers that pre-load
software that would be installed on targets using roles in the
`davedittrich.utils` collection. This is done to reduce testing
time by not requiring repeated installation of large numbers of
packages into the reduced `geerlingguy` Ansible images.

# Building images

TODO.

# Debugging image builds

Increased verbosity will result in logging of the Docker build
tasks, allowing you to debug the builds.

    .
    ├── Makefile
    ├── README.md
    ├── ansible.cfg
    ├── build-docker-debian10-ansible.log
    ├── build-docker-debian9-ansible.log
    ├── build-docker-ubuntu1804-ansible.log
    ├── build-docker-ubuntu2004-ansible.log
    └── hosts.yml
