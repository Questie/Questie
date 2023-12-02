from logging import getLogger
from pathlib import Path

from scrapy.crawler import CrawlerProcess

from spiders.quest_spider import QuestSpider


class Runner:

    def __init__(self) -> None:
        self.logger = getLogger(__name__)
        Path("quest_data.json").unlink(missing_ok=True)

    def run(self) -> None:
        process = CrawlerProcess(settings={
            "LOG_LEVEL": "INFO",
            "FEED_EXPORT_ENCODING": "utf-8",
            "FEED_FORMAT": "json",
            "CONCURRENT_REQUESTS": 32,
            "FEED_URI": "quest_data.json",
            "COOKIES_ENABLED": False
        })

        process.crawl(QuestSpider)

        process.start()


if __name__ == '__main__':
    runner = Runner()
    runner.run()
