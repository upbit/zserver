#!/usr/bin/env python
# -*- coding:utf-8 -*-

import sys
reload(sys)
sys.setdefaultencoding('utf8')
sys.dont_write_bytecode = True

import time
import json
import requests

sys.path.insert(0, 'pixivpy3.zip')
from pixivpy3 import *

def add_illusts(illusts):
  query = ""
  for illust in illusts:
    query += json.dumps({"index": {"_id": illust.id}}) + "\n"
    query += json.dumps(illust) + "\n"
  return requests.post("http://localhost:9200/users/illust/_bulk", data=query).text

def index():
  api = PixivAPI()
  api.login("username", "password")

  for page in [1,2,3]:
    illusts = api.users_works(1184799, page=page).response
    print add_illusts(illusts)
    time.sleep(0.5)

def query_tags(tag_text, _from=0, size=30):
  query = json.dumps({
    "from": _from,
    "size": size,
    "min_score": 1.0,
    "query": {
        "match_phrase": {
            "tags": tag_text
        }
    }
  })
  response = requests.post("http://localhost:9200/users/illust/_search", data=query).text
  return PixivAPI().parse_json(response).hits.hits

def query_users_favcount(_from=0, size=30):
  query = json.dumps({
    "from": _from,
    "size": size,
    "query": {
      "regexp": {
        "tags": "[1-9]0{2,9}users"
      }
    }
  })
  response = requests.post("http://localhost:9200/users/illust/_search", data=query).text
  return PixivAPI().parse_json(response).hits.hits

def search():
  # tags match_phrase
  for doc in query_tags("尻神様"):
    illust = doc._source
    print "%s [%s]" % (illust.title, ",".join(illust.tags))

  print "-------------------------------------------------"

  # *users入り
  for doc in query_users_favcount():
    illust = doc._source
    print "%s [%s]" % (illust.title, ",".join([tag for tag in illust.tags if "users" in tag]))

def main():
  index()
  search()

if __name__ == '__main__':
  main()
