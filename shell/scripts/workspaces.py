#!/usr/bin/env python3.6

from __future__ import print_function

import argparse
import os
import yaml

WORKSPACES_FILE = os.path.join(
    os.getenv("DOTFILES_ROOT"), "shell/workspaces.yaml"
)
current_workspace_var = "CURRENT_WORKSPACE"

ACTIONS = {
    "cd": 'echo "cd to [{root}]"; builtin cd {root};',
    "source": ";\n".join(
        [
            'echo "Sourcing [{root}/{source}]"',
            "set -x",
            "export CURRENT_WORKSPACE={name}",
            "ln -sfn {root}/ ~/current_workspace",
            "builtin cd {root}",
            "tmux rename-window \"$(git symbolic-ref HEAD | sed 's#^refs/heads/##')\" | true",
            "set +x",
            "source {root}/{source}",
        ]
    ),
}


def parse_args(argv=None):
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers()

    dump_subparser = subparsers.add_parser("dump_options")
    dump_subparser.add_argument("--prev", nargs="?", default=None)
    dump_subparser.add_argument("--cur", nargs="?", default=None)
    dump_subparser.set_defaults(func=dump_options)

    list_subparser = subparsers.add_parser("list_workspaces")
    list_subparser.set_defaults(func=list_workspaces)

    for key, action_fmt in ACTIONS.items():
        action_subparser = subparsers.add_parser(key)
        action_subparser.add_argument("--worktree_name", default="driving")
        action_subparser.add_argument(
            "workspace_name",
            nargs="?",
            default=os.getenv(current_workspace_var),
        )
        action_subparser.set_defaults(action=key, func=build_action)

    return parser.parse_args(args=argv)


def dump_options(args):
    options = []
    if args.prev in ACTIONS.keys():
        options = enumerate_worktrees().names()
    else:
        options = ACTIONS.keys()
    print(" ".join(options))


def list_workspaces(args):
    options = sorted(enumerate_worktrees().names())
    print(" ".join(options))


def load_workspace_file():
    with open(WORKSPACES_FILE, "r") as stream:
        try:
            return yaml.load(stream, Loader=yaml.SafeLoader)
        except yaml.YAMLError as exc:
            print(exc)


class Worktree(object):
    def __init__(self, repo_name, root, root_checkout, source):
        self.repo_name = repo_name
        self.root_ = root
        self.root_checkout = root_checkout
        self.source_ = source

    @staticmethod
    def build_worktree(body):
        return Worktree(
            body["repo_name"],
            body["root"],
            body["root_checkout"],
            body["source"],
        )

    def subtrees(self):
        with os.scandir(self.root_) as it:
            for entry in it:
                if entry.is_dir():
                    yield entry.name

    def subtree_root(self, name):
        return os.path.join(self.root_, name)

    def format_action(self, name, action):
        return action.format(
            name=name, root=self.subtree_root(name), source=self.source_
        )


class Worktrees(object):
    def __init__(self):
        self.worktrees_ = dict()

    def names(self):
        l = []
        for name, w in self.worktrees_.items():
            l.extend(w.subtrees())
        return l

    def add_worktree_dir(self, body):
        tree = Worktree.build_worktree(body)
        self.worktrees_[tree.repo_name] = tree

    def worktree(self, worktree_name):
        return self.worktrees_[worktree_name]

    def format_action(self, worktree_name, workspace_name, action_fmt):
        return self.worktree(worktree_name).format_action(
            workspace_name, action_fmt
        )


def enumerate_worktrees():
    ws_file = load_workspace_file()
    trees = Worktrees()
    for worktree in ws_file["worktree_dirs"]:
        trees.add_worktree_dir(worktree)
    return trees


def build_action(args):
    workspaces = enumerate_worktrees()
    action_fmt = ACTIONS[args.action]
    print(
        workspaces.format_action(
            args.worktree_name, args.workspace_name, action_fmt
        )
    )


def main(argv=None):
    args = parse_args(argv)
    args.func(args)


if __name__ == "__main__":
    main()
