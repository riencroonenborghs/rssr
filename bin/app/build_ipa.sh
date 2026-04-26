#!/bin/bash

cd rssreader_app

flutter build ipa --export-method development --dart-define-from-file=.env.prod.json 2>&1

cd ..