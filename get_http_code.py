#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import urllib
import socket

def get_status(url):
    socket.setdefaulttimeout(2)
    sys.stderr = None
    res=urllib.urlopen(url)
    page_status=res.getcode()
    return page_status

def main():
    url=sys.argv[1]
    page_status=get_status(url)
    print page_status

if __name__=="__main__":
    main()
