__all__ = ["configure_logger"]

import logging
import sys


def configure_logger():
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    stream_handler = logging.StreamHandler(sys.stdout)
    log_formatter = logging.Formatter(
        "%(asctime)s [%(levelname)s] %(name)s: %(message)s"
    )
    stream_handler.setFormatter(log_formatter)

    for h in logger.handlers:
        logger.removeHandler(h)

    logger.addHandler(stream_handler)
