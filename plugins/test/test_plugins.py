# -*- coding: utf-8 -*-

def _include_in_issue(string, exclude_prefixes=None):
    """
    Test for inclusion of interface in the /etc/issue file.

    By default, interfaces that start with the following strings
    are excluded from inclusion: 'veth', 'br', 'tun', and 'docker'.
    The loopback interface ('lo') is always excluded.
    """
    if exclude_prefixes is None:
        # TODO(dittrich): NOT DRY: These are replicated in roles/ip_in_issue/defaults/main.yml  # noqa
        # until I can make them DRY.
        exclude_prefixes = ['br', 'docker', 'tun', 'veth']
    # Always exclude loopback.
    if 'lo' not in exclude_prefixes:
        exclude_prefixes.append('lo')
    result = True
    for prefix in exclude_prefixes:
        if string.startswith(prefix):
            result = False
            continue
    return result


class TestModule(object):
    """
    Ansible test plugin definitions for davedittrich.utils collection.
    """

    def tests(self):
        return {
            'include_in_issue': _include_in_issue,
        }


# vim: set fileencoding=utf-8 ts=4 sw=4 tw=0 et :
