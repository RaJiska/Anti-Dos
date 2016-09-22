#! /bin/bash
while read -r line; do
  extractedLine=$(echo $line | grep -o -P '(?<=: ).*(?= to)')
  if [[ $(iptables -L INPUT -v -n | grep "$extractedLine") ]]; then
    echo "IP: $extractedLine already exists"
  else
    echo "$extractedLine"
  fi
done < <(cat ban.log)
