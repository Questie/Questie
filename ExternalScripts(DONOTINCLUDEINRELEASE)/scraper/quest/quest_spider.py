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
            if (("reqRace" not in result) or result["reqRace"] == "0") and script.startswith('//<![CDATA[\nvar g_mapperData'):
                result["reqRace"] = self.__get_fallback_faction(script)

        objectives_text = response.xpath('//meta[@name="description"]/@content').get()
        if objectives_text:
            result["objectivesText"] = objectives_text.strip()

        result["itemObjective"] = self.__match_item_objectives(response)

        spell_objective = response.xpath('//a[@class="q"]/@href').get()
        if spell_objective:
            result["spellObjective"] = re.search(r'spell=(\d+)', spell_objective).group(1)

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

    def __get_fallback_faction(self, script):
        react_alliance_match = re.search(r'"reactalliance":(\d+)', script)
        react_horde_match = re.search(r'"reacthorde":(-?\d+)', script)
        if react_alliance_match and react_horde_match:
            react_alliance = react_alliance_match.group(1)
            react_horde = react_horde_match.group(1)
            if react_alliance == "1" and react_horde != "1":
                return "77"
            elif react_horde == "1" and react_alliance != "1":
                return "178"
        return "0"

    def __match_item_objectives(self, response):
        item_objective = []
        item_objective_match = response.xpath('//a[@class="q1"]')
        for item in item_objective_match:
            item_provided = item.xpath('./following-sibling::text()').get()
            if item_provided is None or item_provided.strip() != "(Provided)":
                item_objective.append(re.search(r'item=(\d+)', item.xpath('./@href').get()).group(1))
        if item_objective:
            return item_objective
        return None

    @classmethod
    def from_crawler(cls, crawler, *args, **kwargs):
        spider = super(QuestSpider, cls).from_crawler(crawler, *args, **kwargs)
        crawler.signals.connect(spider.spider_feed_closed, signal=signals.feed_exporter_closed)
        return spider

    def spider_feed_closed(self):
        f = QuestFormatter()
        f()

