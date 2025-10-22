#!/bin/bash

function multiselect {
    # little helpers for terminal print control and key input
    ESC=$( printf "\033")
    cursor_blink_on()   { printf "$ESC[?25h"; }
    cursor_blink_off()  { printf "$ESC[?25l"; }
    cursor_to()         { printf "$ESC[$1;${2:-1}H"; }
    print_inactive()    { printf "$2   $1 "; }
    print_active()      { printf "$2  $ESC[7m $1 $ESC[27m"; }
    get_cursor_row()    { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }

    local return_value=$1
    local -n options=$2
    local -n defaults=$3

    local selected=()
    for ((i=0; i<${#options[@]}; i++)); do
        if [[ ${defaults[i]} = "true" ]]; then
            selected+=("true")
        else
            selected+=("false")
        fi
        printf "\n"
    done

    # determine current screen position for overwriting the options
    local lastrow=`get_cursor_row`
    local startrow=$(($lastrow - ${#options[@]}))

    # ensure cursor and input echoing back on upon a ctrl+c during read -s
    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off

    key_input() {
        local key
        IFS= read -rsn1 key 2>/dev/null >&2
        if [[ $key = ""      ]]; then echo enter; fi;
        if [[ $key = $'\x20' ]]; then echo space; fi;
        if [[ $key = "k" ]]; then echo up; fi;
        if [[ $key = "j" ]]; then echo down; fi;
        if [[ $key = $'\x1b' ]]; then
            read -rsn2 key
            if [[ $key = [A || $key = k ]]; then echo up;    fi;
            if [[ $key = [B || $key = j ]]; then echo down;  fi;
        fi 
    }

    toggle_option() {
        local option=$1
        if [[ ${selected[option]} == true ]]; then
            selected[option]=false
        else
            selected[option]=true
        fi
    }

    print_options() {
        # print options by overwriting the last lines
        local idx=0
        for option in "${options[@]}"; do
            local prefix="[ ]"
            if [[ ${selected[idx]} == true ]]; then
              prefix="[\e[38;5;46m✔\e[0m]"
            fi

            cursor_to $(($startrow + $idx))
            if [ $idx -eq $1 ]; then
                print_active "$option" "$prefix"
            else
                print_inactive "$option" "$prefix"
            fi
            ((idx++))
        done
    }

    local active=0
    while true; do
        print_options $active

        # user key control
        case `key_input` in
            space)  toggle_option $active;;
            enter)  print_options -1; break;;
            up)     ((active--));
                    if [ $active -lt 0 ]; then active=$((${#options[@]} - 1)); fi;;
            down)   ((active++));
                    if [ $active -ge ${#options[@]} ]; then active=0; fi;;
        esac
    done

    # cursor position back to normal
    cursor_to $lastrow
    printf "\n"
    cursor_blink_on

    eval $return_value='("${selected[@]}")'
}

#pre-select options
appYakuake=false
appGuake=false
appChromium=false
appFirefox=false
appThunderbird=false
appGit=false
appNodejs=false
appNpm=false
appFlameshot=false
appWget=false
appCurl=false
appGparted=false
appDosfstools=false
appEclipse=false
appBaseDevel=false
appFlatpak=false
appAmberol=false

appAurNames=("yakuake" "guake" "chromium" "firefox" "thunderbird" "git" "nodejs" "npm" "flameshot" "wget" "curl" "gparted" "dosfstools" "eclipse-ecj" "base-devel" "flatpak" "amberol")
appNames=(  "Yakuake - Dropdown Terminal for KDE only" "Guake - Dropdow Terminal" "Chromium - Web Browser"  "Firefox - Web Browser" "Thunderbird - Mailing App" "Git" "Nodejs" "Npm" "Flameshot - Take Screen Shot" "WGet" "Curl" "GParted - Disk Management" "dosfstools - Disk management addons for Windows file formats" "Eclipse - Java Editor" "base-devel" "Flatpak - Package Management" "Amberol - Music tool" )
preselection=( $appYakuake  $appGuake $appChromium $appFirefox $appThunderbird $appGit $appNodejs $appSelections $appNpm $appFlameshot $appWget $appCurl $appGparted $appDosfstools $appEclipse $appBaseDevel $appFlatpak $appAmberol )
multiselect result appNames preselection

selectedApps=()
idx=0
for ((idx=0; idx<=${#result[@]}; idx++)); do
    if [[ ${result[idx]} = "true" ]]; then selectedApps+=("${appAurNames[idx]}"); fi
done


echo "Installing selected apps: ${selectedApps[@]}"

sudo pacman -Sy ${selectedApps[@]} --noconfirm

#-------------------------------------------------------
#install yay and yay packages
echo "Select Yay packages to install: (Git required for yay install)"


#pre-select options
appVSCode= false

yayPackageNames=("visual-studio-code-bin")
appNames=("Visual Studio Code(Yay Needed)")
preselection=($appVSCode )
multiselect result appNames preselection


selectedApps=()
idx=0
for ((idx=0; idx<=${#result[@]}; idx++)); do
    if [[ ${result[idx]} = "true" ]]; then selectedApps+=("${yayPackageNames[idx]}"); fi
done

echo "Installing selected apps: ${selectedApps[@]}"
yay -S ${selectedApps[@]} --noconfirm --answerdiff=None --answeredit=None --sudoloop --save
