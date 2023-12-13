from logging import getLogger
from pathlib import Path

from scrapy.crawler import CrawlerProcess

from item.item_spider import ItemSpider
from npc.npc_spider import NPCSpider
from object.object_spider import ObjectSpider
from quest.quest_spider import QuestSpider


class Runner:

    def __init__(self) -> None:
        self.logger = getLogger(__name__)
        Path("quest/quest_data.json").unlink(missing_ok=True)
        Path("npc/npc_data.json").unlink(missing_ok=True)
        Path("item/item_data.json").unlink(missing_ok=True)
        Path("object/object_data.json").unlink(missing_ok=True)

    def run(self) -> None:
        process = CrawlerProcess(settings={
            "LOG_LEVEL": "INFO",
            "FEED_EXPORT_ENCODING": "utf-8",
            "FEED_FORMAT": "json",
            "CONCURRENT_REQUESTS": 32,
            # "FEED_URI": "quest/quest_data.json",
            # "FEED_URI": "npc/npc_data.json",
            # "FEED_URI": "item/item_data.json",
            "FEED_URI": "object/object_data.json",
            "COOKIES_ENABLED": False
        })

        # TODO: Add Argument parser to select which spider to run

        # process.crawl(QuestSpider)
        # process.crawl(NPCSpider)
        # process.crawl(ItemSpider)
        process.crawl(ObjectSpider)

        process.start()


if __name__ == '__main__':
    runner = Runner()
    runner.run()
