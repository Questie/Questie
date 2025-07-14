import logging
import re
from scrapy import signals, Spider
from npc.retail_npc_ids import RETAIL_NPC_IDS
from npc.translations.npc_translation_formatter import NPCTranslationFormatter
from npc.translations.npc_translation_move_to_lookups import main as move_to_lookups
from supported_locales import LOCALES


class NPCTranslationSpider(Spider):
    name = "npc-translations"
    base_urls = [
        f"https://www.wowhead.com/{locale['input']}/npc={{}}" for locale in LOCALES
    ]

    start_urls = []

    def __init__(self) -> None:
        super().__init__()
        self.start_urls = [url.format(npc_id) for npc_id in RETAIL_NPC_IDS for url in self.base_urls]

    def parse(self, response):
        locale = re.search(r'/([a-z]{2})/npc', response.url).group(1)

        if response.url.find('/npcs?notFound=') != -1:
            npc_id = re.search(r'/npcs\?notFound=(\d+)', response.url).group(1)
            logging.warning('\x1b[31;20mNPC with ID {npc_id} not found for {locale}\x1b[0m'.format(npc_id=npc_id, locale=locale))
            return None

        npc_id = re.search(r'/npc=(\d+)', response.url).group(1)
        result = {"npcId": npc_id, "locale": locale}

        npc_name = response.xpath('//div[@class="text"]/h1/text()').get()
        if npc_name and not npc_name.startswith("["):
            result["name"] = npc_name

        yield result

    @classmethod
    def from_crawler(cls, crawler, *args, **kwargs):
        spider = super(NPCTranslationSpider, cls).from_crawler(crawler, *args, **kwargs)
        crawler.signals.connect(spider.spider_feed_closed, signal=signals.feed_exporter_closed)
        return spider

    def spider_feed_closed(self):
        print("Finished scrapting NPC translations, now formatting the data...")
        formatter = NPCTranslationFormatter()
        formatter()
        print("Formatting done, now moving to lookups...")
        move_to_lookups()
        print("DONE")
