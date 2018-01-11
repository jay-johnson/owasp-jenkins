import os
import logging
from owasp_jenkins.log.setup_logging import setup_logging
from owasp_jenkins.log.build_logstash_formatter import build_logstash_formatter

setup_logging(logging.DEBUG)
log = logging.getLogger("testing-logstash-setup")
log.info("this was a test without the logstash handler enabled")
build_logstash_formatter(log)
log.info(("this message should show "
          "up in kibana - used logstash={}:{}")
         .format(os.getenv("LOGSTASH_HOST", "localhost"),
                 os.getenv("LOGSTASH_PORT", "5000").strip().lstrip()))
