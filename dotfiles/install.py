#!/usr/bin/python
from __future__ import absolute_import
import os
import shutil
import sys
import glob
import argparse
import inspect

from dotfiles.config import ConfigLoader
from dotfiles.util import *
import dotfiles.module_base as module_base
import dotfiles.package_base as package_base
import dotfiles.src_package as src_package
import dotfiles.logger as logger
from collections import defaultdict
from spgl.relational_database import *

__abstract__ = True

BUILD_DIR_NAME = 'build'
SRC_DIR_NAME = 'src'
GIT_DIR_NAME = '.git'
BUILD_UTIL_DIR_NAME = 'dotfiles_build_packages'

class PackageRelationship(object):
    CONFIGURED_BY = Relationship('configured by')
    CONFIGURES = Relationship('configures')
    make_inverse_relationships(CONFIGURED_BY, CONFIGURES)

    DEPENDED_ON_BY = Relationship('depended on by')
    DEPENDS_ON = Relationship('depends on')
    make_inverse_relationships(DEPENDED_ON_BY, DEPENDS_ON)

    SUGGESTED_BY = Relationship('suggested by')
    SUGGESTS = Relationship('suggests')
    make_inverse_relationships(SUGGESTED_BY, SUGGESTS)

class PackageState:
    UNINITIALIZED = 'uninitialized'
    INITIALIZED = 'initialized'
    INSTALLED = 'installed'
    NOT_INSTALLABLE = 'not installable'
    INSTALL_FAILED = 'install failed'
    ALL = [UNINITIALIZED, INITIALIZED, INSTALLED, NOT_INSTALLABLE, INSTALL_FAILED]

class PackageInfo(RelationalDatabaseNode):
    def __init__(self, name):
        super(PackageInfo, self).__init__(name)
        self.install_steps = None
        self.state = PackageState.UNINITIALIZED
        self.state_message = None
        self.state_error = None

    @property
    def name(self):
        return self.key

class PackageCollection(object):
    def __init__(self, context, raw_packages, package_factories, package_aliases):
        self.packages = RelationalDatabase()
        self.context = context
        self.raw_packages = raw_packages
        self.package_factories = package_factories
        self.package_aliases = package_aliases

    def resolve_package_alias(self, name):
        if name in self.package_aliases:
            return self.package_aliases[name]
        return name

    def resolve_package_aliases(self, names):
        result = map(self.resolve_package_alias, names)
        if type(names) is set:
            return set(result)
        return result

    def ensure_package(self, name):
        if name not in self.packages:
            self.packages.add_node(PackageInfo(name))
        return self.packages[name]

    def add_package(self, name):
        name = self.resolve_package_alias(name)
        if name not in self.packages:
            if ':' in name:
                factory_name = name.split(':')[0]
                arg = name.split(':')[1]
                package_factory = find_by_name(self.package_factories, factory_name)
                if package_factory is None:
                    raise Exception('Cannot resolve package factory name: '+factory_name+' for package: '+name)
                package = package_factory.build(arg)
            else:
                package = find_by_name(self.raw_packages, name)
            if package is None:
                raise Exception('Could not find package: '+name)
            package.init_package(self.context)
            try:
                install_steps = package.install()
            except Exception as e:
                install_steps = None
                install_steps_error = e

            package_info = self.ensure_package(package.name())
            package_info.install_steps = install_steps
            if install_steps is not None:
                for step in install_steps:
                    for dep_name in self.resolve_package_aliases(object_deps(step)):
                        self.add_package(dep_name)
                        package_info.add_relationship(PackageRelationship.DEPENDS_ON, dep_name)
            for dep_name in self.resolve_package_aliases(object_deps(package)):
                self.add_package(dep_name)
                package_info.add_relationship(PackageRelationship.DEPENDS_ON, dep_name)
            for suggest_name in self.resolve_package_aliases(object_suggestions(package)):
                self.add_package(suggest_name)
                package_info.add_relationship(PackageRelationship.SUGGESTS, suggest_name)
            for configures_name in self.resolve_package_aliases(object_configures(package)):
                self.ensure_package(configures_name)
                package_info.add_relationship(PackageRelationship.CONFIGURES, configures_name)

            if install_steps is None:
                package_info.state = PackageState.NOT_INSTALLABLE
                package_info.state_error = install_steps_error
            else:
                package_info.state = PackageState.INITIALIZED


    def get_installable_packages(self):
        installable_packages = set()
        for package_name in self.packages.keys():
            package_info = self.packages[package_name]
            if package_info.state == PackageState.INITIALIZED:
                deps_satisfied = True
                for dep in package_info.get_related(PackageRelationship.DEPENDS_ON):
                    if dep.state != PackageState.INSTALLED:
                        deps_satisfied = False
                configured_satisfied = True
                for dep in package_info.get_related(PackageRelationship.CONFIGURED_BY):
                    if dep.state != PackageState.INSTALLED and dep.state != PackageState.NOT_INSTALLABLE:
                        configured_satisfied = False
                if deps_satisfied and configured_satisfied:
                    installable_packages.add(package_info)
        return installable_packages

    def propagate_package_state(self):
        action_taken = True
        while action_taken:
            action_taken = False
            for package_name in self.packages.keys():
                package_info = self.packages[package_name]
                if package_info.state == PackageState.INITIALIZED:
                    for dep in package_info.get_related(PackageRelationship.DEPENDS_ON):
                        if dep.state == PackageState.NOT_INSTALLABLE:
                            package_info.state = PackageState.NOT_INSTALLABLE
                            package_info.state_message = 'Dep \''+dep.name+'\' is not installable'
                            action_taken = True
                        if dep.state == PackageState.INSTALL_FAILED:
                            package_info.state = PackageState.NOT_INSTALLABLE
                            package_info.state_message = 'Dep \''+dep.name+'\' failed to install'
                            action_taken = True


