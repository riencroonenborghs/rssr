#!/bin/bash

cd rssreader_app

flutter build ipa --export-method development 2>&1

cd ..