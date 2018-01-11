import os
import logging
import logging.config
import logstash.formatter


def build_logstash_formatter(log):
    try:

        class WrappedLogstashFormatter(
                    logstash.formatter.LogstashFormatterVersion1):

            def set_fields(self, add_fields_dict):
                self.fields_to_add = add_fields_dict

            def format(self, msg):

                full_msg = {
                    "@timestamp": self.format_timestamp(msg.created),
                    "@version": 1,
                    "@env": os.getenv(
                                    "ENV_NAME",
                                    "dev"),
                    "@message": msg.getMessage(),
                    "@fields": {"logger": os.getenv(
                                    "APP_NAME",
                                    "owasp-jenkins")},
                    "host": self.host,
                    "path": msg.pathname,
                    "tags": self.tags,
                    "type": "owasp",
                    "level": msg.levelname,
                    "logger_name": msg.name}

                full_msg.update(self.get_extra_fields(msg))

                if hasattr(msg, 'exec_info'):
                    full_msg.update(self.get_debug_fields)

                full_msg.update(self.fields_to_add)

                return self.serialize(full_msg)
        # end of WrappedLogstashFormatter

        fields_to_add = {"@env": "dev"}
        tags = os.getenv("LOGSTASH_TAGS", "dev").split(",")
        lgstsh_formatter = WrappedLogstashFormatter("wpdlsh", tags, False)
        lgstsh_formatter.set_fields(fields_to_add)
        found_handler = False

        for i in logging.root.handlers:
            if "logstash" in str(i.__class__.__name__).lower():
                found_handler = True
                i.formatter = lgstsh_formatter

        if not found_handler:
            new_handler = logstash.TCPLogstashHandler(
                            os.getenv(
                                    "LOGSTASH_HOST", "localhost"),
                            port=int(os.getenv(
                                    "LOGSTASH_PORT", "5000").strip().lstrip()),
                            version=1)
            new_handler.formatter = lgstsh_formatter
            log.handlers.append(new_handler)

        log.debug("logstash ready")

    except Exception as e:
        print(("Failed to build_logstash_formatter with ex={}")
              .format(e))

# end of build_logstash_formatter
