#!/usr/bin/env python3.6

from __future__ import print_function

import abc
import argparse
import logging
import os
import sys
import yaml

log = logging.getLogger(__name__)

WORKSPACES_FILE = os.path.join(
    os.getenv("DOTFILES_ROOT"), "shell/workspaces.yaml"
)


def base_arg_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument("--verbose", action="store_true")

    subparsers = parser.add_subparsers()

    dump_subparser = subparsers.add_parser("dump_options")
    dump_subparser.add_argument("forest", nargs="?", default=None)
    dump_subparser.add_argument("--all", nargs="*", default=None)
    dump_subparser.set_defaults(func=dump_options)

    list_subparser = subparsers.add_parser("list_workspaces")
    list_subparser.add_argument("forest")
    list_subparser.set_defaults(func=list_workspaces)

    return parser, subparsers


class Action(metaclass=abc.ABCMeta):
    action_instances = []

    @classmethod
    def __init_subclass__(cls, **kwargs):
        super().__init_subclass__(**kwargs)
        log.debug(f"Instantiating action: {cls}")
        instance = cls()
        log.debug(f"Instantiated action: {instance}")
        Action.action_instances.append(instance)

    @classmethod
    def all_actions(_):
        return [a.__action_name__ for a in Action.action_instances]

    @classmethod
    def add_action_parsers(_, subparsers):
        for action in Action.action_instances:
            subparser = subparsers.add_parser(action.__action_name__)
            subparser.set_defaults(
                action_name=action.__action_name__, func=action.do
            )
            action.parse_args(subparser)

    def get_action(action_name):
        log.debug(f"Searching for Action: {action_name}")
        action = next(
            (
                a
                for a in Action.action_instances
                if a.__action_name__ == action_name
            ),
            None,
        )
        if not action:
            raise RuntimeError(f"Action not found: {action_name}")

        log.debug(f"Found action for [{action_name}]: {action}")
        return action

    @abc.abstractmethod
    def parse_args(self, subparser):
        raise NotImplementedError()

    @abc.abstractmethod
    def autocomplete(self, argv):
        raise NotImplementedError()

    @abc.abstractmethod
    def do(self, args):
        raise NotImplementedError()


class CreateAction(Action):
    __action_name__ = "create"

    def parse_args(self, subparser):
        subparser.add_argument("forest")
        subparser.add_argument("branch")
        subparser.add_argument("worktree", default=None, nargs="?")

    def autocomplete(self, argv):
        forests = load_forests()
        forest_names = [f.name for f in load_forests()]
        if not argv or (len(argv) == 1 and argv[0] not in forest_names):
            return forest_names
        else:
            # TODO: List git branches
            return load_forest(argv[0]).worktree_names()

    def do(self, args):
        if not args.worktree:
            args.worktree = args.branch

        tree = self.add_worktree(args.worktree)
        return "\n".join(
            [
                "(set -euxo pipefail;",
                f"cd {self.root_checkout_dir()};",
                f"echo 'Creating new worktree: {args.worktree}';",
                f"git worktree add --detach {tree.root()};",
                f"cd {tree.root()};",
                f"git checkout {args.branch};",
                f"workspace {args.forest} source {args.worktree};",
                ")",
            ]
        )


class SourceAction(Action):
    __action_name__ = "source"

    def parse_args(self, subparser):
        subparser.add_argument("forest")
        subparser.add_argument("tree")

    def autocomplete(self, argv):
        forests = load_forests()
        forest_names = [f.name for f in load_forests()]
        if not argv or (len(argv) == 1 and (argv[0] not in forest_names)):
            return forest_names
        else:
            return load_forest(argv[0]).worktree_names()

    def do(self, args):
        forest = load_forest(args.forest)
        tree = forest.worktree(args.tree)
        return "\n".join(
            [
                f"echo 'Activating workspace: {tree.name}';",
                f"builtin cd {tree.root()};",
                "tmux rename-window \"$(git symbolic-ref HEAD | sed 's#^refs/heads/##')\" | true;",
                f"echo 'Sourcing workspace [{tree.name}]: {forest.source_file()}';",
                f"source '{tree.source_file()}';",
            ]
        )


class ChdirAction(Action):
    __action_name__ = "cd"

    def parse_args(self, subparser):
        subparser.add_argument("forest")
        subparser.add_argument("tree")

    def autocomplete(self, argv):
        forests = load_forests()
        forest_names = [f.name for f in load_forests()]
        if not argv or (len(argv) == 1 and (argv[0] not in forest_names)):
            return forest_names
        else:
            return load_forest(argv[0]).worktree_names()

    def do(self, args):
        forest = load_forest(args.forest)
        tree = forest.worktree(args.tree)
        return f"builtin cd {tree.root()};"


class WorkTree(object):
    def __init__(self, parent, name):
        self.parent = parent
        self.name = name

    def root(self):
        return os.path.join(self.parent.root_, self.name)

    def source_file(self):
        return os.path.join(self.root(), self.parent.source_file())


class WorkForest(object):
    def __init__(self, body):
        self.name = body["name"]
        self.root_ = body["root"]
        self.root_checkout = body["root_checkout"]
        self.source_ = body["source"]

        self.worktrees_ = dict()

        self._find_worktrees()

    def _find_worktrees(self):
        with os.scandir(self.root_) as it:
            for entry in it:
                if entry.is_dir():
                    self.add_worktree(entry.name)

    def add_worktree(self, name):
        log.debug(f"Adding worktree: {name}")
        self.worktrees_[name] = WorkTree(self, name)
        return self.worktrees_[name]

    def worktree_names(self):
        return self.worktrees_.keys()

    def worktree(self, worktree):
        return self.worktrees_[worktree]

    def root_checkout_dir(self):
        return os.path.join(self.root_, self.root_checkout)

    def source_file(self):
        return self.source_


def load_forests():
    ws_file = yaml.load(open(WORKSPACES_FILE, "r"), Loader=yaml.SafeLoader)
    forests = []
    for forest_description in ws_file["workforest"]:
        forest = WorkForest(forest_description)
        forests.append(forest)
    return forests


def load_forest(forest_name):
    for forest in load_forests():
        if forest.name == forest_name:
            return forest
    else:
        log.error(f"Forest not found: {forest_name}")


def list_all_forests_and_trees():
    forests = load_forests()
    for forest in forests:
        for tree in forest.worktree_names():
            yield "/".join([forest.name, tree])


def dump_options(args):
    log.debug(sys.argv)
    log.debug(f"All comp words: {args.all}")

    comp = args.all[1:]  # Strip off leading 'workspace' arg
    log.debug(f"stripped: {comp}")

    options = []
    if not comp or comp[0] not in Action.all_actions():
        log.debug(f"stripped: {comp}")
        options = Action.all_actions()
    else:
        options = Action.get_action(comp[0]).autocomplete(comp[1:])

    log.debug(f"suggestions: {options}")
    return " ".join(options)


def list_workspaces(args):
    forest = load_forest(args)
    options = sorted(forest.worktree_names())
    return " ".join(options)


def build_action(args):
    forest = load_forest(args)

    action = Action.get_action(args.action_name)

    cmd = action(args)

    return cmd


def main(argv=None):
    verbose = bool(os.getenv("WORKSPACE_VERBOSE", False))
    logging.basicConfig(level=(logging.DEBUG if verbose else logging.WARNING))

    parser, subparsers = base_arg_parser()
    Action.add_action_parsers(subparsers)

    args = parser.parse_args(argv)

    print(args.func(args))


if __name__ == "__main__":
    main()
