#!/usr/bin/env python
# -*- coding:utf-8 -*-

import sys
reload(sys)
sys.setdefaultencoding('utf8')
sys.dont_write_bytecode = True

import time
import json
import requests

# PixivPy-3.x: pip install pixivpy
from pixivpy3 import *

BASE_FIELDS = {
  "id": None,
  "title": None,
  "caption": None,
  "type": None,
  "age_limit": None,
  "tags": None,
  "page_count": None,
  "created_time": None,
  "image_urls": {
    "large": None,
    "px_128x128": None,
    "px_480mw": None,
  },
  "stats": {
    "commented_count": None,
    "favorited_count": {
      "private": None,
      "public": None,
    },
    "score": None,
    "scored_count": None,
    "views_count": None,
  },
  "height": None,
  "width": None,
  "user": {
    "account": None,
    "id": None,
    "name": None,
  },
}

def dict_with_fields(source, fields=BASE_FIELDS):
  result = JsonDict()
  print source
  for k,v in fields.items():
    if type(v) == dict:
      print k, source[k], v
      sub_dict = dict_with_fields(source.get(k, None), fields=v)
      print sub_dict
      result[k] = sub_dict
    else:
      print k, source[k]
      result[k] = source.get(k, None)
  return result

def mapping():
  query = json.dumps({
    "properties" : {
      "id": {"type": "long"},
      "title": {"type": "string", "index": "analyzed"},
      "caption": {"type": "string", "index": "analyzed"},
      "type": {"type": "string", "index": "not_analyzed"},
      "age_limit": {"type": "string", "index": "not_analyzed"},
      "tags": {"type": "string"},
      "page_count": {"type" : "integer"},
      "created_time": {"type": "date", "format" : "YYYY-MM-dd HH:mm:ss"},
      "image_urls": {
        "properties": {
          "large": {"type": "string","index": "not_analyzed"},
          "px_128x128": {"type": "string","index": "not_analyzed"},
          "px_480mw": {"type": "string","index": "not_analyzed"}
        }
      },
      "stats": {
        "properties": {
          "commented_count": {"type": "integer"},
          "favorited_count": {
            "properties": {
              "private": {"type": "integer"},
              "public": {"type": "integer"}
            }
          },
          "score": {"type": "integer"},
          "scored_count": {"type": "integer"},
          "views_count": {"type": "integer"}
        }
      },
      "height": {"type": "integer"},
      "width": {"type": "integer"},
      "user": {
        "properties": {
          "account": {"type": "string"},
          "id": {"type": "long"},
          "name": {"type": "string"}
        }
      }
    }
  })
  return requests.post("http://localhost:9200/users/_mapping/illust", data=query).text

def add_illusts(illusts):
  query = ""
  for ori_illust in illusts:
    illust = dict_with_fields(ori_illust)
    query += json.dumps({"index": {"_id": illust.id}}) + "\n"
    query += json.dumps(illust) + "\n"

  print query
  return requests.post("http://localhost:9200/users/illust/_bulk", data=query).text

def index():
  api = PixivAPI()
  api.login("username", "password")

  for page in [1]:
    print page
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
  #mapping()
  index()
  #search()

if __name__ == '__main__':
  main()
