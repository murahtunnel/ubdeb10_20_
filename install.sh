#!/bin/bash

rm -f $0

apt update
apt install curl -y
apt install wget -y
apt install jq -y

NC='\033[0m'
rbg='\033[41;37m'
r='\033[1;91m'
g='\033[1;92m'
y='\033[1;93m'
u='\033[0;35m'
c='\033[0;96m'
w='\033[1;97m'

if [ "${EUID}" -ne 0 ]; then
echo "${r}You need to run this script as root${NC}"
sleep 2
exit 0
fi

if [[ ! -f /root/.isp ]]; then
curl -sS ipinfo.io/org?token=7a814b6263b02c > /root/.isp
fi
if [[ ! -f /root/.city ]]; then
curl -sS ipinfo.io/city?token=7a814b6263b02c > /root/.city
fi
if [[ ! -f /root/.myip ]]; then
curl -sS ipv4.icanhazip.com > /root/.myip
fi

export IP=$(cat /root/.myip);
export ISP=$(cat /root/.isp);
export CITY=$(cat /root/.city);
source /etc/os-release

function lane_atas() {
echo -e "${c}┌──────────────────────────────────────────┐${NC}"
}
function lane_bawah() {
echo -e "${c}└──────────────────────────────────────────┘${NC}"
}

apt update
data_server=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
date_list=$(date +"%Y-%m-%d" -d "$data_server")
url_izin="https://raw.githubusercontent.com/murahtunnel/vps_access/main/ip"
client=$(curl -sS $url_izin | grep $IP | awk '{print $2}')
exp=$(curl -sS $url_izin | grep $IP | awk '{print $3}')
today=`date -d "0 days" +"%Y-%m-%d"`
time=$(printf '%(%H:%M:%S)T')
date=$(date +'%d-%m-%Y')
d1=$(date -d "$exp" +%s)
d2=$(date -d "$today" +%s)
certifacate=$(((d1 - d2) / 86400))
checking_sc() {
  useexp=$(curl -s $url_izin | grep $IP | awk '{print $3}')
  if [[ $date_list < $useexp ]]; then
    echo -ne
  else
    clear
    echo -e "\033[96m============================================\033[0m"
    echo -e "\033[44;37m           NotAllowed Autoscript            \033[0m"    
    echo -e "\033[96m============================================\033[0m"
    echo -e "\e[95;1m buy / sewa AutoScript installer VPS \e[0m"
    echo -e "\033[96m============================================\033[0m"
    echo -e "\033[96m============================================\033[0m"    
    echo -e "\e[96;1m   1 IP        : Rp.10.000   \e[0m"
    echo -e "\e[96;1m   2 IP        : Rp.15.000   \e[0m"   
    echo -e "\e[96;1m   7 IP        : Rp.40.000   \e[0m"
    echo -e "\e[96;1m   Unli IP     : Rp.150.000  \e[0m"
    echo -e "\e[97;1m   open source : Rp.400.000  \e[0m"       
    echo -e ""
    echo -e "\033[34m Contack WA/TLP: 083197765857 \033[0m"
    echo -e "\033[96m============================================\033[0m"
    exit 0
  fi
}
checking_sc

if [[ "$( uname -m | awk '{print $1}' )" == "x86_64" ]]; then
    echo -ne
else
    echo -e "${r} Your Architecture Is Not Supported ( ${y}$( uname -m )${NC} )"
    exit 1
fi

if [[ ${ID} == "ubuntu" || ${ID} == "debian" ]]; then
    echo -ne
else
    echo -e " ${r}This Script only Support for OS"
    echo -e ""
    echo -e " - ${y}Ubuntu 20.04${NC}"
    echo -e " - ${y}Ubuntu 21.04${NC}"
    echo -e " - ${y}Ubuntu 22.04${NC}"
    echo -e " - ${y}Ubuntu 23.04${NC}"
    echo -e " - ${y}Ubuntu 24.04${NC}"
    echo ""
    echo -e " - ${y}Debian 10${NC}"
    echo -e " - ${y}Debian 11${NC}"
    echo -e " - ${y}Debian 12${NC}"
    Credit_Sc
    exit 0
