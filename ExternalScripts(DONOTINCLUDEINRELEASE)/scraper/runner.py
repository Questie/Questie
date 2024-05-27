from argparse import ArgumentParser
from logging import getLogger
from pathlib import Path

from scrapy.crawler import CrawlerProcess

from item.item_spider import ItemSpider
from npc.npc_spider import NPCSpider
from npc.npc_zone_id_spider import NpcZoneIdSpider
from object.object_spider import ObjectSpider
from object.object_zone_id_spider import ObjectZoneIdSpider
from quest.quest_spider import QuestSpider
from quest.classic.quest_spider import ClassicQuestSpider
from quest.sod_translations.quest_translation_spider import QuestTranslationSpider

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

    def run_classic_quest(self) -> None:
        Path("quest/classic/quest_data.json").unlink(missing_ok=True)
        process = CrawlerProcess(settings={**BASE_SETTINGS, "FEED_URI": "quest/classic/quest_data.json"})
        process.crawl(ClassicQuestSpider)
        process.start()

    def run_quest_translations(self) -> None:
        Path("quest/sod_translations/quest_data.json").unlink(missing_ok=True)
        process = CrawlerProcess(settings={**BASE_SETTINGS, "FEED_URI": "quest/sod_translations/quest_data.json"})
        process.crawl(QuestTranslationSpider)
        process.start()

    def run_npc(self) -> None:
        Path("npc/npc_data.json").unlink(missing_ok=True)
        process = CrawlerProcess(settings={**BASE_SETTINGS, "FEED_URI": "npc/npc_data.json"})
        process.crawl(NPCSpider)
        process.start()

    def run_npc_zone_ids(self) -> None:
        Path("npc/npc_zone_id_data.json").unlink(missing_ok=True)
        process = CrawlerProcess(settings={**BASE_SETTINGS, "FEED_URI": "npc/npc_zone_id_data.json"})
        process.crawl(NpcZoneIdSpider)
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

    def run_object_zone_ids(self) -> None:
        Path("object/object_zone_id_data.json").unlink(missing_ok=True)
        process = CrawlerProcess(settings={**BASE_SETTINGS, "FEED_URI": "object/object_zone_id_data.json"})
        process.crawl(ObjectZoneIdSpider)
        process.start()


if __name__ == '__main__':
    parser = ArgumentParser()
    parser.add_argument("--quest", help="Run quest spider", action="store_true")
    parser.add_argument("--quest-classic", help="Run quest spider for classic wow", action="store_true")
    parser.add_argument("--quest-translations", help="Run quest spider for SoD translations", action="store_true")
    parser.add_argument("--npc", help="Run npc spider", action="store_true")
    parser.add_argument("--npc-zone", help="Run npc zone IDs spider", action="store_true")
    parser.add_argument("--item", help="Run item spider", action="store_true")
    parser.add_argument("--object", help="Run object spider", action="store_true")
    parser.add_argument("--object-zone", help="Run object zone IDs spider", action="store_true")

    args = parser.parse_args()

    if (not args.quest) and (not args.quest_classic) and (not args.quest_translations) and (not args.npc) and (not args.npc_zone) and (not args.item) and (not args.object) and (not args.object_zone):
        parser.error("No spider selected")

    runner = Runner()

    if args.quest:
        print("Running quest spider")
        runner.run_quest()
    if args.quest_classic:
        print("Running quest spider for classic wow")
        runner.run_classic_quest()
    if args.quest_translations:
        print("Running quest spider for SoD translations")
        runner.run_quest_translations()
    if args.npc:
        print("Running npc spider")
        runner.run_npc()
    if args.npc_zone:
        print("Running npc zone ID spider")
        runner.run_npc_zone_ids()
    if args.item:
        print("Running item spider")
        runner.run_item()
    if args.object:
        print("Running object spider")
        runner.run_object()
    if args.object_zone:
        print("Running object zone ID spider")
        runner.run_object_zone_ids()
