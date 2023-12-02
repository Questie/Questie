import re
import scrapy

class QuestSpider(scrapy.Spider):
    name = "quest"
    start_urls = [
        'https://www.wowhead.com/classic/quest=77667',
    ]

    def parse(self, response):
        result = {}
        for script in response.xpath('//script/text()').extract():
            if script.startswith('//<![CDATA[\nWH.Gatherer.addData') and script.endswith('//]]>'):
                result['questId'] = re.search(r'g_quests\[(\d+)\]', script).group(1)
                result['name'] = re.search(r'"name":"([^"]+)"', script).group(1)
                result['level'] = re.search(r'"level":(\d+)', script).group(1)
                result['reqLevel'] = re.search(r'"reqlevel":(\d+)', script).group(1)
                result['reqClass'] = re.search(r'"reqclass":(\d+)', script).group(1)
                result['reqRace'] = re.search(r'"reqrace":(\d+)', script).group(1)
            if script.lstrip().startswith('WH.markup'):
                result['start'] = re.search(r'Start:.*?npc=(\d+)', script).group(1)
                result['end'] = re.search(r'End:.*?npc=(\d+)', script).group(1)
        if result:
            yield result
