# Docker cURL image

Simple minimal Alpine image with cURL installed. 

## Usage

```bash
# Trigger your wordpress cron
docker run --rm -it deardooley/curl http://example.wordpress.com/wp-cron.php

# Perform heartbeat
docker run --rm -it -v $(pwd)/config:/data deardooley/curl -XPOST -F /data/config.json http://requestbin.com/abcde?action=heartbeat
```
