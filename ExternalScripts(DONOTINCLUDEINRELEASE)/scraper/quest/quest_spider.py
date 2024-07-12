import logging
import re
import scrapy
from scrapy import signals

from quest.quest_formatter import QuestFormatter
from quest.quest_ids import QUEST_IDS
from quest.factions_ignore import FACTIONS_IGNORE_LIST


class QuestSpider(scrapy.Spider):
    name = "quest"
    base_url_classic = "https://www.wowhead.com/classic/quest={}"

    start_urls = []

    def __init__(self) -> None:
        super().__init__()
        self.start_urls = [self.base_url_classic.format(quest_id) for quest_id in QUEST_IDS]

    def parse(self, response):
        # debug the response
        # with open('response.html', 'wb') as f:
        #     f.write(response.body)

        if response.url.startswith('https://www.wowhead.com/classic/quests?notFound='):
            questID = re.search(r'https://www.wowhead.com/classic/quests\?notFound=(\d+)', response.url).group(1)
            logging.warning('\x1b[31;20mQuest with ID {questID} not found\x1b[0m'.format(questID=questID))
            return None

        result = {}
        for script in response.xpath('//script/text()').extract():
            if script.startswith('//<![CDATA[\nWH.Gatherer.addData') and script.find('$.extend(g_quests') >= 0 and script.endswith('//]]>'):
                result["questId"] = re.search(r'g_quests\[(\d+)]', script).group(1)
                result["name"] = re.search(r'"name":"([^"]+)"', script).group(1)
                result["level"] = self.__match_level(re.search(r'"level":(\d+)', script))
                result["reqLevel"] = self.__match_level(re.search(r'"reqlevel":(\d+)', script))
                result["reqClass"] = re.search(r'"reqclass":(\d+)', script).group(1)
                # "reprewards":[[<factionId>,<value>],[<factionId2>,<value2>],...]
                repRewardsMatch = re.search(r'"reprewards":\[(\[\d+,-?\d+\](,\[\d+,-?\d+\])*)\]', script)
                if repRewardsMatch:
                    result["repRewards"] = self.__normalize_reputation(
                        result["questId"],
                        repRewardsMatch.group(1).rstrip(']').lstrip('[').replace('],[', ',').split(',')
                    )
                if "reqRace" not in result:
                    result["reqRace"] = re.search(r'"reqrace":(\d+)', script).group(1)
            if script.lstrip().startswith('WH.markup'):
                result["start"] = self.__match_start(re.search(r'Start:.*?npc=(\d+)', script))
                result["end"] = self.__match_end(script)
            if (("reqRace" not in result) or result["reqRace"] == "0") and script.strip().startswith('WH.markup.printHtml'):
                result["reqRace"] = self.__get_fallback_faction(script)

        objectives_text = response.xpath('//meta[@name="description"]/@content').get()
        if objectives_text:
            result["objectivesText"] = objectives_text.strip()

        kill_objectives = response.xpath('//tr[@data-icon-list-quantity]/td/a[contains(@href, "/npc=")]/@href').getall()
        if kill_objectives:
            result["killObjective"] = [re.search(r'npc=(\d+)', kill_objective).group(1) for kill_objective in kill_objectives]

        item_objectives = self.__match_item_objectives(response)
        if item_objectives:
            result["itemObjective"] = item_objectives

        spell_objective = response.xpath('//a[@class="q"]/@href').get()
        if spell_objective:
            result["spellObjective"] = re.search(r'spell=(\d+)', spell_objective).group(1)

        pre_quest_single, pre_quest_group, next_quest = self.__get_quest_chain(response)
        if pre_quest_single:
            result["preQuestSingle"] = pre_quest_single
        if pre_quest_group:
            result["preQuestGroup"] = pre_quest_group
        if next_quest:
            result["nextQuest"] = next_quest

        # example quest: https://www.wowhead.com/classic/quest=1679/muren-stormpike
        exclusive_to_script = response.xpath('//th[text()="Disables"]/../following-sibling::tr/td/script/text()').get()
        if exclusive_to_script:
            result["exclusiveTo"] = re.findall(r'quest=(\d+)', exclusive_to_script)

        if result:
            yield result

    def __normalize_reputation(self, questID, reputationRewards):
        i = 0
        normalized_reputations = []
        while i < len(reputationRewards):
            reward = (reputationRewards[i], reputationRewards[i + 1])
            i = i + 2

            if int(reward[0]) in FACTIONS_IGNORE_LIST:
                continue

            # if we already have the same reputation reward from the same faction, ignore it
            if any(item[0] == reward[0] for item in normalized_reputations):
                existing_reward = next(item for item in normalized_reputations if item[0] == reward[0])
                logging.info("Quest with ID {questID} has multiple reputations rewards for the same faction: {reward1} vs. {reward2}. Ignoring.".format(questID=questID, reward1=reward, reward2=existing_reward))
            else:
                normalized_reputations.append(reward)

        return normalized_reputations

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
        react_alliance_match = re.search(r']Alliance\[', script)
        react_horde_match = re.search(r']Horde\[', script)
        if react_alliance_match and (not react_horde_match):
            return "77"
        elif react_horde_match and (not react_alliance_match):
            return "178"
        return "0"

    def __match_item_objectives(self, response):
        item_objective = []

        for i in range(1, 6):  # Sometimes the link class is q1, q2, q3, ...
            item_objective_match = response.xpath('//a[@class="q{}"]'.format(i))
            for item in item_objective_match:
                item_provided = item.xpath('./following-sibling::text()').get()
                if item_provided is None or item_provided.strip() != "(Provided)":
                    item_objective.append(re.search(r'item=(\d+)', item.xpath('./@href').get()).group(1))
        if item_objective:
            return item_objective
        return None

    def __get_quest_chain(self, response):
        pre_quest_single, pre_quest_group, next_quest = None, None, None
        # Example quest: https://www.wowhead.com/classic/quest=1678/vejrek
        requires_any_script = response.xpath('//th[text()="Requires Any"]/../following-sibling::tr/td/script/text()').get()
        if requires_any_script:
            pre_quest_single = re.findall(r'quest=(\d+)', requires_any_script)
        else:
            # example quest: https://www.wowhead.com/classic/quest=4822/you-scream-i-scream
            requires_script = response.xpath('//th[text()="Requires"]/../following-sibling::tr/td/script/text()').get()
            if requires_script:
                all_required = re.findall(r'quest=(\d+)', requires_script)
                if len(all_required) == 1:
                    pre_quest_single = all_required
                else:
                    pre_quest_group = all_required

        # Example quest: https://www.wowhead.com/classic/quest=1678/vejrek
        rows = response.xpath('//table[@class="series"]/tr')
        pre_quest_row = None
        next_quest_row = None
        for i, row in enumerate(rows):
            if row.xpath('.//b'):
                pre_quest_row = rows[i - 1] if i > 0 else None
                next_quest_row = rows[i + 1] if i < len(rows) - 1 else None
                break
        if pre_quest_row and pre_quest_single is None:
            pre_quest_single = [re.search(r'quest=(\d+)', pre_quest_row.xpath('.//a/@href').get()).group(1)]
        if next_quest_row:
            next_quest = re.search(r'quest=(\d+)', next_quest_row.xpath('.//a/@href').get()).group(1)

        return pre_quest_single, pre_quest_group, next_quest

    @classmethod
    def from_crawler(cls, crawler, *args, **kwargs):
        spider = super(QuestSpider, cls).from_crawler(crawler, *args, **kwargs)
        crawler.signals.connect(spider.spider_feed_closed, signal=signals.feed_exporter_closed)
        return spider

    def spider_feed_closed(self):
        f = QuestFormatter()
        f()
