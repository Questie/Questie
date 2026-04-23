import logging
import re

import scrapy

from npc.npc_ids_complete import NPC_IDS_COMPLETE


class NpcZoneIdSpider(scrapy.Spider):
    name = "npc_zone_id"
    base_url = "https://www.wowhead.com/classic/npc={}"
    exp = ""

    start_urls = []

    def __init__(self, expansion: int) -> None:
        super().__init__()

        # This expansion code differs from the other spiders because we also need to use the expansion prefix later on for URL validation
        match expansion:
            case 0:
                self.exp = ""
            case 1:
                self.exp = "classic/"
            case 2:
                self.exp = "tbc/"
            case 3:
                self.exp = "wotlk/"
            case 4:
                self.exp = "cata/"
            case 5:
                self.exp = "mop-classic/"
            case _: # If number is unknown, treat it as classic
                self.exp = "classic/"

        self.base_url = "https://www.wowhead.com/" + self.exp + "npc={}"
        self.start_urls = [self.base_url.format(npc_id) for npc_id in NPC_IDS_COMPLETE]

    def parse(self, response):
        # debug the response
        # with open('response.html', 'wb') as f:
        #     f.write(response.body)

        if response.url.startswith(f'https://www.wowhead.com/{self.exp}npcs?notFound='):
            npc_id = re.search(rf'https://www.wowhead.com/{self.exp}npcs\?notFound=(\d+)', response.url).group(1)
            logging.warning('\x1b[31;20mNPC with ID {npc_id} not found\x1b[0m'.format(npc_id=npc_id))
            return None

        result = {
            "npcId": re.search(rf'https://www.wowhead.com/{self.exp}npc=(\d+)', response.url).group(1)
        }
        # This extract the zoneId from the onclick of the "This NPC can be found in X" link in the NPC description
        location_on_click = response.xpath('//span[@id="locations"]//a/@onclick').extract()
        if location_on_click:
            result["zoneId"] = re.search(r'zone: (\d+),', location_on_click[0]).group(1)
            yield result
