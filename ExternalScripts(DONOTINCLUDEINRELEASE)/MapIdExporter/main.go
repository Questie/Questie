package main

import (
	"fmt"
	"os"
	"sort"
)

// Define a struct to hold the data for sorting
type subZoneEntry struct {
	areaId         int
	parentAreaId   AreaId
	areaName       string
	parentAreaName string
}

// Used to export to questie
func dumpSubzoneToParentZone(AreaTable []*areaTable, outputfile string) {

	subZoneToParentZone := "--! Generated table, add something manually here and i'll kill you //Logon\n\n---@type table<AreaId, AreaId> table<SubAreaId, ParentAreaId>\nZoneDB.private.subZoneToParentZone = [[return {\n"

	// Create a slice to store the entries before formatting
	entries := []subZoneEntry{}

	for _, area := range AreaTable {

		//We want it to be -1 if it's 0
		setParentArea := area.ParentAreaID
		if setParentArea == 0 {
			setParentArea = -1
		}

		//? We don't want any subzones
		if area.Flags0&IsSubzone == IsSubzone || area.Flags0_new&IsSubzone == IsSubzone {
			// Used to export to questie
			parentAreaId := AreaId(setParentArea)

			// ? I have no idea what this tried to fix... but it did things wrong.
			// for _, area2 := range AreaTable {
			// 	if area2.ZoneName == area.ZoneName && area2.ParentAreaID == 0 {
			// 		parentAreaId = AreaId(area2.AreaId)
			// 		break
			// 	}
			// }
			parentAreaName := ""
			for _, area2 := range AreaTable {
				if area2.AreaId == int(parentAreaId) {
					parentAreaName = area2.AreaName_lang
					break
				}
			}
			// Add the entry to the slice instead of the string
			entries = append(entries, subZoneEntry{
				areaId:         area.AreaId,
				parentAreaId:   parentAreaId,
				areaName:       area.AreaName_lang,
				parentAreaName: parentAreaName,
			})
		}
	}

	// Sort the slice based on areaId
	sort.Slice(entries, func(i, j int) bool {
		return entries[i].areaId < entries[j].areaId
	})

	// Build the string from the sorted slice
	for _, entry := range entries {
		subZoneToParentZone += fmt.Sprintf("  [%d] = %d, -- %s -> %s\n", entry.areaId, entry.parentAreaId, entry.areaName, entry.parentAreaName)
	}

	// Used to export to questie
	subZoneToParentZone += "}]]"
	f, err := os.Create(outputfile)
	// Basic error handling for file creation
	if err != nil {
		fmt.Println("Error creating file:", err)
		return
	}
	defer f.Close()
	_, err = f.WriteString(subZoneToParentZone)
	// Basic error handling for file writing
	if err != nil {
		fmt.Println("Error writing to file:", err)
	}
}

func main() {
	// Download area tables from here e.g wotlk - https://wago.tools/db2/AreaTable?build=3.4.4.60430
	var expansionFileMap = map[string]map[string]string{
		"classic": {
			"AreaTable": "../DBC - WoW.tools/AreaTable.1.15.7.60277.csv",
		},
		"tbc": {
			"AreaTable": "../DBC - WoW.tools/AreaTable.2.5.4.44833.csv",
		},
		"wotlk": {
			"AreaTable": "../DBC - WoW.tools/AreaTable.3.4.4.60430.csv",
		},
		"cata": {
			"AreaTable": "../DBC - WoW.tools/AreaTable.4.4.2.60192.csv",
		},
		"mop": {
			"AreaTable": "../DBC - WoW.tools/AreaTable.5.5.0.60548.csv",
		},
	}
	for expansion, file := range expansionFileMap {
		fmt.Println("Loading", expansion, "area table")
		AreaTable := LoadAreaTable(file["AreaTable"])
		dumpSubzoneToParentZone(AreaTable, "zoneTable_"+expansion+".lua")
	}
}
