import re
import scrapy
from scrapy import signals

from match_dungeon_spawns import match_dungeon_spawns
from npc.retail_npc_ids import RETAIL_NPC_IDS
from npc.npc_formatter import NPCFormatter
from npc.npc_ids import NPC_IDS


class NPCSpider(scrapy.Spider):
    name = "npc"
    base_url_classic = "https://www.wowhead.com/classic/npc={}"
    base_url_retail = "https://www.wowhead.com/npc={}"

    start_urls = []

    def __init__(self, run_for_retail: bool) -> None:
        super().__init__()
        if run_for_retail:
            self.start_urls = [self.base_url_retail.format(npc_id) for npc_id in RETAIL_NPC_IDS]
        else:
            self.start_urls = [self.base_url_classic.format(npc_id) for npc_id in NPC_IDS]

    def parse(self, response):
        result = {}
        for script in response.xpath('//script/text()').extract():
            if script.startswith('//<![CDATA[\nWH.Gatherer.addData'):
                npc_id = response.url.split("/")[-2][4:]
                if npc_id == "sic":
                    # Handle an invalid case
                    return
                result["npcId"] = npc_id
                name_match = re.search(r'"name":"((?:[^"\\]|\\.)*)"', script)
                if not name_match:
                    # Raid/Dungeon Boss sites use a different format
                    name_match = re.search(r'"name_enus":"((?:[^"\\]|\\.)*)"', script)
                result["name"] = name_match.group(1)
                min_level_match = re.search(r'"minlevel":(\d+)', script)
                result["minLevel"] = min_level_match.group(1) if str(min_level_match) != "None" else "0"
                max_level_match = re.search(r'"maxlevel":(\d+)', script)
                result["maxLevel"] = max_level_match.group(1) if str(max_level_match) != "None" else "0"
                react_match = re.search(r'"react":\[(?:(-?\d+)|null),(?:(-?\d+)|null)]', script)
                if react_match is not None:
                    result["reactAlliance"] = react_match.group(1) if react_match.group(1) is not None else "0"
                    result["reactHorde"] = react_match.group(2) if react_match.group(2) is not None else "0"
                else:
                    result["reactAlliance"] = "0"
                    result["reactHorde"] = "0"

                list_views_pattern = re.compile(r'new Listview\((.*?)}\)', re.DOTALL)
                for match in list_views_pattern.findall(script):
                    list_view_id_match = re.search(r'id: \'(.*?)\',', match)
                    if list_view_id_match:  # some seem to have a Listview but without IDs, so we need to test for None here
                        list_view_name = list_view_id_match.group(1)
                        if list_view_name == "starts":
                            result["questStarts"] = self.__get_ids_from_listview(match)
                        if list_view_name == "ends":
                            result["questEnds"] = self.__get_ids_from_listview(match)

            if script.lstrip().startswith('var g_mapperData'):
                result["spawns"] = self.__match_spawns(result, script)

        if ("spawns" in result and (not result["spawns"])) or (not "spawns" in result):
            text = response.xpath("//div[contains(text(), 'This NPC can be found in')]").get()
            if text:
                spawns, zone_id = match_dungeon_spawns(text)
                if spawns:
                    result["spawns"] = spawns
                if zone_id:
                    result["zoneId"] = zone_id

        if result:
            yield result

    def __match_spawns(self, result, script):
        zone_id_pattern = re.compile(r'"(\d+)":(?:\[{|{"\d+")')
        zone_id_matches = zone_id_pattern.findall(script)
        coords_pattern = re.compile(r'"coords":\[(\[.*?])][,}]')
        coords_matches = coords_pattern.findall(script)
        spawns = []
        for zone_id, coords in zip(zone_id_matches, coords_matches):
            spawns.append([int(zone_id), coords])
            if "zoneId" not in result.keys():
                result["zoneId"] = zone_id
        return spawns

    def __get_ids_from_listview(self, text):
        pattern = re.compile(r'"id":(\d+)')
        ids = []
        for match in pattern.findall(text):
            ids.append(match)
        return ids

    @classmethod
    def from_crawler(cls, crawler, *args, **kwargs):
        spider = super(NPCSpider, cls).from_crawler(crawler, *args, **kwargs)
        crawler.signals.connect(spider.spider_feed_closed, signal=signals.feed_exporter_closed)
        return spider

    def spider_feed_closed(self):
        f = NPCFormatter()
        f()

