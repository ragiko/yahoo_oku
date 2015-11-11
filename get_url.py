# -*- coding:utf-8 -*-

import requests
import re
import time
import os

pattern = re.compile(r'http://page\d*\.auctions\.yahoo\.co\.jp/jp/auction/\w*\d+') #\d+\.auctions\.yahoo\.co\.jp\/jp\/auction\/\w*\d+')
target_url = 'http://topic.auctions.yahoo.co.jp/promo/goodsh/sale/'
while(1):
    target_html = requests.get(target_url).text
    match_URL = re.findall(pattern, target_html)
    print  time.strftime("%H:%M:%S ") + str(len(match_URL))
    os.system('echo ' + '"' + time.strftime("%H:%M:%S ") + str(len(match_URL)) + '" >> python_log.txt') 
    # print target_html
    text = open("./links.txt", 'a')
    for i in range(len(match_URL)):
        text.write(match_URL[len(match_URL) - i - 1])
        text.write("\n")
    text.close()
    time.sleep(1)

