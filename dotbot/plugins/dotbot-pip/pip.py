# Vendored from https://github.com/sobolevn/dotbot-pip
# Copyright (c) 2017 Sobolev Nikita, MIT License.
# Modifications under the same license.
import os
import subprocess

import dotbot


class Pip(dotbot.Plugin):
    _directive = 'pip'

    _default_stdout = False
    _default_stderr = False
    _default_user = False
    _default_upgrade = False

    def can_handle(self, directive):
        return directive == self._directive

    def handle(self, directive, data):
        data = self._maybe_convert_to_dict(data)

        try:
            self._resolve_requirements_path(data)
            self._handle_install(data)
            return True
        except ValueError as e:
            self._log.error(e)
            return False

    @property
    def cwd(self):
        return self._context.base_directory()

    def _maybe_convert_to_dict(self, data):
        if isinstance(data, str):
            return {'file': data}
        return data

    def _resolve_requirements_path(self, data):
        path = data.get('file')
        if not path:
            raise ValueError('No requirements file specified')

        message = 'Requirements file "{}" does not exist'.format(path)
        path = os.path.expandvars(path)
        path = os.path.expanduser(path)
        path = os.path.join(self.cwd, path)

        if not os.path.isfile(path):
            raise ValueError(message)

        data['file'] = path

    def _get_binary(self, data):
        return data.get('binary') or self._directive

    def _get_parameters(self, data):
        return {
            'stdout': data.get('stdout', self._default_stdout),
            'stderr': data.get('stderr', self._default_stderr),
            'user': data.get('user', self._default_user),
            'upgrade': data.get('upgrade', self._default_upgrade),
        }

    def _handle_install(self, data):
        binary = self._get_binary(data)
        parameters = self._get_parameters(data)

        flags = []
        if parameters['user']:
            flags.append('--user')
        if parameters['upgrade']:
            flags.append('--upgrade')

        command = '{} install {} -r {}'.format(
            binary, ' '.join(flags), data['file']
        )

        with open(os.devnull, 'w') as devnull:
            result = subprocess.call(
                command,
                shell=True,
                stdin=devnull,
                stdout=None if parameters['stdout'] else devnull,
                stderr=None if parameters['stderr'] else devnull,
                cwd=self.cwd,
            )

            if result not in [0, 1]:
                raise ValueError('Failed to install requirements.')
