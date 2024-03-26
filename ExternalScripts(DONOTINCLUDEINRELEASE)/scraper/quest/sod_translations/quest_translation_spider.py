import logging
import re
import scrapy
from scrapy import signals

from quest.quest_formatter import QuestFormatter
from quest.quest_ids import QUEST_IDS


class QuestTranslationSpider(scrapy.Spider):
    name = "quest-translations"
    base_urls = [
        "https://www.wowhead.com/classic/de/quest={}",
        "https://www.wowhead.com/classic/es/quest={}",
        "https://www.wowhead.com/classic/fr/quest={}",
        "https://www.wowhead.com/classic/pt/quest={}",
        "https://www.wowhead.com/classic/ru/quest={}",
        "https://www.wowhead.com/classic/ko/quest={}",
        "https://www.wowhead.com/classic/cn/quest={}",
    ]

    start_urls = []

    def __init__(self) -> None:
        super().__init__()
        # all base_urls with all quest_ids
        self.start_urls = [url.format(quest_id) for quest_id in QUEST_IDS for url in self.base_urls]

    def parse(self, response):
        # debug the response
        # with open('response.html', 'wb') as f:
        #     f.write(response.body)

        if response.url.startswith('https://www.wowhead.com/classic/quests?notFound='):
            questID = re.search(r'https://www.wowhead.com/classic/quests\?notFound=(\d+)', response.url).group(1)
            logging.warning('\x1b[31;20mQuest with ID {questID} not found\x1b[0m'.format(questID=questID))
            return None

        locale = re.search(r'https://www.wowhead.com/classic/(\w+)/quest', response.url).group(1)
        quest_id = re.search(r'/quest=(\d+)', response.url).group(1)

        result = {"questId": quest_id, "locale": locale}

        quest_title = response.xpath('//div[@class="text"]/h1/text()').get()
        if not quest_title.startswith("["):
            result["title"] = quest_title

        yield result

    @classmethod
    def from_crawler(cls, crawler, *args, **kwargs):
        spider = super(QuestTranslationSpider, cls).from_crawler(crawler, *args, **kwargs)
        crawler.signals.connect(spider.spider_feed_closed, signal=signals.feed_exporter_closed)
        return spider

    def spider_feed_closed(self):
        f = QuestFormatter()
        f()
