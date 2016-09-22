#! /bin/bash
tcpdump -i eth0 -n portrange $2 > $1
