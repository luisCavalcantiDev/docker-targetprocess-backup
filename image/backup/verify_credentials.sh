#!/bin/bash

if [ -z "$TP_USER" ]; then
	echo "TP_USER not set, please set it in ./credentials.sh"
  exit 1
fi
if [ -z "$TP_PASSWORD" ]; then
	echo "TP_PASSWORD not set, please set it in ./credentials.sh"
  exit 1
fi
if [[ "$TP_PASSWORD" == "TODO" ]]; then
	echo "TP_PASSWORD not set, please set it in ./credentials.sh"
  exit 1
fi
if [ -z "$TP_DOMAIN" ]; then
	echo "TP_DOMAIN not set, please set it in ./credentials.sh"
  exit 1
fi
