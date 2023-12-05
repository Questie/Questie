import re
import scrapy
from scrapy import signals

from npc.npc_ids import NPC_IDS
from npc_formatter import NPCFormatter


class NPCSpider(scrapy.Spider):
    name = "npc"
    base_url_classic = "https://www.wowhead.com/classic/npc={}"

    start_urls = []

    def __init__(self) -> None:
        super().__init__()
        self.start_urls = [self.base_url_classic.format(npc_id) for npc_id in NPC_IDS]
        # self.start_urls = [self.base_url_classic.format(npc_id) for npc_id in [203079, 202060]]

    def parse(self, response):
        result = {}
        for script in response.xpath('//script/text()').extract():
            if script.startswith('//<![CDATA[\nWH.Gatherer.addData'):
                result["npcId"] = response.url.split("/")[-2][4:]
                result["name"] = re.search(r'"name":"([^"]+)"', script).group(1)
                min_level_match = re.search(r'"minlevel":(\d+)', script)
                result["minLevel"] = min_level_match.group(1) if str(min_level_match) != "None" else "0"
                max_level_match = re.search(r'"maxlevel":(\d+)', script)
                result["maxLevel"] = max_level_match.group(1) if str(max_level_match) != "None" else "0"
                react_match = re.search(r'"react":\[(-?\d+),(-?\d+)]', script)
                result["reactAlliance"] = react_match.group(1) if str(react_match) != "None" else "0"
                result["reactHorde"] = react_match.group(2) if str(react_match) != "None" else "0"
            if script.lstrip().startswith('var g_mapperData'):
                zone_id_pattern = re.compile(r'"(\d+)":\[{')
                zone_id_matches = zone_id_pattern.findall(script)
                coords_pattern = re.compile(r'"coords":\[(\[.*?])],')
                coords_matches = coords_pattern.findall(script)
                spawns = []
                for zone_id, coords in zip(zone_id_matches, coords_matches):
                    spawns.append([int(zone_id), coords])
                    if "zoneId" not in result.keys():
                        result["zoneId"] = zone_id
                result["spawns"] = spawns

        if result:
            yield result

    @classmethod
    def from_crawler(cls, crawler, *args, **kwargs):
        spider = super(NPCSpider, cls).from_crawler(crawler, *args, **kwargs)
        crawler.signals.connect(spider.spider_closed, signal=signals.spider_closed)
        return spider

    def spider_closed(self, spider):
        self.logger.info("Spider closed.")

        # f = NPCFormatter()
        # f()

