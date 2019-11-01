#!/usr/bin/env python2

from __future__ import print_function

import argparse
import os
import pprint
import yaml

WORKSPACES_FILE = os.path.join(
    os.getenv('DOTFILES_ROOT'), 'shell/workspaces.yaml')
current_workspace_var = 'CURRENT_WORKSPACE'

ACTIONS = {
    'cd': 'echo "cd to [{root}]"; builtin cd {root};',
    'source': ';\n'.join([
        'echo "Sourcing [{root}/{source}]"',
        'set -x',
        'export CURRENT_WORKSPACE={name}',
        'ln -sfn {root}/ ~/current_workspace',
        'builtin cd {root}',
        'tmux rename-window "$(git symbolic-ref HEAD | sed \'s#^refs/heads/##\')" | true',
        'set +x',
        'source {root}/{source}',
    ])
}


def parse_args(argv=None):
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers()

    dump_subparser = subparsers.add_parser('dump_options')
    dump_subparser.add_argument('--prev', nargs='?', default=None)
    dump_subparser.add_argument('--cur', nargs='?', default=None)
    dump_subparser.set_defaults(func=dump_options)

    list_subparser = subparsers.add_parser('list_workspaces')
    list_subparser.set_defaults(func=list_workspaces)

    for key, action_fmt in ACTIONS.items():
        action_subparser = subparsers.add_parser(key)
        action_subparser.add_argument(
            'workspace_name',
            nargs='?',
            default=os.getenv(current_workspace_var))
        action_subparser.set_defaults(action=key, func=build_action)

    return parser.parse_args(args=argv)


def dump_options(args):
    options = []
    if args.prev in ACTIONS.keys():
        options = load_workspaces().keys()
    else:
        options = ACTIONS.keys()
    print(' '.join(options))


def list_workspaces(args):
    options = sorted([ws['root'] for name, ws in load_workspaces().items()])
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
