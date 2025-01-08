import logging
import re

from scrapy import signals, Spider

from object.translations.cata_object_ids import CATA_OBJECT_IDS


class ObjectTranslationSpider(Spider):
    name = "object-translations"
    cata_url = "https://www.wowhead.com/cata"
    base_urls = [
        cata_url + "/de/object={}",
        cata_url + "/es/object={}",
        cata_url + "/fr/object={}",
        cata_url + "/pt/object={}",
        cata_url + "/ru/object={}",
        cata_url + "/ko/object={}",
        cata_url + "/cn/object={}",
    ]

    start_urls = []

    def __init__(self) -> None:
        super().__init__()
        # all base_urls with all object_ids
        self.start_urls = [url.format(object_id) for object_id in CATA_OBJECT_IDS for url in self.base_urls]

    def parse(self, response):
        locale = re.search(r'/(\w+)/object', response.url).group(1)

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
        print("DONE")