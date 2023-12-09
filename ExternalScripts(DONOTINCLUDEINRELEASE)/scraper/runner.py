from logging import getLogger
from pathlib import Path

from scrapy.crawler import CrawlerProcess

from item.item_spider import ItemSpider
from npc.npc_spider import NPCSpider
from quest.quest_spider import QuestSpider


class Runner:

    def __init__(self) -> None:
        self.logger = getLogger(__name__)
        Path("quest/quest_data.json").unlink(missing_ok=True)
        Path("npc/npc_data.json").unlink(missing_ok=True)
        Path("item/item_data.json").unlink(missing_ok=True)

    def run(self) -> None:
        process = CrawlerProcess(settings={
            "LOG_LEVEL": "INFO",
            "FEED_EXPORT_ENCODING": "utf-8",
            "FEED_FORMAT": "json",
            "CONCURRENT_REQUESTS": 32,
            "FEED_URI": "quest/quest_data.json",
            "COOKIES_ENABLED": False
        })

        # TODO: Add Argument parser to select which spider to run

        # process.settings.attributes["FEED_URI"].value = "json"
        # Path("quest/quest_data.json").unlink(missing_ok=True)
        process.crawl(QuestSpider)
        # process.settings.attributes["FEEDS"].value = "npc/npc_data.json"
        # Path("npc/npc_data.json").unlink(missing_ok=True)
        # process.crawl(NPCSpider)
        # process.settings.attributes["FEEDS"].value = "item/item_data.json"
        # Path("item/item_data.json").unlink(missing_ok=True)
        # process.crawl(ItemSpider)

        process.start()


if __name__ == '__main__':
    runner = Runner()
    runner.run()
