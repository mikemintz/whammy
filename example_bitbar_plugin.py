#!/usr/bin/env LC_ALL=en_US.UTF-8 /usr/local/bin/python3

import json
import sys

NAME_MAP_JSON_PATH = "/Users/mikemintz/.config/desktop-names.json"
name_map = json.load(open(NAME_MAP_JSON_PATH))

def run(cmd):
    import subprocess
    p = subprocess.run(cmd, shell=True, check=True, stdout=subprocess.PIPE)
    return p.stdout.decode()

def dialog(title, body, initialvalue):
    from tkinter import Tk, simpledialog
    root = Tk()
    run("""/usr/bin/osascript -e 'tell app "Finder" to set frontmost of process "Python" to true'""")
    root.withdraw()
    response = simpledialog.askstring(title, body, parent=root, initialvalue=initialvalue)
    root.destroy()
    return response

def run_rename():
    desktops_string = [x.split(' ') for x in open("/Users/mikemintz/.config/whammy-desktops.txt").read().split("\n") if x]
    cur_desktops = [x[0] for x in desktops_string if x[1] == 'true']
    cur_desktop = cur_desktops[0] if cur_desktops else ''

    global name_map
    name_map = json.load(open(NAME_MAP_JSON_PATH))
    old_name = name_map.get(cur_desktop, '')
    new_name = dialog("Rename desktop", "New name for desktop {}".format(cur_desktop), old_name)
    if new_name == '':
        del name_map[cur_desktop]
    elif new_name:
        name_map[cur_desktop] = new_name
    json.dump(name_map, open(NAME_MAP_JSON_PATH, 'w'))

def ansi_wrap(codes, text):
    if not codes:
        return text
    ansi_prelude = ''.join(["\033[{}m".format(code) for code in codes])
    return "{}{}\033[0m".format(ansi_prelude, text)

def get_status_text_for_monitor(monitor):
    result = []

    desktops_string = [x.split(' ') for x in open("/Users/mikemintz/.config/whammy-desktops.txt").read().split("\n") if x]
    cur_desktops = [x[0] for x in desktops_string if x[1] == 'true']
    cur_desktop = cur_desktops[0] if cur_desktops else ''
    desktops = [x[0] for x in desktops_string]

    if not desktops_string:
        return ''
    for i, desktop in enumerate(desktops):
        if i > 0:
            result.append(ansi_wrap([37], u"\u2758"))
        suffix = ': ' + name_map[desktop] if desktop in name_map else ''
        pretty_name = ' {}{} '.format(desktop, suffix)
        ansi_codes = [37, 44] if desktop == cur_desktop else [37, 40]
        result.append(ansi_wrap(ansi_codes, pretty_name))
    return ''.join(result).strip()

def get_status_text():
    result = []
    num_monitors = 1
    for monitor in range(1, num_monitors + 1):
        result.append(get_status_text_for_monitor(monitor))
    return ''.join(result).strip()

def run_status_bar_update():
    status_text = get_status_text()
    print("{} | font=Monaco size=12 ansi=true".format(status_text))
    print("---")
    print("Rename this space | bash='{}' param1=rename refresh=true terminal=false".format(sys.argv[0].replace(' ', '\\\\ ')))

if __name__ == "__main__":
    if len(sys.argv) >= 2 and sys.argv[1] == 'rename':
        run_rename()
    run_status_bar_update()
