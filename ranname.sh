#!/bin/bash
head -c 20 /dev/random | base64 | sed -e 's/\///g' | sed -e 's/=//g'
