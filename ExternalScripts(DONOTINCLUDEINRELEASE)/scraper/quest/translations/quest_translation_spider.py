import logging
import re
from scrapy import signals, Spider

from quest.quest_ids_retail import QUEST_IDS_RETAIL
from quest.translations.quest_translation_formatter import QuestTranslationFormatter
from quest.translations.quest_translation_move_to_lookups import main as move_to_lookups
from supported_locales import LOCALES


class QuestTranslationSpider(Spider):
    name = "quest-translations"
    base_urls = [
        f"https://www.wowhead.com/{locale['input']}/quest={{}}" for locale in LOCALES
    ]

    start_urls = []

    def __init__(self) -> None:
        super().__init__()
        self.start_urls = [url.format(quest_id) for quest_id in QUEST_IDS_RETAIL for url in self.base_urls]

    def parse(self, response):
        locale = re.search(r'/([a-z]{2})/quest', response.url).group(1)

        if response.url.find('/quests?notFound=') != -1:
            quest_id = re.search(r'/quests\?notFound=(\d+)', response.url).group(1)
            logging.warning('\x1b[31;20mQuest with ID {quest_id} not found for {locale}\x1b[0m'.format(quest_id=quest_id, locale=locale))
            return None

        quest_id = re.search(r'/quest=(\d+)', response.url).group(1)
        result = {"questId": quest_id, "locale": locale}

        quest_name = response.xpath('//div[@class="text"]/h1/text()').get()
        if quest_name and not quest_name.startswith("["):
            result["name"] = quest_name

        objectives_text = response.xpath('//meta[@name="description"]/@content').get()
        if objectives_text:
            result["objectivesText"] = objectives_text.strip()

        yield result

    @classmethod
    def from_crawler(cls, crawler, *args, **kwargs):
        spider = super(QuestTranslationSpider, cls).from_crawler(crawler, *args, **kwargs)
        crawler.signals.connect(spider.spider_feed_closed, signal=signals.feed_exporter_closed)
        return spider

    def spider_feed_closed(self):
        print("Finished scraping quest translations, now formatting the data...")
        formatter = QuestTranslationFormatter()
        formatter()
        print("Formatting done, now moving to lookups...")
        move_to_lookups()
        print("DONE")
