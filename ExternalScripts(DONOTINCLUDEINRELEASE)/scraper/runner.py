from argparse import ArgumentParser, ArgumentTypeError
from logging import getLogger
from pathlib import Path

from scrapy.crawler import CrawlerProcess

from item.item_spider import ItemSpider
from item_drop.item_drop_spider import ItemDropSpider
from npc.npc_spider import NPCSpider
from npc.npc_zone_id_spider import NpcZoneIdSpider
from npc.translations.npc_translation_spider import NPCTranslationSpider
from object.object_spider import ObjectSpider
from object.translations.object_translation_spider import ObjectTranslationSpider
from object.object_zone_id_spider import ObjectZoneIdSpider
from quest.quest_spider import QuestSpider
from quest.classic.quest_spider import ClassicQuestSpider
from quest.sod_translations.quest_translation_spider import QuestTranslationSpiderSoD
from quest.translations.quest_translation_spider import QuestTranslationSpider

BASE_SETTINGS = {
    "LOG_LEVEL": "INFO",
    "FEED_EXPORT_ENCODING": "utf-8",
    "FEED_FORMAT": "json",
    "CONCURRENT_REQUESTS": 1,
    "DOWNLOAD_DELAY": 1,
    "RANDOMIZE_DOWNLOAD_DELAY": True,
    "COOKIES_ENABLED": False,
    "USER_AGENT": 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36'
}

def parse_expac_value(value):

    # This is used to convert non-numerical inputs into expansion levels.
    # Retail is 0 because it is always a moving target.

    EXPAC_STRINGS = {
        "retail": 0,
        "classic": 1,
        "era": 1,
        "tbc": 2,
        "wotlk": 3,
        "wrath": 3,
        "cata": 4,
        "mop": 5,
        "mists": 5,
        "wod": 6,
        # these are future examples, god forbid we reach bfa classic
        # these numbers just get passed to spiders; to add expansion support
        # to spiders, go to them and add cases for wowhead's url syntax
        "legion": 7,
        "bfa": 8,
        "sl": 9,
        "shadowlands": 9,
        "df": 10,
        "dragonflight": 10,
        "tww": 11,
        "warwithin": 11,
        "midnight": 12,
        "tlt": 13,
        "lasttitan": 13,
    }

    try:
        return int(value)
    except ValueError:
        pass

    normalized_value = value.lower()
    if normalized_value in EXPAC_STRINGS:
        return EXPAC_STRINGS[normalized_value]

    raise ArgumentTypeError(f"'{value}' is not a valid expansion ID or name.")

class Runner:

    def __init__(self) -> None:
        self.logger = getLogger(__name__)

    def run_quest(self, expac: int) -> None:
        Path("quest/quest_data.json").unlink(missing_ok=True)
        settings = {**BASE_SETTINGS, "FEED_URI": "quest/quest_data.json"}
        process = CrawlerProcess(settings=settings)
        process.crawl(QuestSpider, expac)
        process.start()

    def run_npc(self, expac: int) -> None:
        Path("npc/npc_data.json").unlink(missing_ok=True)
        settings = {**BASE_SETTINGS, "FEED_URI": "npc/npc_data.json"}
        process = CrawlerProcess(settings=settings)
        process.crawl(NPCSpider, expac)
        process.start()

    def run_npc_zone_ids(self, expac: int) -> None:
        Path("npc/npc_zone_id_data.json").unlink(missing_ok=True)
        settings = {**BASE_SETTINGS, "FEED_URI": "npc/npc_zone_id_data.json"}
        process = CrawlerProcess(settings=settings)
        process.crawl(NpcZoneIdSpider, expac)
        process.start()

    def run_item(self, expac: int) -> None:
        Path("item/item_data.json").unlink(missing_ok=True)
        settings = {**BASE_SETTINGS, "FEED_URI": "item/item_data.json"}
        process = CrawlerProcess(settings=settings)
        process.crawl(ItemSpider, expac)
        process.start()

    def run_item_drops(self, expac: int) -> None:
        Path("item_drop/item_drop_data.json").unlink(missing_ok=True)
        settings = {**BASE_SETTINGS, "FEED_URI": "item_drop/item_drop_data.json"}
        process = CrawlerProcess(settings=settings)
        process.crawl(ItemDropSpider, expac)
        process.start()

    def run_object(self, expac: int) -> None:
        Path("object/object_data.json").unlink(missing_ok=True)
        settings = {**BASE_SETTINGS, "FEED_URI": "object/object_data.json"}
        process = CrawlerProcess(settings=settings)
        process.crawl(ObjectSpider, expac)
        process.start()

    def run_object_zone_ids(self, expac: int) -> None:
        Path("object/object_zone_id_data.json").unlink(missing_ok=True)
        settings = {**BASE_SETTINGS, "FEED_URI": "object/object_zone_id_data.json"}
        process = CrawlerProcess(settings=settings)
        process.crawl(ObjectZoneIdSpider, expac)
        process.start()

    def run_npc_translations(self) -> None:
        Path("npc/translations/output").mkdir(parents=True, exist_ok=True)
        Path("npc/translations/output/scraped_data.json").unlink(missing_ok=True)
        settings = {**BASE_SETTINGS, "FEED_URI": "npc/translations/output/scraped_data.json"}
        process = CrawlerProcess(settings=settings)
        process.crawl(NPCTranslationSpider)
        process.start()

    def run_object_translations(self) -> None:
        Path("object/translations/output").mkdir(parents=True, exist_ok=True)
        Path("object/translations/output/scraped_data.json").unlink(missing_ok=True)
        settings = {**BASE_SETTINGS, "FEED_URI": "object/translations/output/scraped_data.json"}
        process = CrawlerProcess(settings=settings)
        process.crawl(ObjectTranslationSpider)
        process.start()

    def run_quest_translations(self) -> None:
        Path("quest/translations/output").mkdir(parents=True, exist_ok=True)
        Path("quest/translations/output/scraped_data.json").unlink(missing_ok=True)
        settings = {**BASE_SETTINGS, "FEED_URI": "quest/translations/output/scraped_data.json"}
        process = CrawlerProcess(settings=settings)
        process.crawl(QuestTranslationSpider)
        process.start()

    def run_quest_translations_sod(self) -> None:
        Path("quest/sod_translations/quest_data.json").unlink(missing_ok=True)
        settings = {**BASE_SETTINGS, "FEED_URI": "quest/sod_translations/quest_data.json"}
        process = CrawlerProcess(settings=settings)
        process.crawl(QuestTranslationSpiderSoD)
        process.start()


