#! /usr/bin/python3
from collections import OrderedDict
from shutil import which

__author__ = 'Lene Preuss <lene.preuss@gmail.com>'

programs = OrderedDict({
    "Net": {
        "Chromium": "x",
        "Firefox": "x",
        "Thunderbird": "x",
        "Nicotine": "x",
        "Skype": "x",
        "Slack": "x",
        "Pidgin": "x",
        "Vuze": "x",
        "VirtualBox": "x",
        "KGPG": "x",
    },
    "Dev": {
        "Emacs": "emacs",
    },
    "Fun": {
        "Audacious": "audacious",
    },
    "KCalc": "kcalc",
    "Kate": "kate",
    "XV": "xv"
})


def create_menu(entries):
    menu = ''
    create_menu.indent += 4
    for item in entries.keys():
        indent = " " * create_menu.indent
        if isinstance(entries[item], dict):
            submenu = create_menu(entries[item])
            if submenu:
                menu += '{}<menu id="dynamic_{}" label="{}">\n{}{}</menu>\n'.format(
                    indent, item.lower(), item, submenu, indent
                )
        else:
            if which(entries[item]):
                menu += '{}<item label="{}"><action name="execute"><execute>{}</execute></action></item>\n'.format(
                    indent, item, entries[item]
                )
    create_menu.indent -= 4
    return menu
create_menu.indent = 0

print(
"""<?xml version="1.0" encoding="UTF-8"?>
<openbox_pipe_menu>
{}
</openbox_pipe_menu>
""".format(create_menu(programs))
)
