rm -rf /tmp/$(hostname)_server_info.txt
echo "
---/etc/redhat-release---" >> /tmp/$(hostname)_server_info.txt
cat /etc/redhat-release >> /tmp/$(hostname)_server_info.txt
echo "
---cat /proc/meminfo---" >> /tmp/$(hostname)_server_info.txt
cat /proc/meminfo >> /tmp/$(hostname)_server_info.txt
echo "
---lscpu---" >> /tmp/$(hostname)_server_info.txt
lscpu >> /tmp/$(hostname)_server_info.txt
echo "
---/sbin/ifconfig---" >>/tmp/$(hostname)_server_info.txt
/sbin/ifconfig >> /tmp/$(hostname)_server_info.txt
echo "
---mount---" >>/tmp/$(hostname)_server_info.txt
mount >> /tmp/$(hostname)_server_info.txt
echo "
---df-p---" >> /tmp/$(hostname)_server_info.txt
df -Ph | awk '{printf "%-30s %10s %6s %6s %4s %s\n",$1,$2,$3,$4,$5,$6}' >> /tmp/$(hostname)_server_info.txt
echo "
---ls-la---" >> /tmp/$(hostname)_server_info.txt  && ls -la / | grep '^d' | awk '{printf "%-20s %-12s %10s %s\n",$9,$1,$3,$4}' >> /tmp/$(hostname)_server_info.txt
echo "
---id <sidadm>---" >>/tmp/$(hostname)_server_info.txt
id er2adm >> /tmp/$(hostname)_server_info.txt