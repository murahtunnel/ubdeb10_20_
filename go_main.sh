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
echo "${r}You need to run this script as root\033[0m"
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

function LINER_UP() {
echo -e "\033[38;5;197m┌──────────────────────────────────────────┐\033[0m"
}
function LINER_TURN() {
echo -e "\033[38;5;197m└──────────────────────────────────────────┘\033[0m"
}

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
    echo -e "\033[44;37m           NotAllowed Autoscript         \033[0m"    
    echo -e "\033[96m============================================\033[0m"
    echo -e "\e[95;1m buy / sewa AutoScript installer VPS \e[0m"
    echo -e "\033[96m============================================\033[0m"    
    echo -e "\e[96;1m   1 IP        : Rp.10.000   \e[0m"
    echo -e "\e[96;1m   2 IP        : Rp.15.000   \e[0m"   
    echo -e "\e[96;1m   7 IP        : Rp.40.000   \e[0m"
    echo -e "\e[96;1m   Unli IP     : Rp.150.000  \e[0m"
    echo -e "\e[97;1m   open source : Rp.400.000  \e[0m"       
    echo -e ""
    echo -e "\033[34m Contack WA/TLP: +62 859-3192-5073     \033[0m"
    echo -e "\033[96m============================================\033[0m"
    exit 0
  fi
}
checking_sc

function OS_SCRIPT_SUPPORTED() {
if [[ "$( uname -m | awk '{print $1}' )" == "x86_64" ]]; then
    echo -ne
else
    echo -e "${r} Your Architecture Is Not Supported ( ${y}$( uname -m )\033[0m )"
    exit 1
fi

if [[ ${ID} == "ubuntu" || ${ID} == "debian" ]]; then
    echo -ne
else
    echo -e " ${r}This Script only Support for OS"
    echo -e ""
    echo -e " - ${y}Ubuntu 20.04\033[0m"
    echo -e " - ${y}Ubuntu 21.04\033[0m"
    echo -e " - ${y}Ubuntu 22.04\033[0m"
    echo -e " - ${y}Ubuntu 23.04\033[0m"
    echo -e " - ${y}Ubuntu 24.04\033[0m"
    echo ""
    echo -e " - ${y}Debian 10\033[0m"
    echo -e " - ${y}Debian 11\033[0m"
    echo -e " - ${y}Debian 12\033[0m"
    exit 0
fi

if [[ ${VERSION_ID} == "10" || ${VERSION_ID} == "11" || ${VERSION_ID} == "12" || ${VERSION_ID} == "20.04" || ${VERSION_ID} == "21.04" || ${VERSION_ID} == "22.04" || ${VERSION_ID} == "23.04" || ${VERSION_ID} == "24.04" ]]; then
    echo -ne
else
    echo -e " ${r}This Script only Support for OS"
    echo -e ""
    echo -e " - ${y}Ubuntu 20.04\033[0m"
    echo -e " - ${y}Ubuntu 21.04\033[0m"
    echo -e " - ${y}Ubuntu 22.04\033[0m"
    echo -e " - ${y}Ubuntu 23.04\033[0m"
    echo -e " - ${y}Ubuntu 24.04\033[0m"
    echo ""
    echo -e " - ${y}Debian 10\033[0m"
    echo -e " - ${y}Debian 11\033[0m"
    echo -e " - ${y}Debian 12\033[0m"
    exit 0
fi

if [ "$(systemd-detect-virt)" == "openvz" ]; then
echo "OpenVZ is not supported"
exit 1
fi
}
OS_SCRIPT_SUPPORTED

function MAKEDIRS() {
    # Direktori utama
    local main_dirs=(
        "/etc/xray" "/var/lib/LT" "/etc/lunatic" "/etc/limit"
        "/etc/vmess" "/etc/vless" "/etc/trojan" "/etc/ssh"
    )
    
    local lunatic_subdirs=("vmess" "vless" "trojan" "ssh" "bot")
    local lunatic_types=("usage" "ip" "detail")

    local protocols=("vmess" "vless" "trojan" "ssh")

    for dir in "${main_dirs[@]}"; do
        mkdir -p "$dir"
    done

    for service in "${lunatic_subdirs[@]}"; do
        for type in "${lunatic_types[@]}"; do
            mkdir -p "/etc/lunatic/$service/$type"
        done
    done

    for protocol in "${protocols[@]}"; do
        mkdir -p "/etc/limit/$protocol"
    done

    local databases=(
        "/etc/lunatic/vmess/.vmess.db"
        "/etc/lunatic/vless/.vless.db"
        "/etc/lunatic/trojan/.trojan.db"
        "/etc/lunatic/ssh/.ssh.db"
        "/etc/lunatic/bot/.bot.db"
    )

    for db in "${databases[@]}"; do
        touch "$db"
        echo "& plugin Account" >> "$db"
    done

    touch /etc/.{ssh,vmess,vless,trojan}.db
    echo "IP=" > /var/lib/LT/ipvps.conf
}
echo -e "\e[97;1m =========================== \e[0m"
echo -e "\e[97;1m   CREATE DIRECTORY SCRIPT   \e[0m"
echo -e "\e[97;1m =========================== \e[0m"
sleep 2
MAKEDIRS