fi

if [[ ${VERSION_ID} == "10" || ${VERSION_ID} == "11" || ${VERSION_ID} == "12" || ${VERSION_ID} == "20.04" || ${VERSION_ID} == "21.04" || ${VERSION_ID} == "22.04" || ${VERSION_ID} == "23.04" || ${VERSION_ID} == "24.04" ]]; then
    echo -ne
else
    echo -e " ${r}This Script only Support for OS"
    echo -e ""
    echo -e " - ${y}Ubuntu 20.04${NC}"
    echo -e " - ${y}Ubuntu 21.04${NC}"
    echo -e " - ${y}Ubuntu 22.04${NC}"
    echo -e " - ${y}Ubuntu 23.04${NC}"
    echo -e " - ${y}Ubuntu 24.04${NC}"
    echo ""
    echo -e " - ${y}Debian 10${NC}"
    echo -e " - ${y}Debian 11${NC}"
    echo -e " - ${y}Debian 12${NC}"
    Credit_Sc
    exit 0
fi

if [ "$(systemd-detect-virt)" == "openvz" ]; then
echo "OpenVZ is not supported"
exit 1
fi

function MakeDirectories() {
    cd
    # Membuat direktori yang diperlukan
    mkdir -p /var/lib/LT/ >/dev/null 2>&1
    echo "IP=" >> /var/lib/LT/ipvps.conf
    touch /etc/.{ssh,vmess,vless,trojan}.db
    mkdir -p /etc/{xray,bot,vmess,vless,trojan,ssh,limit,usr}
    mkdir -p /etc/xray/limit
    mkdir -p /etc/xray/limit/{ssh,vmess,vless,trojan}
    mkdir -p /etc/lunatic/vmess/ip
    mkdir -p /etc/lunatic/vless/ip
    mkdir -p /etc/lunatic/trojan/ip
    mkdir -p /etc/lunatic/ssh/ip

# limit quota xray   
    mkdir -p /etc/lunatic/vmess/usage
    mkdir -p /etc/lunatic/vless/usage
    mkdir -p /etc/lunatic/trojan/usage

# detail account
    mkdir -p /etc/lunatic/vmess/detail
    mkdir -p /etc/lunatic/vless/detail
    mkdir -p /etc/lunatic/trojan/detail
    mkdir -p /etc/lunatic/ssh/detail

# dir xray limit quota                
    mkdir -p /etc/limit/vmess
    mkdir -p /etc/limit/vless
    mkdir -p /etc/limit/trojan
    mkdir -p /etc/limit/ssh
# dir protocol
    mkdir -p /etc/vmess
    mkdir -p /etc/vless
    mkdir -p /etc/trojan
    mkdir -p /etc/ssh
    touch /etc/lunatic/vmess/.vmess.db
    touch /etc/lunatic/vless/.vless.db
    touch /etc/lunatic/trojan/.trojan.db
    touch /etc/lunatic/ssh/.ssh.db
    touch /etc/lunatic/bot/.bot.db
    echo "& plughin Account" >>/etc/lunatic/vmess/.vmess.db
    echo "& plughin Account" >>/etc/lunatic/vless/.vless.db
    echo "& plughin Account" >>/etc/lunatic/trojan/.trojan.db
    echo "& plughin Account" >>/etc/lunatic/ssh/.ssh.db
}

