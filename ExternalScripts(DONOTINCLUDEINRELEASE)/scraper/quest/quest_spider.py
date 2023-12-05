import re
import scrapy
from scrapy import signals

from quest.quest_ids import QUEST_IDS
from quest_formatter import QuestFormatter


class QuestSpider(scrapy.Spider):
    name = "quest"
    base_url_classic = "https://www.wowhead.com/classic/quest={}"

    start_urls = []

    def __init__(self) -> None:
        super().__init__()
        self.start_urls = [self.base_url_classic.format(quest_id) for quest_id in QUEST_IDS]

    def parse(self, response):
        result = {}
        for script in response.xpath('//script/text()').extract():
            if script.startswith('//<![CDATA[\nWH.Gatherer.addData') and script.endswith('//]]>'):
                result["questId"] = re.search(r'g_quests\[(\d+)\]', script).group(1)
                result["name"] = re.search(r'"name":"([^"]+)"', script).group(1)
                result["level"] = re.search(r'"level":(\d+)', script).group(1)
                result["reqLevel"] = re.search(r'"reqlevel":(\d+)', script).group(1)
                result["reqClass"] = re.search(r'"reqclass":(\d+)', script).group(1)
                result["reqRace"] = re.search(r'"reqrace":(\d+)', script).group(1)
            if script.lstrip().startswith('WH.markup'):
                result["start"] = re.search(r'Start:.*?npc=(\d+)', script).group(1)
                result["end"] = re.search(r'End:.*?npc=(\d+)', script).group(1)
        if result:
            yield result

    @classmethod
    def from_crawler(cls, crawler, *args, **kwargs):
        spider = super(QuestSpider, cls).from_crawler(crawler, *args, **kwargs)
        crawler.signals.connect(spider.spider_closed, signal=signals.spider_closed)
        return spider

    def spider_closed(self, spider):
        self.logger.info("Spider closed.")

        f = QuestFormatter()
        f()