clear

function DOMAINS_MANAGER() {
    echo -e "\e[97;1m =========================== \e[0m"
    echo -e "\e[97;1m   DOMAINS CHANGES TO VPS    \e[0m"
    echo -e "\e[97;1m =========================== \e[0m"
    echo -e "\e[92;1m 1. Domain sendiri \e[0m"
    echo -e "\e[92;1m 2. Domain random  \e[0m"
    echo -e "\e[97;1m =========================== \e[0m"
    echo -e ""
    read -p "Select choice domain 1-2: " DOMAINS_SELECT

    if [ "$DOMAINS_SELECT" == "1" ]; then
        clear
        echo -e "\e[97;1m =========================== \e[0m"
        echo -e "\e[97;1m      DOMAINS SENDIRI        \e[0m"
        echo -e "\e[97;1m =========================== \e[0m"
        echo -e ""
        read -p "Your domains: " YUDOMAINS
        echo "$YUDOMAINS" > /etc/xray/domain
        echo "$YUDOMAINS" > /root/domain
    elif [ "$DOMAINS_SELECT" == "2" ]; then
        wget https://raw.githubusercontent.com/murahtunnel/ubdeb10_20_/main/domains.sh \
             -O /tmp/domains.sh >/dev/null 2>&1 && \
             chmod +x /tmp/domains.sh && /tmp/domains.sh
    else
        echo -e "\e[91;1mPilihan tidak valid!\e[0m"
    fi
    clear
}

DOMAINS_MANAGER