def load_packages(path):
    packages = []
    action_factories = []
    package_factories = []
    files = all_files_recursive(path)
    name = os.path.basename(path)

    for filename in files:
        filepath = os.path.join(path, filename)
        if filename.endswith('~'):
            continue
        if filename.endswith('.pyc'):
            continue
        if not os.path.isfile(filepath):
            continue

        if filename.endswith('__init__.py'):
            continue
        if filename.endswith('.py'):
            try:
                py_mod = load_py(name+'.'+filename.replace('.py', ''), filepath)
                mod_found = False
                for name in py_mod.__dict__:
                    thing = py_mod.__dict__[name]
                    if inspect.isclass(thing):
                        if thing.__module__ != py_mod.__name__:
                            continue
                        if not is_abstract(thing):
                            if issubclass(thing, package_base.PackageBase):
                                logger.success('Loading package: '+filename+':'+name, verbose=True)
                                mod_found = True
                                package = thing()
                                packages.append(package)
                            elif issubclass(thing, package_base.PackageActionFactory):
                                logger.success('Loading package action factory: '+filename+':'+name, verbose=True)
                                mod_found = True
                                action_factory = thing()
                                action_factories.append(action_factory)
                            elif issubclass(thing, package_base.PackageFactory):
                                logger.success('Loading package factory: '+filename+':'+name, verbose=True)
                                mod_found = True
                                package_factory = thing()
                                package_factories.append(package_factory)
                            else:
                                logger.warning('Did not load class: ' + str(thing) + ': ' + str(thing.__bases__), verbose=True)
                if not mod_found and not is_abstract(py_mod):
                    logger.failed('No modules found in: '+filename)
            except IOError as e:
                logger.failed( 'Error loading module: '+str(e))
    return (packages, action_factories, package_factories)



def main(rootdir):
    parser = argparse.ArgumentParser(description='Install dotfiles')
    parser.add_argument('--verbose', help="print verbose output", dest='verbose', action='store_true', default=False)

    args = parser.parse_args()
    logger.init(args.verbose)

    logger.log('Root Dir: ' + rootdir)

    builddir = os.path.join(rootdir, BUILD_DIR_NAME)
    srcdir = os.path.join(rootdir, SRC_DIR_NAME)


    if os.path.exists(builddir):
        shutil.rmtree(builddir)
    os.mkdir(builddir)
    if not os.path.exists(builddir):
        os.mkdir(srcdir)

    with logger.frame('Loading Configuration'):
        config_loader = ConfigLoader()
        conf_files = filter(lambda f: f.endswith('.conf') and not f.startswith(srcdir), all_files_recursive(rootdir))
        for f in conf_files:
            with logger.trylog('loading conf: '+f):
                config_loader.load_file(f)
        with logger.trylog('loading user conf file'):
            config_loader.load_file(os.path.expanduser('~/.dotfiles.conf'))


        config = config_loader.build()

        if config.local is None:
            config.assign('local', prompt_yes_no('install local'), float("inf"))


    raw_packages = []
    action_factories = []
    package_factories = []
    with logger.frame('Loading packages'):
        for filename in os.listdir(rootdir):
            fullpath = os.path.join(rootdir, filename)
            if os.path.isdir(fullpath) and not filename.startswith('.') and not filename == SRC_DIR_NAME and not filename == BUILD_DIR_NAME:
                with logger.frame('Loading '+filename):
                    module_packages, module_action_factories, module_package_factories = load_packages(fullpath)
                    raw_packages.extend(module_packages)
                    action_factories.extend(module_action_factories)
                    package_factories.extend(module_package_factories)

    global_context = module_base.GlobalContext(rootdir, srcdir, config, action_factories)

    for factory in action_factories:
        factory.init_factory(global_context)

    logger.log('loaded package action factories: ' + str(names_of_items(action_factories)))
    logger.log('loaded package factories: ' + str(names_of_items(package_factories)))
    logger.log('loaded raw packages: ' + str(names_of_items(raw_packages)))

    package_aliases = config.package_aliases

    # setup path for sub processes
    current_path = os.environ['PATH']
    path = ''
    if len(current_path) > 0:
        path = ':'+current_path
    path = ':'.join([os.path.expanduser(global_context.eval_templates(element)) for element in config.bash.path]) + path
    os.environ['PATH'] = path
    logger.log('Modified PATH: '+path)


    packages = PackageCollection(global_context, raw_packages, package_factories, package_aliases)
    for package_name in config.install:
        packages.add_package(package_name)


    for installable_packages in iter(packages.get_installable_packages, set()):
        with logger.frame('Installing: '+str(names_of_items(installable_packages))):
            for package_info in installable_packages:
                with logger.frame('Installing: '+package_info.name):
                    try:
                        for step in package_info.install_steps:
                            step()
                        package_info.state = PackageState.INSTALLED
                    except Exception as e:
                        package_info.state = PackageState.INSTALL_FAILED
                        package_info.state_error = e
            packages.propagate_package_state()

    for state in PackageState.ALL:
        state_items = filter(lambda node: node.state == state, packages.packages.nodes())
        if len(state_items) > 0:
            with logger.frame(state):
                for package_info in state_items:
                    with logger.frame(package_info.name):
                        if package_info.state_message is not None:
                            logger.log(package_info.state_message)
                        if package_info.state_error is not None:
                            logger.log(str(package_info.state_error))