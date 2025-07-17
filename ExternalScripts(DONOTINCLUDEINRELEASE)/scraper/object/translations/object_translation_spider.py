import logging
import re

from scrapy import signals, Spider

from object.translations.object_translation_formatter import ObjectTranslationFormatter
from object.translations.object_translation_move_to_lookups import main as move_to_lookups
from object.translations.mop_object_ids import MOP_OBJECT_IDS
from supported_locales import LOCALES


class ObjectTranslationSpider(Spider):
    name = "object-translations"
    base_urls = [
        f"https://www.wowhead.com/{locale['input']}/object={{}}" for locale in LOCALES
    ]

    start_urls = []

    def __init__(self) -> None:
        super().__init__()
        self.start_urls = [url.format(object_id) for object_id in MOP_OBJECT_IDS for url in self.base_urls]

    def parse(self, response):
        locale = re.search(r'/([a-z]{2})/object', response.url).group(1)

        if response.url.find('/objects?notFound=') != -1:
            object_id = re.search(r'/objects\?notFound=(\d+)', response.url).group(1)
            logging.warning('\x1b[31;20mObject with ID {object_id} not found for {locale}\x1b[0m'.format(object_id=object_id, locale=locale))
            return None

        object_id = re.search(r'/object=(\d+)', response.url).group(1)
        result = {"objectId": object_id, "locale": locale}

        object_name = response.xpath('//div[@class="text"]/h1/text()').get()
        if not object_name.startswith("["):
            result["name"] = object_name

        yield result

    @classmethod
    def from_crawler(cls, crawler, *args, **kwargs):
        spider = super(ObjectTranslationSpider, cls).from_crawler(crawler, *args, **kwargs)
        crawler.signals.connect(spider.spider_feed_closed, signal=signals.feed_exporter_closed)
        return spider

    def spider_feed_closed(self):
        print("Finished scraping object translations, now formatting the data...")
        formatter = ObjectTranslationFormatter()
        formatter()
        print("Formatting done, now moving to lookups...")
        move_to_lookups()
        print("DONE")