function INSTALL() {
animation_loading() {
    CMD[0]="$1"
    CMD[1]="$2"

    # Jalankan perintah-perintah instalasi secara background dan sembunyikan output
    (
        # Hapus file penanda (jika ada) untuk memastikan proses baru
        rm -f "$HOME/.install_done" 2>/dev/null

        # Jalankan perintah dengan parameter -y dan sembunyikan output
        ${CMD[0]} -y >/dev/null 2>&1
        ${CMD[1]} -y >/dev/null 2>&1

        # Buat file penanda sebagai tanda bahwa instalasi telah selesai
        touch "$HOME/.install_done"
    ) >/dev/null 2>&1 &
    local pid=$!

    # Sembunyikan kursor agar tampilan lebih rapi
    tput civis

    # Pengaturan progress bar dan spinner
    local barWidth=30       # Panjang progress bar
    local progress=0        # Nilai progress sementara
    local spinnerChars="|/-\\"  # Karakter spinner
    local spinnerIdx=0

    # Animasi loading berjalan selama proses background masih aktif
    while kill -0 "$pid" 2>/dev/null; do
        # Simulasi progress bar yang naik dari 0 hingga barWidth, lalu diulang ulang
        progress=$(( (progress + 1) % (barWidth + 1) ))
        # Buat bagian progress yang sudah terisi dan sisanya sebagai kosong
        local filled=$(printf "%0.s#" $(seq 1 $progress))
        local empty=$(printf "%0.s-" $(seq 1 $((barWidth - progress))))

        # Ambil karakter spinner yang sesuai
        local spinner="${spinnerChars:spinnerIdx:1}"
        spinnerIdx=$(( (spinnerIdx + 1) % ${#spinnerChars} ))

        # Tampilkan progress bar beserta spinner
        printf "\r\033[0;35mInstalling\033[1;37m - \033[97;1m[%s%s] %s\033[0m" "$filled" "$empty" "$spinner"
        sleep 0.1
    done

    # Pastikan proses background telah selesai
    wait "$pid"

    # Tampilkan progress bar penuh dan pesan sukses
    printf "\r\033[97;1m[##############################] \033[1;32mOK!\033[0m\n"
    tput cnorm  # Tampilkan kembali kursor
}
TOOLS_PKG() {
cd
wget -q -O /etc/port.txt "https://raw.githubusercontent.com/murahtunnel/ubdeb10_20_/main/PACKAGES/port.txt"
clear
start=$(date +%s)
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
apt install git curl -y >/dev/null 2>&1
apt install python -y >/dev/null 2>&1
}
INSTALL_SSH() {
# install at untuk meng kill triall ssh
sudo apt install at -y >/dev/null 2>&1
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
# install-ws
wget https://raw.githubusercontent.com/murahtunnel/ubdeb10_20_/main/ws/install-ws.sh && chmod +x install-ws.sh && ./install-ws.sh
clear
# banner ssh
wget https://raw.githubusercontent.com/murahtunnel/ubdeb10_20_/main/ws/banner_ssh.sh && chmod +x banner_ssh.sh && ./banner_ssh.sh
clear
}
INSTALL_BACKUP() {
apt install rclone
printf "q\n" | rclone config
wget -O /root/.config/rclone/rclone.conf "https://github.com/murahtunnel/ubdeb10_20_/raw/main/rclone.conf"
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
INSTALL_FEATURE() {
wget https://raw.githubusercontent.com/murahtunnel/ubdeb10_20_/main/menu/install_menu.sh && chmod +x install_menu.sh && ./install_menu.sh
clear
}
INSTALL_UDP_CUSTOM() {
wget https://raw.githubusercontent.com/murahtunnel/ubdeb10_20_/main/ws/UDP.sh && chmod +x UDP.sh && ./UDP.sh
clear
}

if [[ $(cat /etc/os-release | grep -w ID | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/ID//g') == "ubuntu" ]]; then
echo -e "\033[38;5;227mSetup For OS: $(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g')\033[0m"
Setup_For_Ubuntu
elif [[ $(cat /etc/os-release | grep -w ID | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/ID//g') == "debian" ]]; then
echo -e "\033[38;5;227mSetup For OS: $(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g')\033[0m"
Setup_For_Debian
else
echo -e " Your OS Is Not Supported ( ${YELLOW}$(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g')${FONT} )"
fi
}

function Setup_For_Debian(){
LINER_UP
echo -e "\033[38;5;197m│      \033[38;5;227mPROCESS INSTALLED MODUL PACKAGE\033[0m     \033[38;5;197m│\033[0m"
LINER_TURN
animation_loading 'TOOLS_PKG'

LINER_UP
echo -e "\033[38;5;197m│      \033[38;5;227mPROCESS INSTALLED SSH & OPENVPN\033[0m     \033[38;5;197m│\033[0m"
LINER_TURN
animation_loading 'INSTALL_SSH'

LINER_UP
echo -e "\033[38;5;197m│           \033[38;5;227mPROCESS INSTALLED XRAY\033[0m         \033[38;5;197m│\033[0m"
LINER_TURN
animation_loading 'INSTALL_XRAY'

LINER_UP
echo -e "\033[38;5;197m│       \033[38;5;227mPROCESS INSTALLED WEBSOCKET SSH\033[0m    \033[38;5;197m│\033[0m"
LINER_TURN
animation_loading 'INSTALL_WEBSOCKET'

LINER_UP
echo -e "\033[38;5;197m│       \033[38;5;227mPROCESS INSTALLED BACKUP MENU\033[0m\033[38;5;197m      │\033[0m"
LINER_TURN
animation_loading 'INSTALL_BACKUP'

LINER_UP
echo -e "\033[38;5;197m│           \033[38;5;227mPROCESS INSTALLED OHP\033[0m\033[38;5;197m          │\033[0m"
LINER_TURN
animation_loading 'INSTALL_OHP'

LINER_UP
echo -e "\033[38;5;197m│           \033[38;5;227mDOWNLOAD EXTRA MENU\033[0m\033[38;5;197m            │\033[0m"
LINER_TURN
animation_loading 'INSTALL_FEATURE'

LINER_UP
echo -e "\033[38;5;197m│           \033[38;5;227mDOWNLOAD UDP CUSTOM\033[0m\033[38;5;197m            │\033[0m"
LINER_TURN
animation_loading 'INSTALL_UDP_CUSTOM'

}

function Setup_For_Ubuntu(){
LINER_UP
echo -e "\033[38;5;197m│      \033[38;5;227mPROCESS INSTAKKED MODUL PACKAGE\033[0m     \033[38;5;197m│\033[0m"
LINER_TURN
animation_loading 'TOOLS_PKG'

LINER_UP
echo -e "\033[38;5;197m│      \033[38;5;227mPROCESS INSTALLED SSH & OPENVPN\033[0m     \033[38;5;197m│\033[0m"
LINER_TURN
animation_loading 'INSTALL_SSH'

LINER_UP
echo -e "\033[38;5;197m│           \033[38;5;227mPROCESS INSTALLED XRAY\033[0m         \033[38;5;197m│\033[0m"
LINER_TURN
animation_loading 'INSTALL_XRAY'

LINER_UP
echo -e "\033[38;5;197m│       \033[38;5;227mPROCESS INSTALLED WEBSOCKET SSH\033[0m    \033[38;5;197m│\033[0m"
LINER_TURN
animation_loading 'INSTALL_WEBSOCKET'

LINER_UP
echo -e "\033[38;5;197m│       \033[38;5;227mPROCESS INSTALLED BACKUP MENU\033[0m\033[38;5;197m      │\033[0m"
LINER_TURN
animation_loading 'INSTALL_BACKUP'

LINER_UP
echo -e "\033[38;5;197m│           \033[38;5;227mPROCESS INSTALLED OHP\033[0m\033[38;5;197m          │\033[0m"
LINER_TURN
animation_loading 'INSTALL_OHP'

LINER_UP
echo -e "\033[38;5;197m│           \033[38;5;227mDOWNLOAD EXTRA MENU\033[0m\033[38;5;197m            │\033[0m"
LINER_TURN
animation_loading 'INSTALL_FEATURE'

LINER_UP
echo -e "\033[38;5;197m│           \033[38;5;227mDOWNLOAD UDP CUSTOM\033[0m\033[38;5;197m            │\033[0m"
LINER_TURN
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

function install_crond(){
wget https://raw.githubusercontent.com/murahtunnel/ubdeb10_20_/main/install_cron.sh && chmod +x install_cron.sh && ./install_cron.sh > /dev/null 2>&1
clear
}


# install tools.sh
wget https://raw.githubusercontent.com/murahtunnel/ubdeb10_20_/main/PACKAGES/tools.sh && chmod +x tools.sh && ./tools.sh > /dev/null 2>&1

INSTALL
install_crond

# install cron.d
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


function SENDER_NOTIFICATION() {
CHATID="6909128011"
KEY="7665798896:AAH6oThmdoWiZYQ7Z_Sv9V-kzV26KcmJzVU"
URL="https://api.telegram.org/bot$KEY/sendMessage"
TEXT="
<code>= = = = = = = = = = = = =</code>
<b>   🧱 AUTOSCRIPT PREMIUM 🧱 </b>
<b>        Notifications       </b>
<code>= = = = = = = = = = = = =</code>
<b>Client  :</b> <code>$client</code>
<b>ISP     :</b> <code>$ISP</code>
<b>Country :</b> <code>$CITY</code>
<b>DATE    :</b> <code>$date</code>
<b>Time    :</b> <code>$time</code>
<b>Expired :</b> <code>$exp</code>
<code>= = = = = = = = = = = = =</code>
<b>     ULTRASONIC TECHNOLOGY    </b>
<code>= = = = = = = = = = = = =</code>"
curl -s --max-time 10 -X POST "$URL" \
-d "chat_id=$CHATID" \
-d "text=$TEXT" \
-d "parse_mode=HTML" \
-d "disable_web_page_preview=true" \
-d "reply_markup={\"inline_keyboard\":[[{\"text\":\" ʙᴜʏ ꜱᴄʀɪᴘᴛ \",\"url\":\"https://t.me/ian_khvicha\"}]]}"

clear
}

rm ~/.bash_history
rm -f openvpn
rm -f key.pem
rm -f cert.pem

clear
echo -e "\033[38;5;197m┌────────────────────────────────────────────┐\033[0m"
echo -e "\033[38;5;197m│  \033[38;5;227mINSTALL SCRIPT SELESAI..\033[0m                  \033[38;5;197m│\033[0m"
echo -e "\033[38;5;197m└────────────────────────────────────────────┘\033[0m"
echo  ""
echo -e "\e[92;1m dalam 3 detik akan Melakukan reboot.... \e[0m"

SENDER_NOTIFICATION

sleep 3

clear
# Langsung reboot
reboot
