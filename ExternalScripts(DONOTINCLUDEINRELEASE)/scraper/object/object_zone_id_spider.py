import logging
import re

import scrapy

from npc.npc_ids_complete import NPC_IDS_COMPLETE
from object.object_ids_complete import OBJECT_IDS_COMPLETE


class ObjectZoneIdSpider(scrapy.Spider):
    name = "object_zone_id"
    base_url_classic = "https://www.wowhead.com/object={}"

    start_urls = []

    def __init__(self) -> None:
        super().__init__()
        self.start_urls = [self.base_url_classic.format(object_id) for object_id in OBJECT_IDS_COMPLETE]

    def parse(self, response):
        # debug the response
        # with open('response.html', 'wb') as f:
        #     f.write(response.body)

        if response.url.startswith('https://www.wowhead.com/objects?notFound='):
            object_id = re.search(r'https://www.wowhead.com/objects\?notFound=(\d+)', response.url).group(1)
            logging.warning('\x1b[31;20mObject with ID {object_id} not found\x1b[0m'.format(object_id=object_id))
            return None

        result = {
            "objectId": re.search(r'https://www.wowhead.com/object=(\d+)', response.url).group(1)
        }
        # This extract the zoneId from the onclick of the "This object can be found in X" link in the Object description
        location_on_click = response.xpath('//span[@id="locations"]//a/@onclick').extract()
        if location_on_click:
            result["zoneId"] = re.search(r'zone: (\d+),', location_on_click[0]).group(1)
            yield result
