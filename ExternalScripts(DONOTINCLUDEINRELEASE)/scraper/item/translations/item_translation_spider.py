import logging
import re

from scrapy import signals, Spider

from item.translations.item_translation_formatter import ItemTranslationFormatter
from item.translations.item_translation_move_to_lookups import main as move_to_lookups
from item.item_ids import ITEM_IDS


class ItemTranslationSpider(Spider):
    name = "item-translations"
    base_url = "https://www.wowhead.com"
    base_urls = [
        base_url + "/de/item={}",
        base_url + "/es/item={}",
        base_url + "/fr/item={}",
        base_url + "/pt/item={}",
        base_url + "/ru/item={}",
        base_url + "/ko/item={}",
        base_url + "/cn/item={}",
    ]

    start_urls = []

    def __init__(self) -> None:
        super().__init__()
        self.start_urls = [url.format(item_id) for item_id in ITEM_IDS for url in self.base_urls]

    def parse(self, response):
        locale = re.search(r'/([a-z]{2})/item', response.url).group(1)

        if response.url.find('/items?notFound=') != -1:
            item_id = re.search(r'/items\?notFound=(\d+)', response.url).group(1)
            logging.warning(f'\x1b[31;20mItem with ID {item_id} not found for {locale}\x1b[0m')
            return None

        item_id = re.search(r'/item=(\d+)', response.url).group(1)
        result = {"itemId": item_id, "locale": locale}

        item_name = response.xpath('//div[@class="text"]/h1/text()').get()
        if item_name and not item_name.startswith("["):
            result["name"] = item_name

        yield result

    @classmethod
    def from_crawler(cls, crawler, *args, **kwargs):
        spider = super(ItemTranslationSpider, cls).from_crawler(crawler, *args, **kwargs)
        crawler.signals.connect(spider.spider_feed_closed, signal=signals.feed_exporter_closed)
        return spider

    def spider_feed_closed(self):
        print("Finished scraping item translations, now formatting the data...")
        formatter = ItemTranslationFormatter()
        formatter()
        print("Formatting done, now moving to lookups...")
        move_to_lookups()
        print("DONE")

