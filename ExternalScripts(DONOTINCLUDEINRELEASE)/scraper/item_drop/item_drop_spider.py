import re
import scrapy
from scrapy import signals

from item_drop.item_drop_formatter import ItemDropFormatter
from item_drop.item_ids import ITEM_IDS


class ItemDropSpider(scrapy.Spider):
    name = "item"
    start_urls = []

    def __init__(self, expansion: int) -> None:
        super().__init__()

        match expansion:
            case 0:
                base_url = "https://www.wowhead.com/item={}"
            case 1:
                base_url = "https://www.wowhead.com/classic/item={}"
            case 2:
                base_url = "https://www.wowhead.com/tbc/item={}"
            case 3:
                base_url = "https://www.wowhead.com/wotlk/item={}"
            case 4:
                base_url = "https://www.wowhead.com/cata/item={}"
            case 5:
                base_url = "https://www.wowhead.com/mop-classic/item={}"
            case _: # If number is unknown, treat it as classic
                base_url = "https://www.wowhead.com/classic/item={}"

        self.start_urls = [base_url.format(item_id) for item_id in ITEM_IDS]

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

