#!/usr/bin/env python2

from __future__ import print_function

import argparse
import os
import pprint
import yaml

WORKSPACES_FILE=os.path.join(os.getenv('DOTFILES_ROOT'), 'shell/workspaces.yaml')
current_workspace_var = 'CURRENT_WORKSPACE'

ACTIONS = {
    'cd': 'echo "cd to [{root}]"; builtin cd {root};',
    'source': 'echo "Sourcing [{root}/{source}]";' \
              'set -x;' \
              'export CURRENT_WORKSPACE={name};' \
              'ln -sfn {root}/ ~/current_workspace;' \
              'builtin cd {root};' \
              'set +x;'
              'source {root}/{source};' \
}

def parse_args(argv=None):
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers()

    dump_parser = subparsers.add_parser('dump_options')
    dump_parser.add_argument('--prev', nargs='?', default=None)
    dump_parser.add_argument('--cur', nargs='?', default=None)
    dump_parser.set_defaults(func=dump_options)
    for key, action_fmt in ACTIONS.items():
        action_parser = subparsers.add_parser(key)
        action_parser.add_argument('workspace_name', nargs='?',
                default=os.getenv(current_workspace_var))
        action_parser.set_defaults(action=key, func=build_action)

    return parser.parse_args(args=argv)

def dump_options(args):
    options = []
    if args.prev in ACTIONS.keys():
        options = load_workspaces().keys()
    else:
        options = ACTIONS.keys()
    print(' '.join(options))

def load_workspaces():
    with open(WORKSPACES_FILE, 'r') as stream:
        try:
            workspaces = yaml.load(stream)
            for name, ws in workspaces.items():
                ws['name'] = name
            return workspaces
        except yaml.YAMLError as exc:
            print(exc)

def build_action(args):
    workspaces = load_workspaces()
    workspace = workspaces[args.workspace_name]
    action_fmt = ACTIONS[args.action]
    print(action_fmt.format(**workspace))

def main(argv=None):
    args = parse_args(argv)
    args.func(args)

if __name__ == "__main__":
    main()
