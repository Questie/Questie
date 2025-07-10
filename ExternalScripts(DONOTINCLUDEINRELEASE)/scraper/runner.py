from argparse import ArgumentParser
from logging import getLogger
from pathlib import Path

from scrapy.crawler import CrawlerProcess

from item.item_spider import ItemSpider
from item.item_translation_spider import ItemTranslationSpider
from npc.npc_spider import NPCSpider
from npc.npc_zone_id_spider import NpcZoneIdSpider
from object.object_spider import ObjectSpider
from object.translations.object_translation_spider import ObjectTranslationSpider
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

    def run_quest(self, run_for_retail: bool) -> None:
        Path("quest/quest_data.json").unlink(missing_ok=True)
        process = CrawlerProcess(settings={**BASE_SETTINGS, "FEED_URI": "quest/quest_data.json"})
        process.crawl(QuestSpider, run_for_retail)
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

    def run_npc(self, run_for_retail: bool) -> None:
        Path("npc/npc_data.json").unlink(missing_ok=True)
        process = CrawlerProcess(settings={**BASE_SETTINGS, "FEED_URI": "npc/npc_data.json"})
        process.crawl(NPCSpider, run_for_retail)
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

    def run_item_translations(self) -> None:
        Path("item/translations").mkdir(parents=True, exist_ok=True)
        Path("item/translations/scraped_data.json").unlink(missing_ok=True)
        process = CrawlerProcess(settings={**BASE_SETTINGS, "FEED_URI": "item/translations/scraped_data.json"})
        process.crawl(ItemTranslationSpider)
        process.start()

    def run_object(self, run_for_retail: bool) -> None:
        Path("object/object_data.json").unlink(missing_ok=True)
        process = CrawlerProcess(settings={**BASE_SETTINGS, "FEED_URI": "object/object_data.json"})
        process.crawl(ObjectSpider, run_for_retail)
        process.start()

    def run_object_translations(self) -> None:
        Path("object/translations").mkdir(parents=True, exist_ok=True)
        Path("object/translations/scraped_data.json").unlink(missing_ok=True)
        process = CrawlerProcess(settings={**BASE_SETTINGS, "FEED_URI": "object/translations/scraped_data.json"})
        process.crawl(ObjectTranslationSpider)
        process.start()

    def run_object_zone_ids(self) -> None:
        Path("object/object_zone_id_data.json").unlink(missing_ok=True)
        process = CrawlerProcess(settings={**BASE_SETTINGS, "FEED_URI": "object/object_zone_id_data.json"})
        process.crawl(ObjectZoneIdSpider)
        process.start()


if __name__ == '__main__':
    parser = ArgumentParser()
    parser.add_argument("--retail", help="Run spider against retail wowhead", action="store_true")
    parser.add_argument("--quest", help="Run quest spider", action="store_true")
    parser.add_argument("--quest-classic", help="Run quest spider for classic wow", action="store_true")
    parser.add_argument("--quest-translations", help="Run quest spider for SoD translations", action="store_true")
    parser.add_argument("--npc", help="Run npc spider", action="store_true")
    parser.add_argument("--npc-zone", help="Run npc zone IDs spider", action="store_true")
    parser.add_argument("--item", help="Run item spider", action="store_true")
    parser.add_argument("--object", help="Run object spider", action="store_true")
    parser.add_argument("--object-translations", help="Run object translation spider", action="store_true")
    parser.add_argument("--object-zone", help="Run object zone IDs spider", action="store_true")
    parser.add_argument("--item-translations", help="Run item translation spider", action="store_true")

    args = parser.parse_args()

    if (not args.quest) and (not args.quest_classic) and (not args.quest_translations) and (not args.npc) and (not args.npc_zone) and (not args.item) and (not args.object) and (not args.object_translations) and (not args.object_zone):
        parser.error("No spider selected")

    runner = Runner()

    run_for_retail = args.retail

    if args.quest:
        print("Running quest spider")
        runner.run_quest(run_for_retail)
    if args.quest_classic:
        print("Running quest spider for classic wow")
        runner.run_classic_quest()
    if args.quest_translations:
        print("Running quest spider for SoD translations")
        runner.run_quest_translations()
    if args.npc:
        print("Running npc spider")
        runner.run_npc(run_for_retail)
    if args.npc_zone:
        print("Running npc zone ID spider")
        runner.run_npc_zone_ids()
    if args.item:
        print("Running item spider")
        runner.run_item()
    if args.item_translations:
        print("Running item spider for translations")
        runner.run_item_translations()
    if args.object:
        print("Running object spider")
        runner.run_object(run_for_retail)
    if args.object_translations:
        print("Running object spider for translations")
        runner.run_object_translations()
    if args.object_zone:
        print("Running object zone ID spider")
        runner.run_object_zone_ids()
