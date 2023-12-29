import re
import scrapy
from scrapy import signals

from object.object_formatter import ObjectFormatter
from object.object_ids import OBJECT_IDS


class ObjectSpider(scrapy.Spider):
    name = "object"
    base_url_classic = "https://www.wowhead.com/classic/object={}"

    start_urls = []

    def __init__(self) -> None:
        super().__init__()
        self.start_urls = [self.base_url_classic.format(item_id) for item_id in OBJECT_IDS]

    def parse(self, response):
        result = {}
        for script in response.xpath('//script/text()').extract():
            result["objectId"] = response.url.split("/")[-2][7:]
            if script.startswith('//<![CDATA[\nWH.Gatherer.addData'):
                result["name"] = re.search(r'"name":"([^"]+)"', script).group(1)
            if script.lstrip().startswith('var g_mapperData'):
                result["spawns"] = self.__match_spawns(result, script)

        if "spawns" in result and (not result["spawns"]):
            text = response.xpath("//div[contains(text(), 'This object can be found in')]").get()
            zone_id_match = re.search(r"zone=(\d+)", text)
            if zone_id_match:
                zone_id = zone_id_match.group(1)
                result["zoneId"] = zone_id
                if (zone_id == "719" or  # Blackfathom Deeps
                        zone_id == "209"):  # Shadowfang Keep
                    result["spawns"] = [[zone_id, "[-1,-1]"]]

        if result:
            yield result

    def __match_spawns(self, result, script):
        zone_id_pattern = re.compile(r'"(\d+)":\[{')
        zone_id_matches = zone_id_pattern.findall(script)
        coords_pattern = re.compile(r'"coords":\[(\[.*?])],')
        coords_matches = coords_pattern.findall(script)
        spawns = []
        for zone_id, coords in zip(zone_id_matches, coords_matches):
            spawns.append([int(zone_id), coords])
            if "zoneId" not in result.keys():
                result["zoneId"] = zone_id
        return spawns

    @classmethod
    def from_crawler(cls, crawler, *args, **kwargs):
        spider = super(ObjectSpider, cls).from_crawler(crawler, *args, **kwargs)
        crawler.signals.connect(spider.spider_feed_closed, signal=signals.feed_exporter_closed)
        return spider

    def spider_feed_closed(self):
        f = ObjectFormatter()
        f()

