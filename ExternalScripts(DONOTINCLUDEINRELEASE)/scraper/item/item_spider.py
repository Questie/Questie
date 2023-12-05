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
                    list_view_name = re.search(r'name: WH\.TERMS\.(.*?),', match).group(1)
                    if list_view_name == "droppedby" or list_view_name == "pickpocketedfrom":
                        dropped_by_pattern = re.compile(r'"id":(\d+)')
                        for dropped_by in dropped_by_pattern.findall(match):
                            if "npcDrops" not in result.keys():
                                result["npcDrops"] = []
                            result["npcDrops"].append(int(dropped_by))
                    if list_view_name == "soldby":
                        sold_by_pattern = re.compile(r'"id":(\d+)')
                        for sold_by in sold_by_pattern.findall(match):
                            if "vendors" not in result.keys():
                                result["vendors"] = []
                            result["vendors"].append(int(sold_by))
                    if list_view_name == "containedin":
                        contained_in_pattern = re.compile(r'"id":(\d+)')
                        for contained_in_object in contained_in_pattern.findall(match):
                            if "objectDrops" not in result.keys():
                                result["objectDrops"] = []
                            result["objectDrops"].append(int(contained_in_object))

        if result:
            yield result

    @classmethod
    def from_crawler(cls, crawler, *args, **kwargs):
        spider = super(ItemSpider, cls).from_crawler(crawler, *args, **kwargs)
        crawler.signals.connect(spider.spider_closed, signal=signals.spider_closed)
        return spider

    def spider_closed(self, spider):
        self.logger.info("Spider closed.")

        # f = ItemFormatter()
        # f()

