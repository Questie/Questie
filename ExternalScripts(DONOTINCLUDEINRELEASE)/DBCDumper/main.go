package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"sync"
)

var locale []string = []string{"enUS",
	"koKR",
	"frFR",
	"deDE",
	"zhCN",
	"esES",
	"zhTW",
	"enGB",
	"esMX",
	"ruRU",
	"ptBR",
	"itIT",
	"ptPT",
}

var versionsToDownload = map[string]string{
	"3.3.5.12340":  "WotlkVanilla",
	"3.4.0.45770":  "WotlkClassic",
	"2.4.3.8606":   "TbcVanilla",
	"2.5.4.44833":  "TbcClassic",
	"1.12.1.5875":  "Vanilla",
	"1.14.3.44834": "Classic",
}

func main() {
	databases := GetDatabases()
	var wg sync.WaitGroup
	for _, database := range databases {
		fmt.Println(database.DisplayName)
		versions := GetVersions(database.Name)
		for _, version := range versions {
			if folder, ok := versionsToDownload[version]; ok {
				fmt.Println(" " + version)
				newpath := filepath.Join(".", "out/"+folder+"/"+database.DisplayName)
				err := os.MkdirAll(newpath, os.ModePerm)
				if err != nil {
					log.Fatal(err)
				}
				for _, locale := range locale {
					fmt.Println("  " + locale)
					wg.Add(1)
					go func(databaseName string, databaseDisplayName string, version string, locale string) {
						defer wg.Done()
						DownloadCSV(database.Name, version, locale, newpath+"/"+database.DisplayName+"_"+locale+".csv")
					}(database.Name, database.DisplayName, version, locale)
				}
				wg.Wait()
				if IsEmpty(newpath) {
					os.Remove(newpath)
				}
			}
		}
	}
}
func IsEmpty(name string) bool {
	f, err := os.Open(name)
	if err != nil {
		return false
	}
	defer f.Close()

	_, err = f.Readdirnames(1) // Or f.Readdir(1)
	if err == io.EOF {
		return true
	}
	return false // Either not empty or error, suits both cases
}

func DownloadCSV(database string, version string, locale string, path string) {

	source := ""
	url := "https://wow.tools/dbc/api/export/?name=%s&build=%s&locale=%s"

	// fmt.Printf("Fetching Database %s\n", fmt.Sprintf(url, database, version, locale))
	resp, err := http.Get(fmt.Sprintf(url, database, version, locale))
	// handle the error if there is one
	if err != nil {
		panic(err)
	}
	// do this now so it won't be forgotten
	defer resp.Body.Close()
	// reads html as a slice of bytes
	html, err := io.ReadAll(resp.Body)
	if err != nil {
		panic(err)
	}

	source = string(html)
	if len(source) > 0 {
		file, err := os.Create(path)
		if err != nil {
			log.Fatal(err)
		}
		defer file.Close()
		file.WriteString(source)
	} else {
		fmt.Printf("    %s %s %s Empty", database, version, locale)
	}
}

type Databases []struct {
	Name        string `json:"name"`
	DisplayName string `json:"displayName"`
}

func GetDatabases() Databases {
	source := ""
	url := "https://api.wow.tools/databases/"

	fmt.Printf("Fetching Databases %s\n", url)
	resp, err := http.Get(url)
	// handle the error if there is one
	if err != nil {
		panic(err)
	}
	// do this now so it won't be forgotten
	defer resp.Body.Close()
	// reads html as a slice of bytes
	html, err := io.ReadAll(resp.Body)
	if err != nil {
		panic(err)
	}

	source = string(html)
	result := Databases{}
	json.Unmarshal([]byte(source), &result)

	return result
}

func GetVersions(database string) []string {

	source := ""
	url := "https://api.wow.tools/databases/%s/versions"

	fmt.Printf("Fetching Databases %s\n", fmt.Sprintf(url, database))
	resp, err := http.Get(fmt.Sprintf(url, database))
	// handle the error if there is one
	if err != nil {
		panic(err)
	}
	// do this now so it won't be forgotten
	defer resp.Body.Close()
	// reads html as a slice of bytes
	html, err := io.ReadAll(resp.Body)
	if err != nil {
		panic(err)
	}

	source = string(html)
	result := []string{}
	json.Unmarshal([]byte(source), &result)

	return result
}
