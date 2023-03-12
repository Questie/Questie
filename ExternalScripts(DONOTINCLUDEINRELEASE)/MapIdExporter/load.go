package main

import (
	"fmt"
	"os"

	"github.com/gocarina/gocsv"
)

//Map Id types
type MapId int   //Big map id such as 0, 1 and 530 for Kalimdor etc.
type UiMapId int // Modern Map Id
type ZoneId int  //e.g Dun Morogh
type AreaId int  //Stuff like subzones in a zone or dungeons etc

type worldMapArea struct {
	ID                  int     `csv:"ID"`
	MapID               int     `csv:"MapID"`
	AreaID              int     `csv:"AreaID"`
	AreaName            string  `csv:"AreaName"`
	LocLeft             float64 `csv:"LocLeft"`
	LocRight            float64 `csv:"LocRight"`
	LocTop              float64 `csv:"LocTop"`
	LocBottom           float64 `csv:"LocBottom"`
	DisplayMapID        int     `csv:"DisplayMapID"`
	DefaultDungeonFloor int     `csv:"DefaultDungeonFloor"`
	ParentWorldMapID    int     `csv:"ParentWorldMapID"`
}

func LoadWorldMapArea() map[AreaId]*worldMapArea {
	in, err := os.Open("csv/worldmaparea.csv")
	if err != nil {
		panic(err)
	}
	defer in.Close()

	worldmaparea := []*worldMapArea{}

	if err := gocsv.UnmarshalFile(in, &worldmaparea); err != nil {
		panic(err)
	}
	areaList := map[AreaId]*worldMapArea{}
	for _, maparea := range worldmaparea {
		idToUse := AreaId(maparea.AreaID)
		//? We want some maps that are "overworld" to be added
		if idToUse == 0 {
			if maparea.MapID != 0 && maparea.MapID != 1 {
				idToUse = AreaId(maparea.MapID)
			} else {
				//? Azeroth (Eastern Kingdom) and Kalimdor should not be added
				fmt.Println("", maparea)
				continue
			}
		}

		areaList[idToUse] = maparea
		fmt.Println("Adding", idToUse, ":", maparea.AreaName)
	}
	return areaList
}

type MapType int

const (
	Cosmic       MapType = 0
	World        MapType = 1
	Continent    MapType = 2
	Zone         MapType = 3
	Dungeon      MapType = 4
	Micro        MapType = 5
	Orphan       MapType = 6
	Raid         MapType = 7  //* Made this up myself
	Battleground MapType = 8  //* Made this up myself
	Arena        MapType = 9  //* Made this up myself
	Unknown      MapType = 10 //* Made this up myself
)

type uiMap struct {
	Name_lang     string  `csv:"Name_lang"`
	UiMapId       int     `csv:"ID"`
	ParentUiMapID int     `csv:"ParentUiMapID"`
	Flags         int     `csv:"Flags"`
	System        int     `csv:"System"`
	Type          MapType `csv:"Type"`
}

func LoadUiMap() map[string]*uiMap {
	in, err := os.Open("csv/uimap.csv")
	if err != nil {
		panic(err)
	}
	defer in.Close()

	uimaps := []*uiMap{}

	if err := gocsv.UnmarshalFile(in, &uimaps); err != nil {
		panic(err)
	}
	returnUiMap := map[string]*uiMap{}
	for _, uiMap := range uimaps {
		if _, ok := returnUiMap[uiMap.Name_lang]; !ok {
			returnUiMap[uiMap.Name_lang] = uiMap
			fmt.Println("Adding", uiMap.UiMapId, ":", uiMap.Name_lang)
		}
	}
	return returnUiMap
}

const (
	AllowDueling = 64
	IsSubzone    = 1073741824
)

type areaTable struct {
	AreaId        int    `csv:"ID"`
	ZoneName      string `csv:"ZoneName"`
	AreaName_lang string `csv:"AreaName_lang"`
	ContinentID   int    `csv:"ContinentID"`
	ParentAreaID  int    `csv:"ParentAreaID"`
	AreaBit       int    `csv:"AreaBit"`
	Flags0        int    `csv:"Flags[0]"`
	Flags1        int    `csv:"Flags[1]"`
}

func LoadAreaTable() []*areaTable {
	in, err := os.Open("csv/areatable.csv")
	if err != nil {
		panic(err)
	}
	defer in.Close()

	areaTables := []*areaTable{}

	if err := gocsv.UnmarshalFile(in, &areaTables); err != nil {
		panic(err)
	}
	return areaTables
}

type InstanceType int

const (
	IsDungeon      InstanceType = 1
	IsRaid         InstanceType = 2
	IsBattleground InstanceType = 3
	IsArena        InstanceType = 4
)

type mapData struct {
	MapId               MapId        `csv:"ID"`
	Directory           string       `csv:"Directory"`
	MapName_lang        string       `csv:"MapName_lang"`
	MapType             int          `csv:"MapType"`
	InstanceType        InstanceType `csv:"InstanceType"`
	ExpansionID         int          `csv:"ExpansionID"`
	AreaTableID         int          `csv:"AreaTableID"`
	ParentMapID         MapId        `csv:"ParentMapID"`
	CosmeticParentMapID MapId        `csv:"CosmeticParentMapID"`
	MinimapIconScale    float64      `csv:"MinimapIconScale"`
	CorpseMapID         MapId        `csv:"CorpseMapID"`
	MaxPlayers          int          `csv:"MaxPlayers"`
	Flags0              int          `csv:"Flags[0]"`
	Flags1              int          `csv:"Flags[1]"`
	Flags2              int          `csv:"Flags[2]"`
}

func LoadMap() map[MapId]*mapData {
	in, err := os.Open("csv/map.csv")
	if err != nil {
		panic(err)
	}
	defer in.Close()

	mapDatas := []*mapData{}

	if err := gocsv.UnmarshalFile(in, &mapDatas); err != nil {
		panic(err)
	}
	returnMapData := map[MapId]*mapData{}
	for _, mapData := range mapDatas {
		returnMapData[mapData.MapId] = mapData
		fmt.Println("Adding", mapData.MapName_lang)
	}
	return returnMapData
}