if __name__ == '__main__':
    parser = ArgumentParser()
    parser.add_argument("--quest", help="Run quest spider", action="store_true")
    parser.add_argument("--npc", help="Run npc spider", action="store_true")
    parser.add_argument("--npc-zone", help="Run npc zone IDs spider", action="store_true")
    parser.add_argument("--item", help="Run item spider", action="store_true")
    parser.add_argument("--item-drops", help="Run item drops spider", action="store_true")
    parser.add_argument("--object", help="Run object spider", action="store_true")
    parser.add_argument("--object-zone", help="Run object zone IDs spider", action="store_true")

    # parser.add_argument("--item-translations", help="Run item translation spider", action="store_true")
    # We don't seem to actually have an item translation spider, this argument was doing nothing?
    parser.add_argument("--npc-translations", help="Run npc translation spider", action="store_true")
    parser.add_argument("--object-translations", help="Run object translation spider", action="store_true")
    parser.add_argument("--quest-translations", help="Run quest translation spider", action="store_true")
    parser.add_argument("--quest-translations-sod", help="Run quest spider for SoD translations", action="store_true")

    parser.add_argument(
        "--expac","--expansion","-ex",
        help="Target expansion ID or name (e.g. 2 or 'tbc'). Defaults to 1 (classic era).",
        nargs='?',             # Allow 0 or 1 argument total
        const=1,               # Value used if flag is present but NO argument is given
        default=1,             # Value used if flag is NOT present at all
        type=parse_expac_value # Custom conversion logic
    )

    args = parser.parse_args()

    if (not args.quest) and (not args.npc) and (not args.npc_zone) and (not args.item) and (not args.item_drops) and (not args.object) and (not args.object_zone) and (
            not args.npc_translations) and (not args.object_translations) and (not args.quest_translations) and (not args.quest_translations_sod):
        parser.error("No spider selected")

    runner = Runner()

    if args.quest:
        print("Running quest spider at expansion level " + str(args.expac))
        runner.run_quest(args.expac)
    if args.npc:
        print("Running npc spider at expansion level " + str(args.expac))
        runner.run_npc(args.expac)
    if args.npc_zone:
        print("Running npc zone ID spider at expansion level " + str(args.expac))
        runner.run_npc_zone_ids(args.expac)
    if args.item:
        print("Running item spider at expansion level " + str(args.expac))
        runner.run_item(args.expac)
    if args.item_drops:
        print("Running item drop spider at expansion level " + str(args.expac))
        runner.run_item_drops(args.expac)
    if args.object:
        print("Running object spider at expansion level " + str(args.expac))
        runner.run_object(args.expac)
    if args.object_zone:
        print("Running object zone ID spider at expansion level " + str(args.expac))
        runner.run_object_zone_ids(args.expac)

    # Item translations are grapped from the ItemSparse client tables
    if args.npc_translations:
        print("Running npc translation spider")
        runner.run_npc_translations()
    if args.object_translations:
        print("Running object spider for translations")
        runner.run_object_translations()
    if args.quest_translations:
        print("Running quest translation spider")
        runner.run_quest_translations()
    if args.quest_translations_sod:
        print("Running quest spider for SoD translations")
        runner.run_quest_translations_sod()
