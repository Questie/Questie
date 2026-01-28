import logging
import re

import scrapy

from object.object_ids_complete import OBJECT_IDS_COMPLETE


class ObjectZoneIdSpider(scrapy.Spider):
    name = "object_zone_id"
    base_url = "https://www.wowhead.com/classic/object={}"
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

        self.base_url = "https://www.wowhead.com/" + self.exp + "object={}"
        self.start_urls = [self.base_url.format(object_id) for object_id in OBJECT_IDS_COMPLETE]

    def parse(self, response):
        # debug the response
        # with open('response.html', 'wb') as f:
        #     f.write(response.body)

        if response.url.startswith(f'https://www.wowhead.com/{self.exp}objects?notFound='):
            object_id = re.search(rf'https://www.wowhead.com/{self.exp}objects\?notFound=(\d+)', response.url).group(1)
            logging.warning('\x1b[31;20mObject with ID {object_id} not found\x1b[0m'.format(object_id=object_id))
            return None

        result = {
            "objectId": re.search(rf'https://www.wowhead.com/{self.exp}object=(\d+)', response.url).group(1)
        }
        # This extract the zoneId from the onclick of the "This object can be found in X" link in the Object description
        location_on_click = response.xpath('//span[@id="locations"]//a/@onclick').extract()
        if location_on_click:
            result["zoneId"] = re.search(r'zone: (\d+),', location_on_click[0]).group(1)
            yield result
