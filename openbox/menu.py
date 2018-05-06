#! /usr/bin/python3
from collections import OrderedDict
from shutil import which

__author__ = 'Lene Preuss <lene.preuss@gmail.com>'

programs = OrderedDict({
    "Net": {
        "Chromium": "chromium-browser",
        "Firefox": "firefox",
        "Thunderbird": "thunderbird",
        
        "Chat Clients": None,
        "Skype": "skype",
        "Slack": "slack",
        "Telegram": "Telegram",
        "Signal": "signal-desktop",
        "Pidgin": "pidgin",
        
        "File Sharing": None,
        "Nicotine": "/home/lene/workspace/configs/nicotine-tor",
        "Vuze": "vuze",
        "Transmission": "transmission-gtk",

        "Other Stuff": None,
        "VirtualBox": "virtualbox",
        "KGPG": "kgpg",
        "Multibit-HD": "/opt/multibit-hd/multibit-hd",
    },
    "Dev": {
        "Emacs": "emacs",
        "PyCharm": "pycharm.sh",
        "IntelliJ IDEA": "/opt/idea/bin/idea.sh",
        "WebStorm": "webstorm.sh",
        "PHPStorm": "phpstorm.sh",
        "CLion": "/opt/clion/bin/clion.sh",
        "NetBeans": "/opt/netbeans/bin/netbeans",
        "pgAdmin III": "pgadmin3",
        "MySQL Workbench": "mysql-workbench",
        "Qt Creator": "qtcreator",
    },
    "Fun": {
        "Audacious": "audacious",
        "Audacity": "audacity",
        "FBReader": "fbreader",
        "Kerbal Space Program": "/opt/KSP_Linux/KSP.x86_64",
        "Freeciv": "freeciv",
        "Scrivener": "scrivener",
        "K3B": "k3b",
    },
    "Other": {
        "LibreOffice": "soffice"
    },
    "KCalc": "kcalc",
    "Kate": "kate",
    "xv": "xv"
})


def create_menu(entries):
    create_menu.indent += 4
    indent = " " * create_menu.indent
    menu = ''

    for item in entries.keys():
        if isinstance(entries[item], dict):
            submenu = create_menu(entries[item])
            if submenu:
                menu += '{}<menu id="dynamic_{}" label="{}">\n{}{}</menu>\n'.format(
                    indent, item.lower(), item, submenu, indent
                )
        else:
            if entries[item] is None:
                menu += indent + '<separator label="{}"/>\n'.format(item)
            elif which(entries[item]):
                menu += '{}<item label="{}"><action name="execute"><execute>{}</execute></action></item>\n'.format(
                    indent, item, entries[item]
                )
    create_menu.indent -= 4
    return menu
create_menu.indent = 0

print("""<?xml version="1.0" encoding="UTF-8"?>
<openbox_pipe_menu>
{}
</openbox_pipe_menu>
""".format(create_menu(programs))
)
