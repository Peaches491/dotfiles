from __future__ import absolute_import
import os
from dotfiles.package_base import *
from dotfiles.util import *
from dotfiles.config import *
from cStringIO import StringIO

colors = {
    'black':'0',
    'red':'1',
    'green':'2',
    'yellow':'3',
    'blue':'4',
    'purple':'5',
    'cyan':'6',
    'white':'7'
}
color_prefixes = [
    '',
    'background_',
    'bold_',
    'underline_',
]

class bashrc(PackageBase):
    def programs(self):
        return ('export EDITOR='+self.config.bash.programs.editor+'\n'+
                'export PAGER='+self.config.bash.programs.pager+'\n')

    def aliases(self):
        result = ''
        for key in sorted(self.config.bash.aliases.keys()):
            value = self.config.bash.aliases[key]
            comment = self.config.bash.aliases[key+'.comment']
            if type(value) == Config:
                name = value.name
                value = value.value
            else:
                name = key

            if comment is None:
                result += 'alias '+name+'='+value+'\n'
            else:
                result += 'alias '+name+'='+value+'\t\t# '+comment+'\n'
        return result

    def bash_colors(self):
        result = StringIO()
        def def_color(name, code):
            color_string = '\e['+code+'m'
            result.write("bash_prompt_"+name+"='\["+color_string+"\]'\n")
            result.write("bash_"+name+"='"+color_string+"'\n")

        def_color('normal', '0')
        for color in colors:
            def_color(color, '0;3'+colors[color])
            def_color('bold_'+color, "1;3"+colors[color])
            def_color('underline_'+color, "4;3"+colors[color])
            def_color('background_'+color, "4"+colors[color])
        return result.getvalue()

    def path(self):
        result = StringIO()
        def write_path_bash(paths, path_var):
            if len(paths) > 0:
                new_path = ''
                for path_entry in paths:
                    new_path = new_path + path_entry+':'
                new_path = new_path + '$'+path_var
                result.write('export '+path_var+'='+new_path+'\n')
        write_path_bash(self.config.bash.path, 'PATH')
        write_path_bash(self.config.bash.ldpath, 'LD_LIBRARY_PATH')
        return result.getvalue()

    def bash_completion(self):
        result = StringIO()
        for completion_dir in self.config.bash.completion_dir:
            result.write('for f in '+os.path.join(completion_dir, '*')+'; do\n')
            result.write('\tsource $f\n')
            result.write('done\n')
        for completion_file in self.config.bash.completion_file:
            result.write('if [ -f '+completion_file+' ]; then\n')
            result.write('\tsource '+completion_file+'\n')
            result.write('fi\n')
        return result.getvalue()

    def prompt(self):
        def expand(text):
            for color in colors:
                for prefix in color_prefixes:
                    text = text.replace('%'+prefix+color, '${bash_prompt_'+prefix+color+'}')
            text = text.replace('%normal', '${bash_prompt_normal}')
            return text

        f = StringIO()
        files = filter(lambda f: f.endswith('.bashprompt'), all_files_recursive(self.base_file('bash')))
        for prompt_f in files:
            f.write(read_file(prompt_f))
            f.write('\n')

        f.write('function prompt_command() {\n')
        f.write('\tEXIT_STATUS=$?\n')
        for statement in self.config.bash.prompt['eval']:
            f.write('\t'+statement+'\n')
        for var in self.config.bash.prompt.vars.keys():
            value = self.config.bash.prompt.vars[var]
            if type(value) is Config:
                f.write('\tif [[ '+value['if']+' ]]; then\n')
                f.write('\t\t'+var+'='+expand(value['then'])+'\n')
                f.write('\telse\n')
                f.write('\t\t'+var+'='+expand(value['else'])+'\n')
                f.write('\tfi\n')
            else:
                f.write('\t'+var+'='+expand(value)+'\n')
        f.write('\tPS1='+expand(self.config.bash.prompt.template)+'\n')

        f.write('\t# set title bar\n')
        f.write('\tcase "$TERM" in\n')
        f.write('\t\txterm*|rxvt*)\n')
        f.write('\t\t\tPS1="\\[\\e]0;\\u@\\h: \\w\\a\\]$PS1"\n')
        f.write('\t\t\t;;\n')
        f.write('\t\t*)\n')
        f.write('\t\t\t;;\n')
        f.write('\tesac\n')
        f.write('\t\n')
        f.write('}\n')
        f.write('PROMPT_COMMAND=prompt_command;')
        return f.getvalue()

    def build_bashrc_file(self):
        with logger.frame('Building bashrc'):
            bash_files = filter(lambda path: path.endswith('.bashrc'), all_files_recursive(self.base_file('bash')))
            raw_file_parts = map(lambda path: (os.path.basename(path), lambda: read_file(path)), bash_files)
            dynamic_parts = [
                ('05-programs', self.programs),
                ('10-aliases', self.aliases),
                ('51-bash-colors', self.bash_colors),
                ('85-prompt', self.prompt),
                ('91-path', self.path),
                ('92-bash-completion', self.bash_completion)
            ]
            configured_parts = []
            self.config.bash.ensure('parts')
            for part_name in self.config.bash.parts.keys():
                configured_parts.append((part_name, lambda: self.config.bash.parts[part_name]))
            all_parts = sorted(raw_file_parts + dynamic_parts + configured_parts, key=lambda x: x[0])

            with open(self.build_file('.bashrc'), 'w') as f:
                for part in all_parts:
                    with logger.trylog(str(part[0]), verbose=True):
                        f.write('##'+part[0]+'\n')
                        f.write(part[1]())
                        f.write('\n')

    def install(self):
        return concat_lists(
            [self.build_bashrc_file],
            self.action('file').symlink(self.home_file('.bashrc'), self.build_file('.bashrc'))
        )
