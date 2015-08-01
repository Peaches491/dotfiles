#! /usr/bin/env python
import os
import os.path
import glob
import sys

backup_directory = '.backup'
backup_prefix = ''
backup_suffix = '.old'


def is_broken_link(path):
    lstat_success = False
    stat_success = False
    try:
        os.lstat(path)
        lstat_success = True
        os.stat(path)
        stat_success = True
    except OSError, e:
        pass
    return lstat_success and not stat_success

def create_symlink(src, name, backup=True):
    """:type src: str"""
    """:type dst: str"""

    if not os.path.exists(src):
        return False

    src = os.path.abspath(src)
    name = os.path.expanduser(name)

    # If this link alread exists, return
    if os.path.islink(name) and os.readlink(name) == src:
        return True

    # If the target exists or is a broken link
    if os.path.exists(name) or is_broken_link(name):
        name = os.path.abspath(name)
        idx = name.rfind('/')
        backup_name = name[:idx] + ('/' if idx>=0 else '') + backup_directory + name[idx:]
        if not os.path.exists(backup_name) and backup:
            print "Creating Backup of {} at {}".format(name, backup_name)
            os.renames(name, backup_name)
        else:
            os.remove(name)
    os.symlink(src, name)
    return is_broken_link(name)

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print "Improper use of link.py!"
        print "  link.py /path/to/source /path/to/new/link"
    create_symlink(sys.argv[1], sys.argv[2])
