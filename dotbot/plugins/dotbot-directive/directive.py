import dotbot


class Directive(dotbot.Plugin):
    """
    Wraps other directives under a custom name so they can be selectively
    skipped with ``--except <name>`` (or targeted with ``--only <name>``).

    Usage in install.conf.yaml::

        - my-custom-group:
            - link:
                ~/.vimrc: dotfiles/vim/vimrc
            - shell:
                - [echo hello, echo]

    Running ``./install --except my-custom-group`` will skip the entire block.
    """

    # Names that the dotbot dispatcher handles specially.
    _RESERVED = {"defaults", "plugins"}

    def can_handle(self, directive):
        # Handle any directive name that is not reserved and not claimed
        # by another loaded plugin (i.e. treat it as a custom group name).
        if directive in self._RESERVED:
            return False
        for plugin_cls in self._context._plugins or []:
            if plugin_cls is type(self):
                continue
            d = getattr(plugin_cls, "_directive", None)
            if d == directive:
                return False
        return True

    def handle(self, directive, data):
        self._log.lowinfo("directive '{}': starting".format(directive))

        if not isinstance(data, list):
            self._log.error(
                "directive '{}': expected a list of actions".format(directive)
            )
            return False

        # Build plugin instances from every other registered plugin class.
        plugins = []
        for plugin_cls in self._context._plugins or []:
            if plugin_cls is type(self):
                continue
            plugins.append(plugin_cls(self._context))

        success = True
        for task in data:
            for action, action_data in task.items():
                if action == "defaults":
                    self._context.set_defaults(action_data)
                    continue

                handled = False
                for plugin in plugins:
                    if plugin.can_handle(action):
                        try:
                            local_success = plugin.handle(action, action_data)
                            success = success and local_success
                            handled = True
                        except Exception as err:
                            self._log.error(
                                "directive '{}': error in action '{}'".format(
                                    directive, action
                                )
                            )
                            self._log.debug(str(err))
                            success = False

                if not handled:
                    self._log.error(
                        "directive '{}': action '{}' not handled".format(
                            directive, action
                        )
                    )
                    success = False

        self._log.lowinfo("directive '{}': finished".format(directive))
        return success
