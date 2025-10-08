#!/usr/bin/env python3

# This file takes a manually filled translation file that was created with untranslated.py and applies the missing translations to the code
#
# Usage: python -m translated moduleName language
#
# moduleName: The file name without the ending, e.g. when the input file is called missing_koKR.py then pass missing_koKR as argument
# language: The abbreviation for the used language, e.g. koKR. Must be one of deDE, esES, esMX, frFR, koKR, ptBR, ruRU, zhCN, or zhTW.

import sys
import re
import runpy

basePath = '../Localization/Translations/'

files = {}

for filePath in re.findall('file="([\\a-zA-Z]*?.lua)"', open('%sTranslations.xml' % basePath).read()):
    with open('%s%s' % (basePath, filePath.replace('\\', '/')), 'r', encoding='utf-8') as translationFile:
        if translationFile.name.endswith('Objectives.lua'):
            continue
        for variableName, tableContent in re.findall(r'\n\nlocal (.*?) = {\n(.*?\n)\}\n\n', translationFile.read(), re.DOTALL):
            files[variableName] = '%s%s' % (basePath, filePath.replace('\\', '/'))

if __name__ == "__main__":
    moduleName = sys.argv[1]
    language = sys.argv[2]
    m = runpy.run_module(moduleName)
    missing = m["missing"]
    for variableName in missing:
        content = ""
        changed = False
        with open(files[variableName], 'r', encoding='utf-8') as file:
            content = file.read()
        for sourceString in missing[variableName]:
            translation = missing[variableName][sourceString]
            if translation == "?":
                print("[WARNING] skipped missing translation for %s" % sourceString)
                continue
            s = re.search(r'(\["%s"] = \{.*?\["%s"] = )(.*?)(,.*?\n    },\n)' % (re.escape(sourceString).replace('\n', '\\n').replace('"', '\\\\"'), language), content, re.DOTALL)
            if s == None:
                print("[ERROR] Failed to find source for: %s" % sourceString)
                continue
            if s.group(2) != "false":
                print("[WARNING] Skipping because value not false for: %s" % sourceString)
                print("In Questie:", s.group(2))
                print("In file   :", translation)
                continue
            temp = re.sub(r'(\["%s"] = \{.*?\["%s"] = )(false)(,.*?\n    },\n)' % (re.escape(sourceString).replace('\n', '\\n').replace('"', '\\\\"'), language), r'\1"%s"\3' % translation.replace('\n', '\\\\n').replace('"', '\\\\"'), content, flags=re.DOTALL)
            if content != temp:
                content = temp
                changed = True
            else:
                print("[ERROR] Failed to apply translation for: %s" % sourceString)
        if changed:
            with open(files[variableName], 'w', encoding='utf-8') as file:
                file.write(content)
            print('Updated file', files[variableName])
        else:
            print('[WARNING] File unchanged', files[variableName])
