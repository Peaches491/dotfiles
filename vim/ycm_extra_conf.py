# -*- coding: utf-8 -*-
import os
import ycm_core


#def IsHeaderFile(filename):
#   extension = os.path.splitext(filename)[1]
#   return extension in ['.hpp', '.hxx', '.hh', '.h', '.inl', '.impl']
 
##########################################################################
# ycm_extra_conf.py for ROS                                              #
# Author: Gaël Ecorchard (2014)                                          #
#                                                                        #
# Place this file in your ROS catkin workspace to use it.                #
#                                                                        #
# License: CC0                                                           #
##########################################################################
 
 
def getRosIncludePaths():
    import os
    try:
        from rospkg import RosPack
    except ImportError:
        return []
    rospack = RosPack()
    includes = []
    includes.append(os.path.expandvars('$ROS_WORKSPACE') + '/devel/include')
    for p in rospack.list():
        if os.path.exists(rospack.get_path(p) + '/include'):
            includes.append(rospack.get_path(p) + '/include')
    if os.path.exists('/opt/ros/indigo/include'):
        includes.append('/opt/ros/indigo/include')
    if os.path.exists('/opt/ros/hydro/include'):
        includes.append('/opt/ros/hydro/include')
    return includes
 
 
def getRosIncludeFlags():
    includes = getRosIncludePaths()
    flags = []
    for include in includes:
        flags.append('-isystem')
        flags.append(include)
    return flags
 
# some default flags
# for more information install clang-3.2-doc package and
# check UsersManual.html
flags = [
    '-Wall',
    '-Werror',
 
    # std is required
    # clang won't know which language to use compiling headers
    '-std=c++98',
 
    # '-x' and 'c++' also required
    # use 'c' for C projects
    '-x',
    'c++',
 
    # include third party libraries
    # '-isystem',
    # '/some/path/include',
] + getRosIncludeFlags()
 
 
# youcompleteme is calling this function to get flags
# You can also set database for flags. Check: JSONCompilationDatabase.html in
# clang-3.2-doc package
def FlagsForFile(filename):
    return {
        'flags': flags,
        'do_cache': True
    }
