import re
import scrapy
from scrapy import signals

from quest.quest_formatter import QuestFormatter
from quest.quest_ids import QUEST_IDS


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
                result["questId"] = re.search(r'g_quests\[(\d+)]', script).group(1)
                result["name"] = re.search(r'"name":"([^"]+)"', script).group(1)
                result["level"] = self.__match_level(re.search(r'"level":(\d+)', script))
                result["reqLevel"] = self.__match_level(re.search(r'"reqlevel":(\d+)', script))
                result["reqClass"] = re.search(r'"reqclass":(\d+)', script).group(1)
                result["reqRace"] = re.search(r'"reqrace":(\d+)', script).group(1)
            if script.lstrip().startswith('WH.markup'):
                result["start"] = self.__match_start(re.search(r'Start:.*?npc=(\d+)', script))
                result["end"] = self.__match_end(script)

        objectives_text = response.xpath('//meta[@name="description"]/@content').get()
        if objectives_text:
            result["objectivesText"] = objectives_text.strip()

        if result:
            yield result

    def __match_level(self, level_match):
        return level_match.group(1) if level_match else 0

    def __match_start(self, start_match):
        return start_match.group(1) if start_match else "nil"

    def __match_end(self, script):
        end_match = re.findall(r'End:.*?npc=(\d+)', script)

        if end_match:
            ret = []
            for match in end_match:
                ret.append(match)
            return ret

        return "nil"

    @classmethod
    def from_crawler(cls, crawler, *args, **kwargs):
        spider = super(QuestSpider, cls).from_crawler(crawler, *args, **kwargs)
        crawler.signals.connect(spider.spider_closed, signal=signals.spider_closed)
        return spider

    def spider_closed(self, spider):
        self.logger.info("Spider closed.")

        # f = QuestFormatter()
        # f()

