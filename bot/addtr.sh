#!/bin/bash
clear

# beck
source /var/lib/LT/ipvps.conf
if [[ "$IP" = "" ]]; then
DOMAIN=$(cat /etc/xray/domain)
else
DOMAIN=$IP
fi
clear

# Checking User Ready or No!
until [[ $USER_INPUT =~ ^[a-zA-Z0-9_]+$ && ${USER_INPUT_EXISTS} == '0' ]]; do

# color validity2
  echo -e "\e[97;1m ================================================== \e[0m"
  echo -e "\e[97;1m              CREATE TITLE SHADOWSOCKS              \e[0m"
  echo -e "\e[97;1m ================================================== \e[0m"
  echo -e ""
  echo -e "\e[97;1m             Just Input a Number from                \e[0m"
  echo -e "\e[0;32m                    limit IP                         \e[0m"
  echo -e "\e[0;32m                    limit Quota                         \e[0m"  
  echo -e "\e[0;32m                    limit day                        \e[0m"
  echo -e "\e[0;33m                 0 \e[97;1mfor \e[31mno \e[97;1mlimit\e[0m"
  echo -e "\e[97;1m ================================================== \e[0m"

        read -rp " USERNAME    :  " -e USER_INPUT
		USER_INPUT_EXISTS=$(grep -w $USER_INPUT /etc/xray/config.json | wc -l)
		if [[ ${USER_INPUT_EXISTS} == '1' ]]; then
        clear
        echo -e "\e[31m A client with the specified name was already!\e[0m"
        sleep 2 && TITLE_INPUT			
		fi
	done

# GETTING NEW UUID
UUID=$(cat /proc/sys/kernel/random/uuid)

read -p " EXPIRY DAYS  :  " EXPIRY_DATE
read -p " LIMIT QUOTA  :  " QUOTA
read -p " LIMIT DEVIC  :  " LIMIT_IP

# DATE.
tgl=$(date -d "$EXPIRY_DATE days" +"%d")
bln=$(date -d "$EXPIRY_DATE days" +"%b")
thn=$(date -d "$EXPIRY_DATE days" +"%Y")
EXPIRED_ACCOUNT="$tgl $bln, $thn"
tgl2=$(date +"%d")
bln2=$(date +"%b")
thn2=$(date +"%Y")
DATE_EXP="$tgl2 $bln2, $thn2"
exp=`date -d "$EXPIRY_DATE days" +"%Y-%m-%d"`

# Save Account to JSON
sed -i '/#LUNATIX-TROJAN#$/a\#! '"$USER_INPUT $exp"'\
},{"password": "'""$UUID""'","email": "'""$USER_INPUT""'"' /etc/xray/config.json
sed -i '/#TROJAN-GRPC#$/a\#! '"$USER_INPUT $exp"'\
},{"password": "'""$UUID""'","email": "'""$USER_INPUT""'"' /etc/xray/config.json

# Link Trojan Akun
systemctl restart xray
GRPC_LINK="trojan://${UUID}@${DOMAIN}:443?mode=gun&security=tls&type=grpc&serviceName=trojan-grpc&sni=bug.com#${USER_INPUT}"
WS_LINK="trojan://${UUID}@bugkamu.com:443?path=%2Ftrojan-ws&security=tls&host=${DOMAIN}&type=ws&sni=${DOMAIN}#${USER_INPUT}"
TLS_LINK="trojan://${UUID}@${DOMAIN}:80?path=%2Ftrojan-ws&security=none&host=${DOMAIN}&type=ws#${USER_INPUT}"

# Restart service
systemctl restart xray
systemctl reload nginx
service cron restart

# Openclash Formatted
cat >/var/www/html/trojan-$USER_INPUT.txt <<-END
================================
          OPENCLASH
================================
# Format Trojan GO/WS #
- name: Trojan-$USER_INPUT-GO/WS
  server: ${DOMAIN}
  port: 443
  type: trojan
  password: ${UUID}
  network: ws
  sni: ${DOMAIN}
  skip-cert-verify: true
  udp: true
  ws-opts:
    path: /trojan-ws
    headers:
        Host: ${DOMAIN}
        
# Format Trojan gRPC #
- name: Trojan-$USER_INPUT-gRPC
  type: trojan
  server: ${DOMAIN}
  port: 443
  password: ${UUID}
  udp: true
  sni: ${DOMAIN}
  skip-cert-verify: true
  network: grpc
  grpc-opts:
    grpc-service-name: trojan-grpc
END

# Buat Dir
if [ ! -e /etc/lunatic/trojan ]; then
  mkdir -p /etc/lunatic/trojan
fi

# Save Limit IP
if [[ $LIMIT_IP -gt 0 ]]; then
echo -e "$LIMIT_IP" > /etc/lunatic/trojan/ip/$USER_INPUT
else
echo > /dev/null
fi

# validity or no ? Input in QUOTA User
if [ -z ${QUOTA} ]; then
  QUOTA="0"
fi

# Calculate QUOTA To Bytes Type
FORMATTED_QUOTA=$(echo "${QUOTA}" | sed 's/[^0-9]*//g')
USAGE_QUOTA=$((${FORMATTED_QUOTA} * 1024 * 1024 * 1024))

# Save Usage for limit QUOTA
if [[ ${FORMATTED_QUOTA} != "0" ]]; then
  echo "${USAGE_QUOTA}" >/etc/lunatic/trojan/usage/${USER_INPUT}
fi

# Save Account to DB
DATADB=$(cat /etc/lunatic/trojan/.trojan.db | grep "^###" | grep -w "${USER_INPUT}" | awk '{print $2}')
if [[ "${DATADB}" != '' ]]; then
  sed -i "/\b${USER_INPUT}\b/d" /etc/lunatic/trojan/.trojan.db
fi
echo "### ${USER_INPUT} ${EXPIRY_DATE} ${UUID} ${QUOTA} ${LIMIT_IP}" >>/etc/lunatic/trojan/.trojan.db

cat > /etc/lunatic/trojan/detail/$USER_INPUT.txt<<-END
=========================================
         ACCOUNT XRAY TROJAN 
=========================================
 Remarks          : ${USER_INPUT}
 Host/IP          : ${DOMAIN}
 User QUOTA       : ${QUOTA} GB
 User Ip          : ${LIMIT_IP} IP
 Key              : ${UUID}
=========================================
ports: 
 - ws 
 80,8880,8080,2082
 - gRPC,TLS
 443,2095,8443
=========================================
 ws link         : ${WS_LINK}
=========================================
 tls link        : ${TLS_LINK}
=========================================
 gRPC link       : ${GRPC_LINK}
=========================================
 OpenClash       : https://${DOMAIN}:81/trojan-$USER_INPUT.txt
=========================================
 Aktif Selama    : $EXPIRY_DATE days
 Dibuat Pada     : $DATE_EXP
 Berakhir Pada   : $EXPIRED_ACCOUNT
=========================================
END
# clear screen
clear
# PRINT ACCOUNT
cat /etc/lunatic/trojan/detail/$USER_INPUT.txt