function Run_First_INSTALL() {
MakeDirectories
    if [ -f /etc/xray/domain ] && [ -s /etc/xray/domain ]; then
        echo "Domain sudah ada, melewati proses pointing."
        return
    fi

    apt update
    apt install jq curl -y
    DOMAIN=klmpk.my.id
    sub=$(head /dev/urandom | tr -dc a-z0-9 | head -c 8)
    dns=${sub}.${DOMAIN}
    CF_KEY=9d25535086484fb695ab64a70a70532a32fd4
    CF_ID=andyyuda41@gmail.com
    set -euo pipefail
    echo ""
    echo "Proses Pointing Domain ${dns}..."
    sleep 1
    ZONE=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}&status=active" \
         -H "X-Auth-Email: ${CF_ID}" \
         -H "X-Auth-Key: ${CF_KEY}" \
         -H "Content-Type: application/json" | jq -r .result[0].id)

    RECORD=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records?name=${dns}" \
         -H "X-Auth-Email: ${CF_ID}" \
         -H "X-Auth-Key: ${CF_KEY}" \
         -H "Content-Type: application/json" | jq -r .result[0].id)

    if [[ "${#RECORD}" -le 10 ]]; then
         RECORD=$(curl -sLX POST "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records" \
         -H "X-Auth-Email: ${CF_ID}" \
         -H "X-Auth-Key: ${CF_KEY}" \
         -H "Content-Type: application/json" \
         --data '{"type":"A","name":"'${dns}'","content":"'${IP}'","ttl":120,"proxied":true}' | jq -r .result.id)
    fi

    RESULT=$(curl -sLX PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD}" \
         -H "X-Auth-Email: ${CF_ID}" \
         -H "X-Auth-Key: ${CF_KEY}" \
         -H "Content-Type: application/json" \
         --data '{"type":"A","name":"'${dns}'","content":"'${IP}'","ttl":120,"proxied":true}')

    # Menyimpan domain ke /etc/xray/domain hanya jika tidak ada
    echo "$dns" > /etc/xray/domain
    clear
    echo ""
    echo -e "\e[96;1mYour Domains:\e[0m ${dns}"
    
}

Run_First_INSTALL


function Dependencies() {
cd
wget https://raw.githubusercontent.com/murahtunnel/ubdeb10_20_/main/PACKAGES/tools.sh &> /dev/null
chmod +x tools.sh 
bash tools.sh
sudo apt install at -y >/dev/null 2>&1

wget -q -O /etc/port.txt "https://raw.githubusercontent.com/murahtunnel/ubdeb10_20_/main/PACKAGES/port.txt"

clear
start=$(date +%s)
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
apt install git curl -y >/dev/null 2>&1
apt install python -y >/dev/null 2>&1
}

