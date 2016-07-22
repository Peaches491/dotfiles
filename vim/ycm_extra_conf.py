#! /usr/bin/env python

import itertools
import os

def getDefaultFlags():
    return [
        '-Wall',
        '-Wextra',
        '-Wno-unused-result',
        '-Weffc++',
        '--pipe',
        '-std=c++11',
        '-x', 'c++',
    ]

def getSystemIncludeFlags():
    return getIncludePaths('-isystem', [
        '/usr/include',
        '/usr/local/include',
        '/usr/include/eigen3',
        '/opt/ros/indigo/include',
    ])

def getBazelWorkspace(current):
    while len(current) > 1:
        current = os.path.dirname(current)
        if os.path.exists(os.path.join(current, 'WORKSPACE')):
            return current
    return None

def getLocalIncludeFlags(filename):
    paths = [
        '.',
        './include',
    ]
    bazel_workspace = getBazelWorkspace(filename)
    if bazel_workspace != None:
        paths += [
            bazel_workspace,
            os.path.join(bazel_workspace, 'bazel-genfiles'),
        ]
    return getIncludePaths('-I', paths)

def getIncludePaths(prefix, paths):
    paths = filter(lambda path: os.path.exists(path), set(paths))
    return list(itertools.chain.from_iterable(
     itertools.izip([prefix] * len(paths), paths)))

def IsHeaderFile(filename):
    extension = os.path.splitext(filename)[1]
    return extension in ['.hpp', '.hxx', '.hh', '.h', '.inl', '.impl']

def FlagsForFile(filename, **kwargs):
    return {
        'flags': getDefaultFlags() + getSystemIncludeFlags() + \
                 getLocalIncludeFlags(filename),
        'do_cache': True
    }



# import itertools
# import os
# import rospkg
# rospack = rospkg.RosPack()

# def getDefaultFlags():
    # return [
        # '-Wall',
        # '-Wextra',
        # '-Wno-unused-result',
        # '-Weffc++',
        # '--pipe',
        # '-std=c++11',
        # '-x', 'c++',
    # ]

# def getSystemIncludeFlags():
    # return getIncludePaths('-isystem', [
        # '/usr/include',
        # '/usr/local/include',
    # ])

# def getRosIncludeFlags():
    # paths = []

    # ros_workspace = os.path.expandvars('$ROS_WORKSPACE') + '/devel/include'
    # if os.path.isdir(ros_workspace):
        # paths += [ros_workspace]

    # paths += [rospack.get_path(path) + '/include' for path in rospack.list()]

    # if os.path.isdir('/opt/ros'):
        # paths += [
            # os.path.join(path + 'include')
            # for path in reversed(os.listdir('/opt/ros'))
            # if os.path.isdir(path) and os.path.isdir(path + '/include')
        # ]

    # return getIncludePaths('-isystem', paths)


# def getDefaultFlags():
    # return [
        # '-Wall',
        # '-Wextra',
        # '-Wno-unused-result',
        # '-Weffc++',
        # '--pipe',
        # '-std=c++11',
        # '-x', 'c++',
    # ]

# def getSystemIncludeFlags():
    # return getIncludePaths('-isystem', [
        # '/usr/include',
        # '/usr/local/include',
        # '/usr/include/eigen3',
        # '/opt/ros/indigo/include',
    # ])

# def getBazelWorkspace(current):
    # while len(current) > 0:
        # current = os.path.dirname(current)
        # if os.path.exists(os.path.join(current, 'WORKSPACE')):
            # return current
    # return None

# def getLocalIncludeFlags(filename):
    # return getIncludePaths('-I', [
        # '.',
        # './include',
        # getBazelWorkspace(filename),
        # os.path.join(getBazelWorkspace(filename), 'bazel-genfiles'),
    # ])

# def getIncludePaths(prefix, paths):
    # paths = filter(lambda path: os.path.exists(path), set(paths))
    # return list(itertools.chain.from_iterable(
     # itertools.izip([prefix] * len(paths), paths)))

# def IsHeaderFile(filename):
    # extension = os.path.splitext(filename)[1]
    # return extension in ['.hpp', '.hxx', '.hh', '.h', '.inl', '.impl']

# def FlagsForFile(filename, **kwargs):
    # return {
        # 'flags': \
                # getDefaultFlags() + \
                ## getSystemIncludeFlags() + \
                ## getRosIncludeFlags() + \
                # getLocalIncludeFlags(filename),
        # 'do_cache': True
    # }
