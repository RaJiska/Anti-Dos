# Anti Dos
Aims to prevent basic DoS attacks by analyzing the flow of ingoing packets and blocking IP address of a client if it sends too many packets within a given amount of time.

# Usage
Scan Port 22
```
./anti-dos.sh .tmp_ip 22
```

Scan Port Range 1000 to 2000
```
./anti-dos.sh .tmp_ip 1000-2000
```
