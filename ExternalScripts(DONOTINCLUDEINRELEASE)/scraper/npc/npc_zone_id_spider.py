import logging
import re

import scrapy


class NpcZoneIdSpider(scrapy.Spider):
    name = "npc_zone_id"
    base_url_classic = "https://www.wowhead.com/npc={}"

    start_urls = []

    def __init__(self) -> None:
        super().__init__()
        self.start_urls = [self.base_url_classic.format(npc_id) for npc_id in range(1, 100)]  # TODO: Add actual NPC IDs

    def parse(self, response):
        # debug the response
        # with open('response.html', 'wb') as f:
        #     f.write(response.body)

        if response.url.startswith('https://www.wowhead.com/npcs?notFound='):
            npc_id = re.search(r'https://www.wowhead.com/npcs\?notFound=(\d+)', response.url).group(1)
            logging.warning('\x1b[31;20mNPC with ID {npc_id} not found\x1b[0m'.format(npc_id=npc_id))
            return None

        print('response.url', response.url)

        result = {
            "npcId": re.search(r'https://www.wowhead.com/npc=(\d+)', response.url).group(1)
        }
        # This extract the zoneId from the onclick of the "This NPC can be found in X" link in the NPC description
        location_on_click = response.xpath('//span[@id="locations"]//a/@onclick').extract()
        if location_on_click:
            result["zoneId"] = re.search(r'zone: (\d+),', location_on_click[0]).group(1)
            yield result
