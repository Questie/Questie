import re
import scrapy
from scrapy import signals

from ids.npc_ids import NPC_IDS
from npc_formatter import NPCFormatter


class NPCSpider(scrapy.Spider):
    name = "npc"
    base_url_classic = "https://www.wowhead.com/classic/npc={}"

    start_urls = []

    def __init__(self) -> None:
        super().__init__()
        self.start_urls = [self.base_url_classic.format(npc_id) for npc_id in NPC_IDS]

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
                zone_id_match = re.search(r'"location":\[(\d+),', script)
                result["zoneId"] = zone_id_match.group(1) if str(zone_id_match) != "None" else "0"
                react_match = re.search(r'"react":\[(-?\d+),(-?\d+)]', script)
                result["reactAlliance"] = react_match.group(1) if str(react_match) != "None" else "0"
                result["reactHorde"] = react_match.group(2) if str(react_match) != "None" else "0"
            if script.lstrip().startswith('var g_mapperData'):
                pattern = re.compile(r'"coords":\[(\[.*?])],"uiMapId":(\d+)')
                matches = pattern.findall(script)
                spawns = []
                for coords, ui_map_id in matches:
                    spawns.append([int(ui_map_id), eval(coords)])
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

        f = NPCFormatter()
        f()

