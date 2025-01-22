#!/bin/bash
clear

UUID=$(cat /proc/sys/kernel/random/uuid)
DOMAIN=$(cat /etc/xray/domain)
until [[ $USER_INPUT =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
clear

  echo -e "\e[97;1m ========================================== ${SOFTEX}"
  echo -e "\e[97;1m          CREATE VMESS ACCOUNT              ${SOFTEX}"
  echo -e "\e[97;1m ========================================== ${SOFTEX}"
  echo -e "\e[97;1m Input the name ( unik ) : ${SOFTEX}"
  read -p " >>  :  " USER_INPUT
  CLIENT_EXISTS=$(grep -w $USER_INPUT /etc/xray/config.json | wc -l)

  if [[ ${CLIENT_EXISTS} == '1' ]]; then
    clear
  echo -e "\e[97;1m ========================================== ${SOFTEX}"
  echo -e "${BEREM} for ${USER_INPUT} with name is already!    ${SOFTEX}"
  echo -e "\e[97;1m ========================================== ${SOFTEX}"
    exit 0
  fi
done

  echo -e "\e[97;1m Expiry for days [ 0 for no limit ] ${SOFTEX}"
  read -p " >>  :  " EXPIRY_DATE
  
  echo -e "\e[97;1m QUOTA for Limit [ 0 for no limit ] ${SOFTEX}" 
  read -p " >>  :  " QUOTA

  echo -e "\e[97;1m Devic for Limit [ 0 for no limit ] ${SOFTEX}"
  read -p " >>  :  " LIMIT_IP
  
  

tgl=$(date -d "$EXPIRY_DATE days" +"%d")
bln=$(date -d "$EXPIRY_DATE days" +"%b")
thn=$(date -d "$EXPIRY_DATE days" +"%Y")
EXPIRY_OF="$tgl $bln, $thn"
tgl2=$(date +"%d")
bln2=$(date +"%b")
thn2=$(date +"%Y")
EXPIRY_ON="$tgl2 $bln2, $thn2"
exp=`date -d "$EXPIRY_DATE days" +"%Y-%m-%d"`

# save account to json
sed -i '/#LUNATIX-VMESS#$/a\### '"$USER_INPUT $exp"'\
},{"id": "'""$UUID""'","alterId": '"0"',"email": "'""$USER_INPUT""'"' /etc/xray/config.json
exp=`date -d "$EXPIRY_DATE days" +"%Y-%m-%d"`
sed -i '/#VMESS-GRPC#$/a\### '"$USER_INPUT $exp"'\
},{"id": "'""$UUID""'","alterId": '"0"',"email": "'""$USER_INPUT""'"' /etc/xray/config.json

asu=`cat<<EOF
      {
      "v": "2",
      "ps": "${USER_INPUT}",
      "add": "${DOMAIN}",
      "port": "443",
      "id": "${UUID}",
      "aid": "0",
      "net": "ws",
      "path": "/vmess",
      "type": "none",
      "host": "${DOMAIN}",
      "tls": "tls"
}
EOF`
ask=`cat<<EOF
      {
      "v": "2",
      "ps": "${USER_INPUT}",
      "add": "${DOMAIN}",
      "port": "80",
      "id": "${UUID}",
      "aid": "0",
      "net": "ws",
      "path": "/vmess",
      "type": "none",
      "host": "${DOMAIN}",
      "tls": "none"
}
EOF`
grpc=`cat<<EOF
      {
      "v": "2",
      "ps": "${USER_INPUT}",
      "add": "${DOMAIN}",
      "port": "443",
      "id": "${UUID}",
      "aid": "0",
      "net": "grpc",
      "path": "vmess-grpc",
      "type": "none",
      "host": "${DOMAIN}",
      "tls": "tls"
}
EOF`

# encrypt vmess ti base64
vmess_base641=$( base64 -w 0 <<< $vmess_json1)
vmess_base642=$( base64 -w 0 <<< $vmess_json2)
vmess_base643=$( base64 -w 0 <<< $vmess_json3)

# vmess link
TLS_LINK="vmess://$(echo $asu | base64 -w 0)"
WS_LINK="vmess://$(echo $ask | base64 -w 0)"
GRPC_LINK="vmess://$(echo $grpc | base64 -w 0)"

# restart xray
systemctl restart xray > /dev/null 2>&1
service cron restart > /dev/null 2>&1


cat >/var/www/html/vmess-$USER_INPUT.txt <<-END
# Format Vmess WS TLS
- name: Vmess-$USER_INPUT-WS TLS
  type: vmess
  server: ${DOMAIN}
  port: 443
  UUID: ${UUID}
  alterId: 0
  cipher: auto
  udp: true
  tls: true
  skip-cert-verify: true
  servername: ${DOMAIN}
  network: ws
  ws-opts:
    path: /vmess
    headers:
      Host: ${DOMAIN}

# Format Vmess WS Non TLS
- name: Vmess-$USER_INPUT-WS Non TLS
  type: vmess
  server: ${DOMAIN}
  port: 80
  UUID: ${UUID}
  alterId: 0
  cipher: auto
  udp: true
  tls: false
  skip-cert-verify: false
  servername: ${DOMAIN}
  network: ws
  ws-opts:
    path: /vmess
    headers:
      Host: ${DOMAIN}

# Format Vmess gRPC
- name: Vmess-$USER_INPUT-gRPC (SNI)
  server: ${DOMAIN}
  port: 443
  type: vmess
  UUID: ${UUID}
  alterId: 0
  cipher: auto
  network: grpc
  tls: true
  servername: ${DOMAIN}
  skip-cert-verify: true
  grpc-opts:
    grpc-service-name: vmess-grpc
END


if [ ! -e /etc/lunatic/vmess ]; then
  mkdir -p /etc/lunati/vmess
fi

# checking limit ip or no!
if [[ $LIMIT_IP -gt 0 ]]; then
# save limit IP
echo -e "$LIMIT_IP" > /etc/lunatic/vmess/ip/$USER_INPUT
else
echo > /dev/null
fi

# Checking quota limit or no!
if [ -z ${QUOTA} ]; then
  QUOTA="0"
fi

# Calculate quota to bytes.
FORMATTED_QUOTA=$(echo "${QUOTA}" | sed 's/[^0-9]*//g')
USAGE_QUOTA=$((${FORMATTED_QUOTA} * 1024 * 1024 * 1024))

# save quota to usage user.
if [[ ${FORMATTED_QUOTA} != "0" ]]; then
  echo "${USAGE_QUOTA}" >/etc/lunatic/vmess/usage/${USER_INPUT}
fi

# Checking account ready or no!
DATADB=$(cat /etc/lunatic/vmess/.vmess.db | grep "^###" | grep -w "${USER_INPUT}" | awk '{print $2}')
if [[ "${DATADB}" != '' ]]; then
  sed -i "/\b${USER_INPUT}\b/d" /etc/lunatic/vmess/.vmess.db
fi

# save account to DB
echo "### ${USER_INPUT} ${exp} ${UUID} ${QUOTA} ${LIMIT_IP}" >>/etc/lunatic/vmess/.vmess.db
clear

cat > /etc/lunatic/vmess/detail/$USER_INPUT.txt<<-END
==========================================
      INFORMATION VMESS ACCOUNT
==========================================
 Remarks     : ${USER_INPUT}
 Domain      : ${DOMAIN}
 User QUOTA  : ${QUOTA} GB
 User Ip     : ${LIMIT_IP} IP
 Uuid        : ${UUID}
==========================================
 ports:
 -ws
 80,8880,8080,2082
 -tls & gRPC
 443,8443,2095,143 
==========================================
 TLS LINK    : ${TLS_LINK}
==========================================
 WS LINK     : ${WS_LINK}
==========================================
 gRPC LINK   : ${GRPC_LINK}
==========================================
 OpenClash   : https://${DOMAIN}:81/vmess-$USER_INPUT.txt
==========================================
 Expiry in   : $EXPIRY_DATE days
 Expiry on   : $EXPIRY_ON
 Expiry of   : $EXPIRY_OF
==========================================
END

# print
cat /etc/lunatic/vmess/detail/$USER_INPUT.txt

