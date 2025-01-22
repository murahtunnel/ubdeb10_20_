#!/bin/bash
clear

UUID=$(cat /proc/sys/kernel/random/uuid)
DOMAIN=$(cat /etc/xray/domain)
until [[ $USER_INPUT =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
clear

  echo -e "${BCYAN} ========================================== ${SOFTEX}"
  echo -e "${GREEN}          CREATE VLESS ACCOUNT              ${SOFTEX}"
  echo -e "${BCYAN} ========================================== ${SOFTEX}"
  echo -e "${GREEN} Input the name ( unik ) : ${SOFTEX}"
  read -p " >>  :  " USER_INPUT
  CLIENT_EXISTS=$(grep -w $USER_INPUT /etc/xray/config.json | wc -l)

  if [[ ${CLIENT_EXISTS} == '1' ]]; then
    clear
  echo -e "${BCYAN} ========================================== ${SOFTEX}"
  echo -e "${BEREM} for ${USER_INPUT} with name is already!    ${SOFTEX}"
  echo -e "${BCYAN} ========================================== ${SOFTEX}"
    exit 0
  fi
done

  echo -e "${GREEN} Expiry for days [ 0 for no limit ] ${SOFTEX}"
  read -p " >>  :  " EXPIRY_DATE
  
  echo -e "${GREEN} QUOTA for Limit [ 0 for no limit ] ${SOFTEX}" 
  read -p " >>  :  " QUOTA

  echo -e "${GREEN} Devic for Limit [ 0 for no limit ] ${SOFTEX}"
  read -p " >>  :  " LIMIT_IP
  
# DATE.
tgl=$(date -d "$EXPIRY_DATE days" +"%d")
bln=$(date -d "$EXPIRY_DATE days" +"%b")
thn=$(date -d "$EXPIRY_DATE days" +"%Y")
EXPIRY_OF="$tgl $bln, $thn"
tgl2=$(date +"%d")
bln2=$(date +"%b")
thn2=$(date +"%Y")
EXPIRY_ON="$tgl2 $bln2, $thn2"
exp=$(date -d "$EXPIRY_DATE days" +"%Y-%m-%d")

# Save Account to JSON
sed -i '/#LUNATIX-VLESS#$/a\#& '"$USER_INPUT $exp"'\
},{"id": "'""$UUID""'","email": "'""$USER_INPUT""'"' /etc/xray/config.json
sed -i '/#VLESS-GRPC#$/a\#& '"$USER_INPUT $exp"'\
},{"id": "'""$UUID""'","email": "'""$USER_INPUT""'"' /etc/xray/config.json

# Link Vless x-ray
LINK_TLS="vless://${UUID}@${DOMAIN}:443?path=/vless&security=tls&encryption=none&type=ws#${USER_INPUT}"
LINK_WS="vless://${UUID}@${DOMAIN}:80?path=/vless&encryption=none&type=ws#${USER_INPUT}"
LINK_GRPC="vless://${UUID}@${DOMAIN}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=${DOMAIN}#${USER_INPUT}"

# save Limit IP
if [[ $LIMIT_IP -gt 0 ]]; then
echo -e "$LIMIT_IP" > /etc/lunatic/vless/ip/$USER_INPUT
else
echo > /dev/null
fi

# Save Quota & Usage Quota
if [ -z ${QUOTA} ]; then
  QUOTA="0"
fi

# quota Extrak to Bytes
CALCULATE_QUOTA=$(echo "${QUOTA}" | sed 's/[^0-9]*//g')
USAGE_QUOTA=$((${CALCULATE_QUOTA} * 1024 * 1024 * 1024))

# Save Quota to Usage Quota User
if [ ! -e /etc/lunatic/vless ]; then
  mkdir -p /etc/lunatic/vless
fi

if [[ ${CALCULATE_QUOTA} != "0" ]]; then
  echo "${USAGE_QUOTA}" >/etc/lunatic/vless/usage/${USER_INPUT}
fi

# Check User ready or no!
DATADB=$(cat /etc/lunatic/vless/.vless.db | grep "^###" | grep -w "${USER_INPUT}" | awk '{print $2}')
if [[ "${DATADB}" != '' ]]; then
  sed -i "/\b${USER_INPUT}\b/d" /etc/lunatic/vless/.vless.db
fi

# Save account to DB
echo "### ${USER_INPUT} ${exp} ${UUID} ${QUOTA} ${LIMIT_IP}" >>/etc/lunatic/vless/.vless.db
clear

# Restart Service
systemctl restart xray
systemctl restart nginx

# openclash FORMATTED
cat >/var/www/html/vless-$USER_INPUT.txt <<-END
# Format Vless WS TLS
- name: Vless-$USER_INPUT-WS TLS
  server: ${DOMAIN}
  port: 443
  type: vless
  UUID: ${UUID}
  cipher: auto
  tls: true
  skip-cert-verify: true
  servername: ${DOMAIN}
  network: ws
  ws-opts:
    path: /vless
    headers:
      Host: ${DOMAIN}

# Format Vless WS Non TLS
- name: Vless-$USER_INPUT-WS (CDN) Non TLS
  server: ${DOMAIN}
  port: 80
  type: vless
  UUID: ${UUID}
  cipher: auto
  tls: false
  skip-cert-verify: false
  servername: ${DOMAIN}
  network: ws
  ws-opts:
    path: /vless
    headers:
      Host: ${DOMAIN}
  udp: true

# Format Vless gRPC (SNI)
- name: Vless-$USER_INPUT-gRPC (SNI)
  server: ${DOMAIN}
  port: 443
  type: vless
  UUID: ${UUID}
  cipher: auto
  tls: true
  skip-cert-verify: true
  servername: ${DOMAIN}
  network: grpc
  grpc-opts:
  grpc-mode: gun
    grpc-service-name: vless-grpc
END

cat > /etc/lunatic/vless/detail/$USER_INPUT.txt<<-END
==========================================
       INFORMATION VLESS ACCOUNT
==========================================
 Remarks     : ${USER_INPUT}
 Domain      : ${DOMAIN}
 User QUOTA  : ${QUOTA} GB
 User Ip     : ${LIMIT_IP} IP
 User ID     : ${UUID}
==========================================
 ports:
 -ws
 80,8880,8080,2082
 -tls
 443,8443,2095
 -gRPC
 443,8443,2095 
==========================================
 Link TLS    : ${LINK_TLS}
========================================== 
 Link NTLS   : ${LINK_WS}
========================================== 
 Link GRPC   : ${LINK_GRPC}
==========================================
 OpenClash   : https://${DOMAIN}:81/vless-$USER_INPUT.txt
==========================================
 Expiry in   : $EXPIRY_DATE minutes
 Expiry on   : $EXPIRY_ON
 Expiry of   : $EXPIRY_OF
========================================== 
END

# print
cat /etc/lunatic/vless/detail/$USER_INPUT.txt

