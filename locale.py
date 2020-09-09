#!/usr/bin/env python3
if __name__ == "__main__":
    
    import os
    
    langs = {}
    missingCount = {}
    
    def parse(lang):
        ret = {}
        with open ("./Locale/" + lang + "/config.lua", "r") as f:
            for line in f.readlines():
                line = line.strip()
                key = None
                val = None
                if line.startswith("['"):
                    key = line.split("['")[1].split("']")[0]
                if line.startswith("[\""):
                    key = line.split("[\"")[1].split("\"]")[0]
                
                if key is not None:
                    line = line[len(key)+4:]
                    if line.endswith("',"):
                        val = line[line.index("'")+1:-2]
                    if line.endswith("\","):
                        val = line[line.index("\"")+1:-2]
                    if val is not None:
                        ret[key] = val
        return ret
            
    print("Loading locale files...")
    for lang in os.listdir("./Locale/"):
        if os.path.isdir("./Locale/"+lang):
            print(lang + "...")
            langs[lang] = parse(lang)
            missingCount[lang] = 0

    print("Writing missing entries...")
    
    for key in langs["enUS"].keys():
        for lang in langs.keys():
            if lang != "enUS":
                if key not in langs[lang] or langs[lang][key] == langs["enUS"][key]:
                    print(lang + " is missing " + key)
                    missingCount[lang] = missingCount[lang] + 1
                    
    for lang in missingCount.keys():
        print(lang + " is missing " + str(missingCount[lang]) + " translations")
    
