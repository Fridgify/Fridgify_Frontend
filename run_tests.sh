#!/bin/bash
cd tools/bin

echo no | ./avdmanager create avd --force --name testAVD --abi google_apis/x86_64 --package 'system-images;android-23;google_apis;x86_64'
