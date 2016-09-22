#  File: anti-dos.sh
#  Author: Ra'Jiska
#  Last Edit: 22/09/16
#
#  Description:
#    Blocks IPs flooding the network on given ports.

#! /bin/bash

if [ -z $1 ];
then
  exit
else
  if [ -z $2 ]; then exit; else echo "Starting..."; fi
fi

FILE=$1
PORT=$2
SCREEN_NAME="TCPDUMPSCAN"

# Config: adapt to your needs
MAX_MSG=800     # Sample message Number
DETECT_MSG=180  # Number of messages from same IPs from sample to detect & block
WAIT_TIME=0.3   # Sleep time before taking another sample

OWN_IP=$(ifconfig | grep "inet addr" | grep -v "127.0.0.1" | awk {'print $2'} | cut -c6-)

#cp /dev/null $FILE

while :
do
  IP_ARRAY=()
  IP_COUNT=()

  screen -dmS $SCREEN_NAME bash -c "./log-traffic.sh $FILE $PORT"
  echo "screen -dmS $SCREEN_NAME bash -c \"./log-traffic.sh $FILE $PORT\""
  sleep 0.5
  screen -X -S $SCREEN_NAME quit
  found=false

  while read -r line; do
    extracted_ip=$(echo $line | grep -oP '(?<=IP ).*(?=\.[0-9]* >)')
    #echo ":$extracted_ip:"

    # Check array to check if IP exists
    for i in "${!IP_ARRAY[@]}"
    do

      # If IP exists: increment IP_COUNT on the right index & break
      if [[ "${IP_ARRAY[$i]}" == $extracted_ip ]];
      then
        IP_COUNT[$i]=$((${IP_COUNT[$i]} + 1))
        #echo "IP_COUNT=${IP_COUNT[@]}"
        #echo "IP_ARRAY=${IP_ARRAY[@]}"
        found=true
        break
      fi

    done

    # If IP was not found, push back IP_ARRAY & IP_COUNT with the IP found
    if [ $found == false ]; then
      IP_ARRAY+=( $extracted_ip )
      IP_COUNT+=( 1 )
    fi

  done < <(cat $FILE | head -n $MAX_MSG)

 # echo "IP_ARRAY=${IP_ARRAY[@]}"

  for i in "${!IP_ARRAY[@]}"
  do
    if [ ${IP_ARRAY[$i]} != $OWN_IP ]; then
      echo "DEBUG: ${IP_ARRAY[$i]} - ${IP_COUNT[$i]} / $MAX_MSG"
      if (( ${IP_COUNT[$i]} >= $DETECT_MSG )); then
        echo "${IP_ARRAY[$i]} detected"
        if [[ $(iptables -L INPUT -v -n | grep "${IP_ARRAY[$i]}") ]]; then
          echo "" > /dev/null
        else
          echo "IP TO BE BANNED !!!"
          curr_date=$(date)
          echo "$curr_date: ${IP_ARRAY[$i]} to be banned (index=$i ; val=${IP_COUNT[$i]} / $MAX_MSG)" >> ban.log
          iptables -A INPUT -s ${IP_ARRAY[$i]} -j DROP && iptables-save
        fi
#      else
#       echo "No Ban With: ${IP_COUNT[$i]}"
      fi
    fi
  done

  unset IP_ARRAY
  unset IP_COUNT

  cp /dev/null $FILE
  # DISABLE FOR PERMANENT MITIGATION
  sleep $WAIT_TIME
done
