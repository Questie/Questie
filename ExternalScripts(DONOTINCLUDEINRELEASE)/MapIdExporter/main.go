package main

import (
	"fmt"
	"os"
)

// Used to export to questie
func dumpSubzoneToParentZone(AreaTable []*areaTable) {

	subZoneToParentZone := "--! Generated table, add something manually here and i'll kill you //Logon\n\n---@type table<AreaId, AreaId> table<SubAreaId, ParentAreaId>\nlocal subZoneToParentZone = {\n"

	for _, area := range AreaTable {

		//We want it to be -1 if it's 0
		setParentArea := area.ParentAreaID
		if setParentArea == 0 {
			setParentArea = -1
		}

		//? We don't want any subzones
		if area.Flags0&IsSubzone == IsSubzone {
			// Used to export to questie
			parentAreaId := AreaId(setParentArea)

			for _, area2 := range AreaTable {
				if area2.ZoneName == area.ZoneName && area2.ParentAreaID == 0 {
					parentAreaId = AreaId(area2.AreaId)
					break
				}
			}
			parentAreaName := ""
			for _, area2 := range AreaTable {
				if area2.AreaId == int(parentAreaId) {
					parentAreaName = area2.AreaName_lang
					break
				}
			}
			subZoneToParentZone += fmt.Sprintf("  [%d] = %d, -- %s -> %s\n", area.AreaId, parentAreaId, area.AreaName_lang, parentAreaName)
		}
	}

	// Used to export to questie
	subZoneToParentZone += "}"
	f, _ := os.Create("zoneTable.lua")
	defer f.Close()
	f.WriteString(subZoneToParentZone)
}

func main() {
	fmt.Println("Hello World")
	AreaTable := LoadAreaTable()
	dumpSubzoneToParentZone(AreaTable)
}
