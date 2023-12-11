#!/usr/bin/env python3

import re

basePath = '../Localization/Translations/'

translations =  {}
duplicates = {}

for filePath in re.findall('file="([\\a-zA-Z]*?.lua)"', open('%sTranslations.xml' % basePath).read()):
    with open('%s%s' % (basePath, filePath.replace('\\', '/')), 'r', encoding='utf-8') as translationFile:
        if translationFile.name.endswith('Objectives.lua'):
            continue
        for filePath, tableContent in re.findall('\n\nlocal (.*?) = {\n(.*?\n)\}\n\n', translationFile.read(), re.DOTALL):
            if filePath not in translations:
                translations[filePath] = {}
            for option, translationContent in re.findall('\["(.*?)"] = {\n(.*?)}', tableContent, re.DOTALL):
                translations[filePath][option] = {}
                if option in duplicates:
                    duplicates[option] += 1
                else:
                    duplicates[option] = 0
                for lang, translation in re.findall('\["(.*?)"] = (.*?),\n', translationContent, re.DOTALL):
                    if translation in ('nil', 'false'):
                        translations[filePath][option][lang] = False
                    else:
                        translations[filePath][option][lang] = translation


numOptions = 0
numMissing = 0
numLangMissing = {}
missingTranslations = {}
langMissingTranslations = {}

for filePath in translations:
    if 'ObjectiveLocales' in filePath:
        continue
    for option in translations[filePath]:
        numOptions += 1
        for lang in translations[filePath][option]:
            if translations[filePath][option][lang] == False:
                #print('%s - %s - %s' % (filePath, lang, option))
                numMissing += 1
                if lang in numLangMissing:
                    numLangMissing[lang] += 1
                else:
                    numLangMissing[lang] = 1
                if not filePath in missingTranslations:
                    missingTranslations[filePath] = {}
                if not option in missingTranslations[filePath]:
                    missingTranslations[filePath][option] = [lang]
                else:
                    missingTranslations[filePath][option].append(lang)
                if not lang in langMissingTranslations:
                    langMissingTranslations[lang] = {}
                if not filePath in langMissingTranslations[lang]:
                    langMissingTranslations[lang][filePath] = [option]
                else:
                    langMissingTranslations[lang][filePath].append(option)

def printStats():
    print("Number of strings:", numOptions)
    print("Missing overall:", numMissing)
    for lang in numLangMissing:
        complete = (numOptions - numLangMissing[lang]) / numOptions * 100
        print(f'Missing for language "{lang}": {numLangMissing[lang]} ({complete}% complete)')

def printMissing():
    for filePath in missingTranslations:
        print(filePath)
        for option in missingTranslations[filePath]:
            print(f'"{option}" is missing for:')
            for lang in missingTranslations[filePath][option]:
                print(lang)

def printMissingByLang():
    print("missing = {")
    for lang in langMissingTranslations:
        print('    "%s":{' % lang)
        for filePath in langMissingTranslations[lang]:
            print('        "%s":{' % filePath)
            for option in langMissingTranslations[lang][filePath]:
                print(f'            "{option}":"?",')
            print('        },')
        print('    },')
    print('}')

def saveMissingByLang():
    for lang in langMissingTranslations:
        with open('missing_'+lang+'.py', 'w') as langFile:
            langFile.write('missing = {\n')
            for filePath in langMissingTranslations[lang]:
                if 'ObjectiveLocales' in filePath:
                    continue
                langFile.write('    "%s":{\n' % filePath)
                for option in langMissingTranslations[lang][filePath]:
                    langFile.write(f'        "{option}":"?",\n')
                langFile.write('    },\n')
            langFile.write('}\n')

if __name__ == "__main__":
    saveMissingByLang()
    printStats()
