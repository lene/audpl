__author__ = 'Lene Preuss <lene.preuss@gmail.com>'

import os


def find_files(base_path, condition):
    return [
        os.path.join(root, file)
        for root, _, files in os.walk(base_path)
        for file in files
        if os.path.exists(os.path.join(root, file))
        if condition(os.path.join(root, file))
    ]

