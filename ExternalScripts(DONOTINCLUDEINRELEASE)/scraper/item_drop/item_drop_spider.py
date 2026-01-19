import re
import scrapy
from scrapy import signals

from item_drop.item_drop_formatter import ItemDropFormatter
from item_drop.item_ids import ITEM_IDS


class ItemDropSpider(scrapy.Spider):
    name = "item"
    base_url_classic = "https://www.wowhead.com/tbc/item={}"

    start_urls = []

    def __init__(self) -> None:
        super().__init__()
        self.start_urls = [self.base_url_classic.format(item_id) for item_id in ITEM_IDS]

    def parse(self, response):
        result = {}
        for script in response.xpath('//script/text()').extract():
            result["itemId"] = response.url.split("/")[-2][5:]
            if script.startswith('\nWH.Gatherer.addData'):
                result["name"] = re.search(r'"name":"((?:[^"\\]|\\.)*)"', script).group(1)

            if script.startswith('\n    var tabsRelated ='):
                list_views_pattern = re.compile(r'new Listview\((.*?)}\)', re.DOTALL)

                for match in list_views_pattern.findall(script):
                    list_view_name = re.search(r'id: \'(.*?)\',', match).group(1)
                    if list_view_name == "dropped-by":
                        #print(match)
                        complex_pattern = re.compile(r'"id":(\d+).*?"modes":{.*?"0":{.*?"count":(\d+).*?"outof":(\d+)}}')
                        for item in complex_pattern.findall(match):
                            result[str(item[0])] = [int(item[1]),int(item[2])]

        if result:
            yield result

    @classmethod
    def from_crawler(cls, crawler, *args, **kwargs):
        spider = super(ItemDropSpider, cls).from_crawler(crawler, *args, **kwargs)
        crawler.signals.connect(spider.spider_feed_closed, signal=signals.feed_exporter_closed)
        return spider

    def spider_feed_closed(self):
        f = ItemDropFormatter()
        f()

