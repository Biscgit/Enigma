__all__ = ["configure_logger"]

import logging
import sys


def configure_logger(no_stdout=False):
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)

    for h in logger.handlers:
        logger.removeHandler(h)

    if not no_stdout:
        stream_handler = logging.StreamHandler(sys.stdout)
        log_formatter = logging.Formatter(
            "%(asctime)s [%(levelname)s] %(name)s: %(message)s"
        )
        stream_handler.setFormatter(log_formatter)
        logger.addHandler(stream_handler)
