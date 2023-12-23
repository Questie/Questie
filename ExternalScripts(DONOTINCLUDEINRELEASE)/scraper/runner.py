from argparse import ArgumentParser
from logging import getLogger
from pathlib import Path

from scrapy.crawler import CrawlerProcess

from item.item_spider import ItemSpider
from npc.npc_spider import NPCSpider
from object.object_spider import ObjectSpider
from quest.quest_spider import QuestSpider

BASE_SETTINGS = {
    "LOG_LEVEL": "INFO",
    "FEED_EXPORT_ENCODING": "utf-8",
    "FEED_FORMAT": "json",
    "CONCURRENT_REQUESTS": 32,
    "COOKIES_ENABLED": False
}

class Runner:

    def __init__(self) -> None:
        self.logger = getLogger(__name__)

    def run_quest(self) -> None:
        Path("quest/quest_data.json").unlink(missing_ok=True)
        process = CrawlerProcess(settings={**BASE_SETTINGS, "FEED_URI": "quest/quest_data.json"})
        process.crawl(QuestSpider)
        process.start()

    def run_npc(self) -> None:
        Path("npc/npc_data.json").unlink(missing_ok=True)
        process = CrawlerProcess(settings={**BASE_SETTINGS, "FEED_URI": "npc/npc_data.json"})
        process.crawl(NPCSpider)
        process.start()

    def run_item(self) -> None:
        Path("item/item_data.json").unlink(missing_ok=True)
        process = CrawlerProcess(settings={**BASE_SETTINGS, "FEED_URI": "item/item_data.json"})
        process.crawl(ItemSpider)
        process.start()

    def run_object(self) -> None:
        Path("object/object_data.json").unlink(missing_ok=True)
        process = CrawlerProcess(settings={**BASE_SETTINGS, "FEED_URI": "object/object_data.json"})
        process.crawl(ObjectSpider)
        process.start()


if __name__ == '__main__':
    parser = ArgumentParser()
    parser.add_argument("--quest", help="Run quest spider", action="store_true")
    parser.add_argument("--npc", help="Run npc spider", action="store_true")
    parser.add_argument("--item", help="Run item spider", action="store_true")
    parser.add_argument("--object", help="Run object spider", action="store_true")

    args = parser.parse_args()

    if (not args.quest) and (not args.npc) and (not args.item) and (not args.object):
        parser.error("No spider selected")

    runner = Runner()

    if args.quest:
        print("Running quest spider")
        runner.run_quest()
    if args.npc:
        print("Running npc spider")
        runner.run_npc()
    if args.item:
        print("Running item spider")
        runner.run_item()
    if args.object:
        print("Running object spider")
        runner.run_object()
