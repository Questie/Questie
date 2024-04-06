import re
import scrapy
from scrapy import signals

from item.item_formatter import ItemFormatter
from item.item_ids import ITEM_IDS


class ItemSpider(scrapy.Spider):
    name = "item"
    base_url_classic = "https://www.wowhead.com/classic/item={}"

    start_urls = []

    def __init__(self) -> None:
        super().__init__()
        self.start_urls = [self.base_url_classic.format(item_id) for item_id in ITEM_IDS]

    def parse(self, response):
        result = {}
        for script in response.xpath('//script/text()').extract():
            result["itemId"] = response.url.split("/")[-2][5:]
            if script.startswith('\nWH.Gatherer.addData'):
                result["name"] = re.search(r'"name":"([^"]+)"', script).group(1)

            if script.startswith('\n    var tabsRelated ='):
                list_views_pattern = re.compile(r'new Listview\((.*?)}\)', re.DOTALL)

                for match in list_views_pattern.findall(script):
                    list_view_name = re.search(r'id: \'(.*?)\',', match).group(1)
                    if list_view_name == "dropped-by" or list_view_name == "pick-pocketed-from" or list_view_name == "skinned-from":
                        dropped_by_pattern = re.compile(r'"id":(\d+)')
                        for dropped_by in dropped_by_pattern.findall(match):
                            if "npcDrops" not in result.keys():
                                result["npcDrops"] = []
                            result["npcDrops"].append(int(dropped_by))
                    if list_view_name == "sold-by":
                        sold_by_pattern = re.compile(r'"id":(\d+)')
                        for sold_by in sold_by_pattern.findall(match):
                            if "vendors" not in result.keys():
                                result["vendors"] = []
                            result["vendors"].append(int(sold_by))
                    if list_view_name == "contained-in-object" or list_view_name == "mined-from-object" or list_view_name == "gathered-from-object":
                        contained_in_object_pattern = re.compile(r'"id":(\d+)')
                        for contained_in_object in contained_in_object_pattern.findall(match):
                            if "objectDrops" not in result.keys():
                                result["objectDrops"] = []
                            result["objectDrops"].append(int(contained_in_object))
                    if list_view_name == "contained-in-item":
                        contained_in_item_pattern = re.compile(r'"id":(\d+)')
                        for contained_in_item in contained_in_item_pattern.findall(match):
                            if "itemDrops" not in result.keys():
                                result["itemDrops"] = []
                            result["itemDrops"].append(int(contained_in_item))
                    if list_view_name == "starts":
                        starts_match = re.search(r'"id":(\d+)', match)
                        if starts_match:
                            starts = starts_match.group(1)  # an item can always only start one quest
                            result["questStarts"] = int(starts)

        if result:
            yield result

    @classmethod
    def from_crawler(cls, crawler, *args, **kwargs):
        spider = super(ItemSpider, cls).from_crawler(crawler, *args, **kwargs)
        crawler.signals.connect(spider.spider_feed_closed, signal=signals.feed_exporter_closed)
        return spider

    def spider_feed_closed(self):
        f = ItemFormatter()
        f()