function Installasi(){
animation_loading() {
    CMD[0]="$1"
    CMD[1]="$2"
    
    (
        # Hapus file fim jika ada
        [[ -e $HOME/fim ]] && rm -f $HOME/fim
        
        # Jalankan perintah di background dan sembunyikan output
        ${CMD[0]} -y >/dev/null 2>&1
        ${CMD[1]} -y >/dev/null 2>&1
        
        # Buat file fim untuk menandakan selesai
        touch $HOME/fim
    ) >/dev/null 2>&1 &

    tput civis # Sembunyikan kursor
    echo -ne "  \033[0;33mProcessed Install \033[1;37m- \033[0;33m["
    
    while true; do
        for ((i = 0; i < 18; i++)); do
            echo -ne "\033[0;32m#"
            sleep 0.1
        done
        
        # Jika file fim ada, hapus dan keluar dari loop
        if [[ -e $HOME/fim ]]; then
            rm -f $HOME/fim
            break
        fi
        
        echo -e "\033[0;33m]"
        sleep 1
        tput cuu1 # Kembali ke baris sebelumnya
        tput dl1   # Hapus baris sebelumnya
        echo -ne "  \033[0;33mProcessed Install \033[1;37m- \033[0;33m["
    done
    
    echo -e "\033[0;33m]\033[1;37m -\033[1;32m Succes !\033[1;37m"
    tput cnorm # Tampilkan kursor kembali
}


INSTALL_SSH() {
wget https://raw.githubusercontent.com/murahtunnel/ubdeb10_20_/main/ssh/ssh-vpn.sh && chmod +x ssh-vpn.sh && ./ssh-vpn.sh

# installer gotop
gotop_latest="$(curl -s https://api.github.com/repos/xxxserxxx/gotop/releases | grep tag_name | sed -E 's/.*"v(.*)".*/\1/' | head -n 1)"
gotop_link="https://github.com/xxxserxxx/gotop/releases/download/v$gotop_latest/gotop_v"$gotop_latest"_linux_amd64.deb"
curl -sL "$gotop_link" -o /tmp/gotop.deb
dpkg -i /tmp/gotop.deb

clear
} 

INSTALL_XRAY() {

# install semua kebutuhan xray
wget https://raw.githubusercontent.com/murahtunnel/ubdeb10_20_/main/xray/ins-xray.sh && chmod +x ins-xray.sh && ./ins-xray.sh
clear

# limit quota & service xray
wget https://raw.githubusercontent.com/murahtunnel/ubdeb10_20_/main/Xbw_LIMIT/install.sh && chmod +x install.sh && ./install.sh
clear

# limit service ip xray
wget https://raw.githubusercontent.com/murahtunnel/ubdeb10_20_/main/AUTOKILL_SERVICE/service.sh && chmod +x service.sh && ./service.sh
clear

}

INSTALL_WEBSOCKET() {
wget https://raw.githubusercontent.com/murahtunnel/ubdeb10_20_/main/ws/install-ws.sh && chmod +x install-ws.sh && ./install-ws.sh
clear
# banner ssh
wget https://raw.githubusercontent.com/murahtunnel/ubdeb10_20_/main/ws/banner_ssh.sh && chmod +x banner_ssh.sh && ./banner_ssh.sh
clear
}

INSTALL_BACKUP() {
apt install rclone
printf "q\n" | rclone config
wget -O /root/.config/rclone/rclone.conf "https://github.com/Andyyuda/vip/raw/main/limit/rclone.conf"
git clone  https://github.com/murahtunnel/wondershaper.git
cd wondershaper
make install
cd
rm -rf wondershaper
    
rm -f /root/set-br.sh
rm -f /root/limit.sh
}

INSTALL_OHP() {
wget https://raw.githubusercontent.com/murahtunnel/ubdeb10_20_/main/ws/ohp.sh && chmod +x ohp.sh && ./ohp.sh
clear
}

menu() {
wget https://raw.githubusercontent.com/murahtunnel/ubdeb10_20_/main/menu/install_menu.sh && chmod +x install_menu.sh && ./install_menu.sh
clear
}

INSTALL_UDP_CUSTOM() {
wget https://raw.githubusercontent.com/murahtunnel/ubdeb10_20_/main/ws/UDP.sh && chmod +x UDP.sh && ./UDP.sh
clear
}

if [[ $(cat /etc/os-release | grep -w ID | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/ID//g') == "ubuntu" ]]; then
echo -e "${g}Setup nginx For OS Is $(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g')${NC}"
UNTUK_UBUNTU
elif [[ $(cat /etc/os-release | grep -w ID | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/ID//g') == "debian" ]]; then
echo -e "${g}Setup nginx For OS Is $(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g')${NC}"
UNTUK_DEBIAN
else
echo -e " Your OS Is Not Supported ( ${YELLOW}$(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g')${FONT} )"
fi
}

function UNTUK_DEBIAN(){
lane_atas
echo -e "${c}│      ${g}PROCESS INSTALLED SSH & OPENVPN${NC}     ${c}│${NC}"
lane_bawah
animation_loading 'INSTALL_SSH'

lane_atas
echo -e "${c}│           ${g}PROCESS INSTALLED XRAY${NC}         ${c}│${NC}"
lane_bawah
animation_loading 'INSTALL_XRAY'

lane_atas
echo -e "${c}│       ${g}PROCESS INSTALLED WEBSOCKET SSH${NC}    ${c}│${NC}"
lane_bawah
animation_loading 'INSTALL_WEBSOCKET'

lane_atas
echo -e "${c}│       ${g}PROCESS INSTALLED BACKUP MENU${NC}${c}      │${NC}"
lane_bawah
animation_loading 'INSTALL_BACKUP'

lane_atas
echo -e "${c}│           ${g}PROCESS INSTALLED OHP${NC}${c}          │${NC}"
lane_bawah
animation_loading 'INSTALL_OHP'

lane_atas
echo -e "${c}│           ${g}DOWNLOAD EXTRA MENU${NC}${c}            │${NC}"
lane_bawah
animation_loading 'menu'

lane_atas
echo -e "${c}│           ${g}DOWNLOAD UDP CUSTOM${NC}${c}            │${NC}"
lane_bawah
animation_loading 'INSTALL_UDP_CUSTOM'

}

function UNTUK_UBUNTU(){
lane_atas
echo -e "${c}│      ${g}PROCESS INSTALLED SSH & OPENVPN${NC}     ${c}│${NC}"
lane_bawah
animation_loading 'INSTALL_SSH'

lane_atas
echo -e "${c}│           ${g}PROCESS INSTALLED XRAY${NC}         ${c}│${NC}"
lane_bawah
animation_loading 'INSTALL_XRAY'

lane_atas
echo -e "${c}│       ${g}PROCESS INSTALLED WEBSOCKET SSH${NC}    ${c}│${NC}"
lane_bawah
animation_loading 'INSTALL_WEBSOCKET'

lane_atas
echo -e "${c}│       ${g}PROCESS INSTALLED BACKUP MENU${NC}${c}      │${NC}"
lane_bawah
animation_loading 'INSTALL_BACKUP'

lane_atas
echo -e "${c}│           ${g}PROCESS INSTALLED OHP${NC}${c}          │${NC}"
lane_bawah
animation_loading 'INSTALL_OHP'

lane_atas
echo -e "${c}│           ${g}DOWNLOAD EXTRA MENU${NC}${c}            │${NC}"
lane_bawah
animation_loading 'menu'

lane_atas
echo -e "${c}│           ${g}DOWNLOAD UDP CUSTOM${NC}${c}            │${NC}"
lane_bawah
animation_loading 'INSTALL_UDP_CUSTOM'

}

# Tentukan nilai baru yang diinginkan untuk fs.file-max
NEW_FILE_MAX=65535  # Ubah sesuai kebutuhan Anda

# Nilai tambahan untuk konfigurasi netfilter
NF_CONNTRACK_MAX="net.netfilter.nf_conntrack_max=262144"
NF_CONNTRACK_TIMEOUT="net.netfilter.nf_conntrack_tcp_timeout_time_wait=30"

# File yang akan diedit
SYSCTL_CONF="/etc/sysctl.conf"

# Ambil nilai fs.file-max saat ini
CURRENT_FILE_MAX=$(grep "^fs.file-max" "$SYSCTL_CONF" | awk '{print $3}' 2>/dev/null)

# Cek apakah nilai fs.file-max sudah sesuai
if [ "$CURRENT_FILE_MAX" != "$NEW_FILE_MAX" ]; then
    # Cek apakah fs.file-max sudah ada di file
    if grep -q "^fs.file-max" "$SYSCTL_CONF"; then
        # Jika ada, ubah nilainya
        sed -i "s/^fs.file-max.*/fs.file-max = $NEW_FILE_MAX/" "$SYSCTL_CONF" >/dev/null 2>&1
    else
        # Jika tidak ada, tambahkan baris baru
        echo "fs.file-max = $NEW_FILE_MAX" >> "$SYSCTL_CONF" 2>/dev/null
    fi
fi

# Cek apakah net.netfilter.nf_conntrack_max sudah ada
if ! grep -q "^net.netfilter.nf_conntrack_max" "$SYSCTL_CONF"; then
    echo "$NF_CONNTRACK_MAX" >> "$SYSCTL_CONF" 2>/dev/null
fi

# Cek apakah net.netfilter.nf_conntrack_tcp_timeout_time_wait sudah ada
if ! grep -q "^net.netfilter.nf_conntrack_tcp_timeout_time_wait" "$SYSCTL_CONF"; then
    echo "$NF_CONNTRACK_TIMEOUT" >> "$SYSCTL_CONF" 2>/dev/null
fi


# Terapkan perubahan
sysctl -p >/dev/null 2>&1

# install dependencies
Dependencies
# installer
Installasi

    cat >/etc/cron.d/logclean <<-END
		SHELL=/bin/sh
		PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
		*/59 * * * * root /usr/bin/logclean
	END
	    cat >/etc/cron.d/daily_reboot <<-END
		SHELL=/bin/sh
		PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
		0 5 * * * /sbin/reboot
	END
    cat >/etc/cron.d/autobackup <<-END
		SHELL=/bin/sh
		PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
		2 0 * * * root /usr/local/sbin/autobackup
	END
    cat >/etc/cron.d/kill_exp <<-END
                SHELL=/bin/bash
                PATH=/sbin:/bin:/usr/sbin:/usr/bin
                */1 * * * * root /usr/local/sbin/kill_expired exp
                */1 * * * * root /usr/local/sbin/kill_expired ssh
                */1 * * * * root /usr/local/sbin/kill_expired vm
                */1 * * * * root /usr/local/sbin/kill_expired vl
                */1 * * * * root /usr/local/sbin/kill_expired tr
	END

cat> /root/.profile << END
if [ "$BASH" ]; then
if [ -f ~/.bashrc ]; then
. ~/.bashrc
fi
fi
mesg n || true
clear
menu
END
chmod 644 /root/.profile
if [ -f "/root/log-install.txt" ]; then
rm /root/log-install.txt > /dev/null 2>&1
fi
if [ -f "/etc/afak.conf" ]; then
rm /etc/afak.conf > /dev/null 2>&1
fi
history -c
serverV=$( curl -sS https://raw.githubusercontent.com/murahtunnel/ubdeb10_20_/main/versi  )
echo $serverV > /root/.versi
echo "00" > /home/daily_reboot
aureb=$(cat /home/daily_reboot)
b=11
if [ $aureb -gt $b ]
then
gg="PM"
else
gg="AM"
fi
cd

curl -sS ifconfig.me > /etc/myipvps
curl -s ipinfo.io/city?token=75082b4831f909 >> /etc/xray/city
curl -s ipinfo.io/org?token=75082b4831f909  | cut -d " " -f 2-10 >> /etc/xray/isp

rm -f /root/*.sh
rm -f /root/*.txt


CHATID="7428226275"
KEY="7382456251:AAFFC-8A6VsotlfAQj6MXe4Mff-7MNX5yRs"
URL="https://api.telegram.org/bot$KEY/sendMessage"

TEXT="
<code>= = = = = = = = = = = = =</code>
<b>            Notifications   </b>
<code>= = = = = = = = = = = = =</code>
<b>ISP VPS    :</b> <code>$ISP</code>
<b>SERVER VPS :</b> <code>$CITY</code>
<b>TIMES REAL :</b> <code>$time</code>
<b>SCRIPT KEY :</b> <code>$client</code>
<b>SCRIPT EXP :</b> <code>$exp</code>
<b>SCRIPT REG :</b> <code>$date</code>
<b= = = = = = = = = = = = =</b>
<b>LUNATIC TUNNELING SCRIPTS</b>
<code>= = = = = = = = = = = = =</code>"
curl -s --max-time 10 -X POST "$URL" \
-d "chat_id=$CHATID" \
-d "text=$TEXT" \
-d "parse_mode=HTML" \
-d "disable_web_page_preview=true" \
-d "reply_markup={\"inline_keyboard\":[[{\"text\":\" ʙᴜʏ ꜱᴄʀɪᴘᴛ \",\"url\":\"https://t.me/MurahTunnel\"}]]}"

cd
rm ~/.bash_history
rm -f openvpn
rm -f key.pem
rm -f cert.pem

sleep 2
cd
clear
echo -e "${c}┌────────────────────────────────────────────┐${NC}"
echo -e "${c}│  ${g}INSTALL SCRIPT SELESAI..${NC}                  ${c}│${NC}"
echo -e "${c}└────────────────────────────────────────────┘${NC}"
echo  ""
echo -e "\e[92;1m dalam 3 detik akan Melakukan reboot.... \e[0m"
sleep 3

# Langsung reboot
reboot
