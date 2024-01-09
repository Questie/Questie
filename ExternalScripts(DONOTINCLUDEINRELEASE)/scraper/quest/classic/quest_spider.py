from scrapy import signals

from quest.classic.quest_formatter import ClassicQuestFormatter
from quest.quest_spider import QuestSpider
from quest.classic.quest_ids import QUEST_IDS

class ClassicQuestSpider(QuestSpider):
    def __init__(self) -> None:
        super().__init__()
        self.start_urls = [self.base_url_classic.format(quest_id) for quest_id in QUEST_IDS]

    @classmethod
    def from_crawler(cls, crawler, *args, **kwargs):
        spider = super(ClassicQuestSpider, cls).from_crawler(crawler, *args, **kwargs)
        crawler.signals.connect(spider.spider_feed_closed, signal=signals.feed_exporter_closed)
        return spider

    def spider_feed_closed(self):
        f = ClassicQuestFormatter()
        f()
