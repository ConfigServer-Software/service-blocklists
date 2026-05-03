#!/bin/bash

# #
#   @for                https://github.com/ConfigServer-Software/service-blocklists
#   @workflow           blocklist-generate.yml
#   @type               bash script
#   @summary            Aetherx Blocklists > GeoLite2 Country IPsets
#                       generates a set of IPSET files by reading the GeoLite2 csv file and splitting the IPs up into their associated country.
#   
#   @terminal           .github/scripts/bl-geolite2.sh -l <LICENSE_KEY>
#                       .github/scripts/bl-geolite2.sh --local
#                       .github/scripts/bl-geolite2.sh --local --dev
#                       .github/scripts/bl-geolite2.sh --dry
#
#   @command            bl-geolite2.sh -l <LICENSE_KEY> ]
#                       bl-geolite2.sh --local
#                       bl-geolite2.sh --dev
#                       bl-geolite2.sh --dry
# #

# #
#   DOWNLOAD MODE
#   
#   If you do not want to provide the GeoIP country .zip and md5, you can download
#   new versions of these files from MaxMind. Run the following command:
#           .github/scripts/bl-geolite2.sh --license XXXXXXXXXXXXX --dev
#   
#   You can also specify a license key in the file `geolite2.conf`; add:
#           LICENSE_KEY=YOUR_LICENSE_KEY
#   Then run the script:
#       .github/scripts/bl-geolite2.sh
#   
#   The GeoIP country .zip and .zip.md5 will be downloaded, extracted, and the
#   blocklist will be generated.
# #

# #
#   LOCAL MODE
#   
#   Running local mode requires you to download the .zip and .md5. You must have
#   the following files in the zip:
#           .github/local/GeoLite2-Country-CSV.zip
#               .github/local/GeoLite2-Country-Locations-en.csv
#               .github/local/GeoLite2-Country-Blocks-IPv4.csv
#                .github/local/GeoLite2-Country-Blocks-IPv6.csv
#           .github/local/GeoLite2-Country-CSV.zip.md5
#   
#   1.  Download geocountry database files
#           https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country-CSV&license_key=LICENSE_KEY&suffix=zip
#           https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country-CSV&license_key=LICENSE_KEY&suffix=zip.md5
#       
#   2.  Place .zip and .md5 inside:
#           blocklistsv2/.github/local/geo-country/
#   
#   3.  Run script from 
#           .github/scripts/bl-geolite2.sh --local
# #

# #
#   TEST MODE
#   
#   You can limit the number of results extracted from the .zip by specifying the
#           `-L 15`.
#   
#   Use this example to build the geoip blocklist with the first 15 entries:
#           .github/scripts/bl-geolite2.sh --local --dev -L 15
# #

# #
#   Define › Set PATH
# #

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"
export LC_NUMERIC=en_US.UTF-8

# #
#   Define › Files
# #

app_file_this=$(basename "$0")                                                  # bl-geolite2_asn.sh    (with ext)
app_file_bin="${app_file_this%.*}"                                              # bl-geolite2_asn       (without ext)

# #
#   Define › Folders
# #

app_dir="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"                        # path where script was last found in
app_dir_this_dir="${PWD}"                                                       # current script directory
app_dir_github="${app_dir_this_dir}/.github"                                    # .github folder

# #
#   Define › Colors
#   
#   Use the color table at:
#       - https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
# #

esc=$(printf '\033')
end="${esc}[0m"
bgEnd="${esc}[49m"
fgEnd="${esc}[39m"
bold="${esc}[1m"
dim="${esc}[2m"
underline="${esc}[4m"
blink="${esc}[5m"
white="${esc}[97m"
black="${esc}[0;30m"
redl="${esc}[0;91m"
redd="${esc}[38;5;196m"
magental="${esc}[38;5;197m"
magentad="${esc}[38;5;161m"
fuchsial="${esc}[38;5;206m"
fuchsiad="${esc}[38;5;199m"
bluel="${esc}[38;5;33m"
blued="${esc}[38;5;27m"
greenl="${esc}[38;5;47m"
greend="${esc}[38;5;35m"
orangel="${esc}[38;5;208m"
oranged="${esc}[38;5;202m"
yellowl="${esc}[38;5;226m"
yellowd="${esc}[38;5;214m"
greyl="${esc}[38;5;250m"
greym="${esc}[38;5;244m"
greyd="${esc}[38;5;240m"
navy="${esc}[38;5;62m"
olive="${esc}[38;5;144m"
peach="${esc}[38;5;204m"
cyan="${esc}[38;5;6m"
bgVerbose="${esc}[1;38;5;15;48;5;125m"
bgDebug="${esc}[1;38;5;15;48;5;237m"
bgInfo="${esc}[1;38;5;15;48;5;27m"
bgOk="${esc}[1;38;5;15;48;5;64m"
bgWarn="${esc}[1;38;5;16;48;5;214m"
bgDanger="${esc}[1;38;5;15;48;5;202m"
bgError="${esc}[1;38;5;15;48;5;160m"

# #
#   Define › App
# #

app_name="Blocklist › Geolite2"                                                 # name of app
app_desc="Uses the MaxMind geo database to generate ipsets for specified ASNs." # desc
app_ver="1.2.0.0"                                                               # current script version
app_repo="ConfigServerApps/service-blocklists"                                  # repository
app_repo_branch="main"                                                          # repository branch
app_repo_curl_storage="https://raw.githubusercontent.com/${app_repo}/${app_repo_branch}/.github"
app_agent="Mozilla/5.0 (Windows NT 10.0; WOW64) "\
"AppleWebKit/537.36 (KHTML, like Gecko) "\
"Chrome/51.0.2704.103 Safari/537.36 "\
"ConfigServer Security (hello@configserver.dev)"                                # user agent used with curl

# #
#   Define › Args
# #

argDryrun="false"                                                               # dryrun mode
argDevMode="false"                                                              # dev mode
argVerbose="false"                                                              # verbose mode
argUseLocalDB="false"                                                           # Process local database instead of download
argMMLicense=""                                                                 # MaxMind license key
argLimitEntries=0                                                               # Number of entries to process; set to 0 or unset for full run

# #
#   Define › Time
# #

time_start=$( date +%s )                                                        # record start time of script
SECONDS=0                                                                       # set seconds count for beginning of script

# #
#   Define › Regex
# #

regex_url='^(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]\.[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]$'
regex_ipv4='^([0-9]{1,3}\.){3}[0-9]{1,3}$'
regex_ipv4_cidr='^([0-9]{1,3}\.){3}[0-9]{1,3}/([0-9]{1,2})$'
regex_ipv6='^[0-9A-Fa-f:.]+$'
regex_ipv6_cidr='^[0-9A-Fa-f:.]+/[0-9]{1,3}$'
regex_ipv4_range='([0-9]{1,3}\.){3}[0-9]{1,3}[[:space:]]*-[[:space:]]*([0-9]{1,3}\.){3}[0-9]{1,3}'

# #
#   Define › Logging functions
#   
#   verbose "This is an verbose message"
#   debug "This is an debug message"
#   info "This is an info message"
#   ok "This is an ok message"
#   warn "This is a warn message"
#   danger "This is a danger message"
#   error "This is an error message"
# #

info( )
{
    printf '\033[0m%-41s %-65s\n' "   ${bgInfo} INFO ${end}" "${greym} $1 ${end}"
}

ok( )
{
    printf '\033[0m%-41s %-65s\n' "   ${bgOk} PASS ${end}" "${greym} $1 ${end}"
}

warn( )
{
    printf '\033[0m%-42s %-65s\n' "   ${bgWarn} WARN ${end}" "${greym} $1 ${end}"
}

danger( )
{
    printf '\033[0m%-42s %-65s\n' "   ${bgDanger} DNGR ${end}" "${greym} $1 ${end}"
}

error( )
{
    printf '\033[0m%-42s %-65s\n' "   ${bgError} FAIL ${end}" "${greym} $1 ${end}"
}

debug( )
{
    if [ "$argDevMode" = "true" ] || [ "$argDryrun" = "true" ]; then
        printf '\033[0m%-42s %-65s\n' "   ${bgDebug} DBUG ${end}" "${greym} $1 ${end}"
    fi
}

verbose( )
{
    case "${argVerbose:-0}" in
        1|true|TRUE|yes|YES)
            printf '\033[0m%-42s %-65s\n' "   ${bgVerbose} VRBO ${end}" "${greym} $1 ${end}"
            ;;
    esac
}

label( )
{
    printf '\033[0m%-31s %-65s\n' "   ${greyd}        ${end}" "${greyd} $1 ${end}"
}

print( )
{
    echo "${greym}$1${end}"
}

# #
#   Define › Elapsed Time
#       - Capture end time
#       - Calculate elapsed time
#       - Calculate days, hours, etc.
#       - Output to console
# #

time_elapsed( )
{
    local T=$1
    D=$(( T / 86400 ))
    H=$(( (T % 86400) / 3600 ))
    M=$(( (T % 3600) / 60 ))
    S=$(( T % 60 ))
}

# #
#   Debug Mode
#   
#   This script includes debug mode. You can enable it with the settings below:
#       argDevMode=true
#   
#   This will enable various prints to show the progress of each step. Make sure to turn this off when
#   in production mode.
# #

folder_source_local="local/geo-country"                                         # local mode enabled: place geoip country .zip and .zip.md5 here.
folder_target_storage="blocklists/geolite/country"                              # path to save compiled ipsets
folder_target_temp="temp"                                                       # local mode disabled: where csv will be downloaded to
folder_target_logs=".logs"                                                      # path to store logs
folder_target_cache="cache"                                                     # location where countries and continents are stored as array to file
path_storage_ipv4="${folder_target_storage}/ipv4"                               # folder to store ipv4
path_storage_ipv6="${folder_target_storage}/ipv6"                               # folder to store ipv6
file_target_ext_tmp="tmp"                                                       # temp extension for ipsets before work is done
file_target_ext_ipset="ipset"                                                   # extension for ipsets
file_source_csv_locs="GeoLite2-Country-Locations-en.csv"                        # File: Geolite2 Country Locations CSV 
file_source_csv_ipv4="GeoLite2-Country-Blocks-IPv4.csv"                         # File: Geolite2 Country CSV IPv4
file_source_csv_ipv6="GeoLite2-Country-Blocks-IPv6.csv"                         # File: Geolite2 Country CSV IPv6
file_cfg="geolite2.conf"                                                        # Optional config file for license key / settings

# #
#   Define › GeoLite2 Database Zip / Md5
#   
#   Search for CSV database archive zip and md5 using wildcard for the date.
#       GeoLite2-Country-CSV_*.zip
#   
#   Downloaded databases usually come with the filename:
#       GeoLite2-Country-CSV_20260313.zip
#       GeoLite2-Country-CSV_20260313.zip.md5
# #

shopt -s nullglob
for f in "${app_dir_github}/${folder_source_local}"/GeoLite2-Country-CSV*.zip; do
    file_source_csv_zip="$f"
    break
done

for f in "${app_dir_github}/${folder_source_local}"/GeoLite2-Country-CSV*.zip.md5; do
    file_source_csv_zip_md5="$f"
    break
done
shopt -u nullglob

# #
#   Define › Help Vars
# #

APP_USAGE="🗔  Usage: ./${app_file_this} ${blued}[-l <LICENSE_KEY>]${end}
        ${greym}./${app_file_this} ${blued}-?${end}
        ${greym}./${app_file_this} ${blued}clr${end}
        ${greym}./${app_file_this} ${blued}chart${end}
"

# #
#   Helper › Show Color Test
#   
#   @usage      .github/scripts/bl-geolite2.sh --color
# #

debug_ColorTest( )
{
    echo
    echo "  white      ${greym}............. ${white}This is text ███████████████${end}"
    echo "  black      ${greym}............. ${black}This is text ███████████████${end}"
    echo "  redl       ${greym}............. ${redl}This is text ███████████████${end}"
    echo "  redd       ${greym}............. ${redd}This is text ███████████████${end}"
    echo "  magental   ${greym}............. ${magental}This is text ███████████████${end}"
    echo "  magentad   ${greym}............. ${magentad}This is text ███████████████${end}"
    echo "  fuchsial   ${greym}............. ${fuchsial}This is text ███████████████${end}"
    echo "  fuchsiad   ${greym}............. ${fuchsiad}This is text ███████████████${end}"
    echo "  bluel      ${greym}............. ${bluel}This is text ███████████████${end}"
    echo "  blued      ${greym}............. ${blued}This is text ███████████████${end}"
    echo "  greenl     ${greym}............. ${greenl}This is text ███████████████${end}"
    echo "  greend     ${greym}............. ${greend}This is text ███████████████${end}"
    echo "  orangel    ${greym}............. ${orangel}This is text ███████████████${end}"
    echo "  oranged    ${greym}............. ${oranged}This is text ███████████████${end}"
    echo "  yellowl    ${greym}............. ${yellowl}This is text ███████████████${end}"
    echo "  yellowd    ${greym}............. ${yellowd}This is text ███████████████${end}"
    echo "  greyl      ${greym}............. ${greyl}This is text ███████████████${end}"
    echo "  greym      ${greym}............. ${greym}This is text ███████████████${end}"
    echo "  greyd      ${greym}............. ${greyd}This is text ███████████████${end}"
    echo "  navy       ${greym}............. ${navy}This is text ███████████████${end}"
    echo "  olive      ${greym}............. ${olive}This is text ███████████████${end}"
    echo "  peach      ${greym}............. ${peach}This is text ███████████████${end}"
    echo "  cyan       ${greym}............. ${cyan}This is text ███████████████${end}"
    echo

    exit 1
}

# #
#   Helper › Show Color Chart
#   
#   Shows a complete color charge which can be used with the color declarations in this script.
#   
#   @usage      .github/scripts/bt-transmission.sh chart
# #

debug_ColorChart( )
{
    for fgbg in 38 48 ; do                                                      # foreground / background
        for clr in {0..255} ; do                                                # colors
            printf "\e[${fgbg};5;%sm  %3s  \e[0m" $clr $clr
            if [ $((($clr + 1) % 6)) == 4 ] ; then                              # show 6 colors per lines
                echo
            fi
        done

        echo
    done
    
    exit 1
}

# #
#   Usage
# #

opt_usage()
{
    echo -e
    printf "  ${bluel}${app_name}${end}\n" 1>&2
    printf "  ${dim}${app_desc}${end}\n" 1>&2
    echo -e
    printf '  %-5s %-40s\n' "Usage:" "" 1>&2
    printf '  %-5s %-40s\n' "    " "${app_file_this} [ ${greym} options${end} ]" 1>&2
    printf '  %-5s %-40s\n\n' "    " "${app_file_this} [ ${greym}--help${end} ] [ ${greym}--dry${end} ] [ ${greym}--local${end} ] [ ${greym}--license LICENSE_KEY${end} ] [ ${greym}--version${end} ]" 1>&2
    printf '  %-5s %-40s\n' "Options:" "" 1>&2
    printf '  %-5s %-18s %-40s\n' "    " "-l,  --license" "specifies your MaxMind license key" 1>&2
    printf '  %-5s %-18s %-40s\n' "    " "-o,  --local" "enables local mode, geo database must be provided locally." 1>&2
    printf '  %-5s %-18s %-40s\n' "    " "" "    ${greym}does not require MaxMind license key${end}" 1>&2
    printf '  %-5s %-18s %-40s\n' "    " "" "    ${greym}local geo .csv files OR .zip must be placed in folder ${blued}${app_dir_github}/${folder_source_local}${end}" 1>&2
    printf '  %-5s %-18s %-40s\n' "    " "-d,  --dry" "runs a dry run of loading csv files from ${blued}${app_dir_github}/${folder_source_local}${end} folder" 1>&2
    printf '  %-5s %-18s %-40s\n' "    " "" "    ${greym}requires you place ${greenl}${file_source_csv_zip}${end} and ${greenl}${file_source_csv_zip_md5}${end} files in ${blued}${app_dir_github}/${folder_source_local}${end} folder${end}" 1>&2
    printf '  %-5s %-18s %-40s\n' "    " "-c,  --color" "displays a demo of the available colors" 1>&2
    printf '  %-5s %-18s %-40s\n' "    " "" "    ${greym}only needed by developer${end}" 1>&2
    printf '  %-5s %-18s %-40s\n' "    " "-g,  --graph" "displays a demo bash color graph" 1>&2
    printf '  %-5s %-18s %-40s\n' "    " "" "    ${greym}only needed by developer${end}" 1>&2
    printf '  %-5s %-18s %-40s\n' "    " "-d,  --dev" "dev mode" 1>&2
    printf '  %-5s %-18s %-40s\n' "    " "-p,  --path" "list of paths associated to script" 1>&2
    printf '  %-5s %-18s %-40s\n' "    " "-h,  --help" "show help menu" 1>&2
    printf '  %-5s %-18s %-40s\n' "    " "" "    ${greym}not required when using local mode${end}" 1>&2
    printf '  %-5s %-18s %-40s\n' "    " "-u,  --usage" "how to use this script" 1>&2
    printf '  %-5s %-18s %-40s\n' "    " "-v,  --version" "current version of ${app_file_this}" 1>&2
    echo
    echo
    exit 1
}

# #
#   Display help text if command not complete
# #

while [ $# -gt 0 ]; do
    case "$1" in
        -u|--usage)
                echo -e
                echo -e "  ${white}To use this script, use one of the following methods:\n"
                echo -e "  ${greenl}${bold}   License Key / Normal Mode${end}"
                echo -e "  ${greyl}${bold}   This method requires no files to be added. The geographical files will be downloaded from the${end}"
                echo -e "  ${greyl}${bold}   MaxMind website / servers.${end}"
                echo -e "  ${blued}         ./${app_file_this} -l ABCDEF1234567-01234${end}"
                echo -e "  ${blued}         ./${app_file_this} -l ABCDEF1234567-01234${end}"
                echo -e
                echo -e
                echo -e "  ${greenl}${bold}   Local Mode .................................................................................................. ${dim}[ Option 1 ]${end}"
                echo -e "  ${greyl}   This mode allows you to use local copies of the GeoLite2 database files to generate an IP list instead of${end}"
                echo -e "  ${greyl}   downloading a fresh copy of the .CSV / .ZIP files from the MaxMind website. This method requires you to${end}"
                echo -e "  ${greyl}   place the .ZIP, and .ZIP.MD5 file in the folder ${orangel}${app_dir_this_dir}/${folder_source_local}${end}"
                echo -e
                echo -e "  ${greyl}${bold}   Download the following files from the MaxMind website: ${end}"
                echo -e "  ${blued}         https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country-CSV&license_key=LICENSE_KEY&suffix=zip${end}"
                echo -e "  ${blued}         https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country-CSV&license_key=LICENSE_KEY&suffix=zip.md5${end}"
                echo -e
                echo -e "  ${greyl}${bold}   Place the ${greend}.ZIP${end} and ${greend}.ZIP.MD5${end} files in: ${end}"
                echo -e "  ${blued}         ${app_dir_this_dir}/${folder_source_local}${end}"
                echo -e
                echo -e "  ${greyl}${bold}   The filenames MUST be: ${end}"
                echo -e "  ${blued}         ${app_dir_this_dir}/${folder_source_local}/GeoLite2-Country-CSV.zip${end}"
                echo -e "  ${blued}         ${app_dir_this_dir}/${folder_source_local}/GeoLite2-Country-CSV.zip.md5${end}"
                echo -e
                echo -e "  ${greyl}${bold}   Run the following command: ${end}"
                echo -e "  ${blued}         ./${app_file_this} --local${end}"
                echo -e "  ${blued}         ./${app_file_this} -o${end}"
                echo -e
                echo -e
                echo -e "  ${greenl}${bold}   Local Mode .................................................................................................. ${dim}[ Option 2 ]${end}"
                echo -e "  ${greyl}   This mode allows you to use local copies of the GeoLite2 database files to generate an IP list instead of${end}"
                echo -e "  ${greyl}   downloading a fresh copy of the .ZIP files from the MaxMind website. This method requires you to extract${end}"
                echo -e "  ${greyl}   the .ZIP and place the .CSV files in the folder ${orangel}${app_dir_this_dir}/${folder_source_local}${end}"
                echo -e
                echo -e "  ${greyl}${bold}   Download the following file from the MaxMind website: ${end}"
                echo -e "  ${blued}         https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country-CSV&license_key=LICENSE_KEY&suffix=zip${end}"
                echo -e
                echo -e "  ${greyl}${bold}   Open the .ZIP and extract the following files to the folder ${orangel}${app_dir_this_dir}/${folder_source_local}${end}"
                echo -e "  ${blued}         ${app_dir_this_dir}/${folder_source_local}/GeoLite2-Country-Locations-en.csv${end}"
                echo -e "  ${blued}         ${app_dir_this_dir}/${folder_source_local}/GeoLite2-Country-Blocks-IPv4.csv${end}"
                echo -e "  ${blued}         ${app_dir_this_dir}/${folder_source_local}/GeoLite2-Country-Blocks-IPv6.csv${end}"
                echo -e
                echo -e "  ${greyl}${bold}   Run the following command: ${end}"
                echo -e "  ${blued}         ./${app_file_this} --local${end}"
                echo -e "  ${blued}         ./${app_file_this} -o${end}"
                echo -e
                echo -e
                echo -e "  ${greenl}${bold}   Dry Run .....................................................................................................${end}"
                echo -e "  ${greyl}   This mode allows you to simulate downloading the .ZIP files from the MaxMind website. However, the CURL${end}"
                echo -e "  ${greyl}   commands will not actually be ran. Instead, the script will look for the needed database files in the ${end}"
                echo -e "  ${greyl}   ${folder_target_temp} folder. This method requires you to place either the .ZIP & .ZIP.MD5 files, or extracted CSV files${end}"
                echo -e "  ${greyl}   in the folder ${orangel}${app_dir_this_dir}/${folder_target_temp}${end}"
                echo -e
                echo -e "  ${greyl}${bold}   Place the .ZIP & .ZIP.MD5 file, OR the .CSV files in the folder ${orangel}${app_dir_this_dir}/${folder_target_temp}${end}"
                echo -e "  ${blued}         ${app_dir_this_dir}/${folder_target_temp}/GeoLite2-Country-Locations-en.csv${end}"
                echo -e "  ${blued}         ${app_dir_this_dir}/${folder_target_temp}/GeoLite2-Country-Blocks-IPv4.csv${end}"
                echo -e "  ${blued}         ${app_dir_this_dir}/${folder_target_temp}/GeoLite2-Country-Blocks-IPv6.csv${end}"
                echo -e
                echo -e "  ${blued}         ${app_dir_this_dir}/${folder_target_temp}/GeoLite2-Country-CSV.zip${end}"
                echo -e "  ${blued}         ${app_dir_this_dir}/${folder_target_temp}/GeoLite2-Country-CSV.zip.md5${end}"
                echo -e
                echo -e "  ${greyl}${bold}   Run the following command: ${end}"
                echo -e "  ${blued}         ./${app_file_this} --dry${end}"
                echo -e "  ${blued}         ./${app_file_this} -d${end}"
                echo -e
                exit 1
            ;;

        -p|--paths)
                echo -e
                echo -e "  ${white}List of paths important to this script:\n"
                echo -e "  ${greenl}${bold}${orangel}${app_dir_this_dir}/${folder_source_local}${end}${end}"
                echo -e "  ${greyl}Folder used when Local Mode enabled (${greend}--local${end})${end}"
                echo -e "  ${greym}    Can detect GeoLite2 ${blued}.ZIP${greym} and ${blued}.ZIP.MD5${greym} files${end}"
                echo -e "  ${greym}    Can detect GeoLite2 ${blued}.CSV${greym} location and IPv4/IPv6 files${end}"
                echo -e
                echo -e
                echo -e "  ${greenl}${bold}${orangel}${app_dir_this_dir}/${folder_target_temp}${end}${end}"
                echo -e "  ${greyl}Folder used when Dry Run enabled (${greend}--dry${end})${end}"
                echo -e "  ${greym}    Can detect GeoLite2 ${blued}.ZIP${greym} and ${blued}.ZIP.MD5${greym} files${end}"
                echo -e "  ${greym}    Can detect GeoLite2 ${blued}.CSV${greym} location and IPv4/IPv6 files${end}"
                echo -e
                echo -e
                echo -e "  ${greenl}${bold}${orangel}${app_dir_this_dir}/${folder_target_cache}${end}${end}"
                echo -e "  ${greyl}Folder used to store associative array for continents and countries${end}"
                echo -e
                echo -e
                exit 1
            ;;

        -l|--license|--key)
            case "$1" in
                *=*)
                    argMMLicense=$(echo "$1" | cut -d= -f2)
                    ;;
                *)
                    shift
                    argMMLicense="$1"
                    info "     ⚙️ License specified ${greym}${argMMLicense}"
                    ;;
            esac

            if [ -z "${argMMLicense}" ]; then
                echo
                echo "  Specifies your MaxMind license key."
                echo "  Required if you are not running the script in local mode."
                echo "  Example: ./${app_file_this} -l ABCDEF1234567-01234"
                echo
                exit 1
            fi
            ;;

        -L|--limit)
            case "$1" in
                *=*)
                    argLimitEntries=$( echo "$1" | cut -d= -f2 )
                    ;;
                *)
                    shift
                    argLimitEntries="$1"
                    info "    ⚙️  Specified limit ${greenl}${argLimitEntries}"
                    ;;
            esac
            ;;

        -d|--dev)
            argDevMode=true
            info "    ⚙️  Developer Mode ${greenl}enabled"
            ;;

        -o|--local)
            argUseLocalDB=true
            info "    ⚙️  Local Mode ${greenl}enabled"
            ;;
    
        --dry|--dryrun)
            argDryrun=true
            info "    ⚙️  Dry-run Mode ${greenl}enabled"
            ;;

        -v|--version)
            echo
            echo "  ${blued}${bold}${app_name}${end} - v${app_ver} ${end}"
            echo "  ${greenl}${bold}https://github.com/${app_repo} ${end}"
            echo
            exit 1
            ;;

        -c|--color)
            debug_ColorTest
            exit 1
            ;;

        -g|--graph|--chart)
            debug_ColorChart
            exit 1
            ;;

        -\?|-h|--help)
            opt_usage
            exit 1
            ;;

        *)
            printf '%-28s %-65s\n' "  ${redl} ERROR ${end}" "${greym} Unknown parameter:${redl} $1 ${greym}. Aborting ${end}"
            exit 1
            ;;
    esac
    shift
done

# #
#   Define
# #

readonly CONFIGS_LIST="${file_source_csv_locs} ${file_source_csv_ipv4} ${file_source_csv_ipv6}"
declare -A map_country
declare -A map_continent

# #
#   Arguments
# #

ARG1=$1

if [ "$ARG1" == "clr" ] || [ "$ARG1" == "color" ]; then
    debug_ColorTest
    exit 1
fi

if [ "$ARG1" == "chart" ] || [ "$ARG1" == "graph" ]; then
    debug_ColorChart
    exit 1
fi

# #
#   Country codes
# #

get_country_name()
{
    local code=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    case "$code" in
        "ad") echo "Andorra" ;;
        "ae") echo "United Arab Emirates" ;;
        "af") echo "Afghanistan" ;;
        "ag") echo "Antigua Barbuda" ;;
        "ai") echo "Anguilla" ;;
        "al") echo "Albania" ;;
        "am") echo "Armenia" ;;
        "an") echo "Netherlands Antilles" ;;
        "ao") echo "Angola" ;;
        "ap") echo "Asia/Pacific Region" ;;
        "aq") echo "Antarctica" ;;
        "ar") echo "Argentina" ;;
        "as") echo "American Samoa" ;;
        "at") echo "Austria" ;;
        "au") echo "Australia" ;;
        "aw") echo "Aruba" ;;
        "ax") echo "Aland Islands" ;;
        "az") echo "Azerbaijan" ;;
        "ba") echo "Bosnia Herzegovina" ;;
        "bb") echo "Barbados" ;;
        "bd") echo "Bangladesh" ;;
        "be") echo "Belgium" ;;
        "bf") echo "Burkina Faso" ;;
        "bg") echo "Bulgaria" ;;
        "bh") echo "Bahrain" ;;
        "bi") echo "Burundi" ;;
        "bj") echo "Benin" ;;
        "bl") echo "Saint Barthelemy" ;;
        "bm") echo "Bermuda" ;;
        "bn") echo "Brunei Darussalam" ;;
        "bo") echo "Bolivia" ;;
        "bq") echo "Bonaire Sint Eustatius Saba" ;;
        "br") echo "Brazil" ;;
        "bs") echo "Bahamas" ;;
        "bt") echo "Bhutan" ;;
        "bv") echo "Bouvet Island" ;;
        "bw") echo "Botswana" ;;
        "by") echo "Belarus" ;;
        "bz") echo "Belize" ;;
        "ca") echo "Canada" ;;
        "cd") echo "Democratic Republic Congo" ;;
        "cf") echo "Central African Republic" ;;
        "cg") echo "Congo" ;;
        "ch") echo "Switzerland" ;;
        "ci") echo "Cote d'Ivoire" ;;
        "ck") echo "Cook Islands" ;;
        "cl") echo "Chile" ;;
        "cm") echo "Cameroon" ;;
        "cn") echo "China" ;;
        "co") echo "Colombia" ;;
        "cr") echo "Costa Rica" ;;
        "cu") echo "Cuba" ;;
        "cv") echo "Cape Verde" ;;
        "cw") echo "Curacao" ;;
        "cx") echo "Christmas Island" ;;
        "cy") echo "Cyprus" ;;
        "cz") echo "Czech Republic" ;;
        "de") echo "Germany" ;;
        "dj") echo "Djibouti" ;;
        "dk") echo "Denmark" ;;
        "dm") echo "Dominica" ;;
        "do") echo "Dominican Republic" ;;
        "dz") echo "Algeria" ;;
        "ec") echo "Ecuador" ;;
        "ee") echo "Estonia" ;;
        "eg") echo "Egypt" ;;
        "eh") echo "Western Sahara" ;;
        "er") echo "Eritrea" ;;
        "es") echo "Spain" ;;
        "et") echo "Ethiopia" ;;
        "eu") echo "Europe" ;;
        "fi") echo "Finland" ;;
        "fj") echo "Fiji" ;;
        "fk") echo "Falkland Islands Malvinas" ;;
        "fm") echo "Micronesia" ;;
        "fo") echo "Faroe Islands" ;;
        "fr") echo "France" ;;
        "ga") echo "Gabon" ;;
        "gb") echo "Great Britain" ;;
        "gd") echo "Grenada" ;;
        "ge") echo "Georgia" ;;
        "gf") echo "French Guiana" ;;
        "gg") echo "Guernsey" ;;
        "gh") echo "Ghana" ;;
        "gi") echo "Gibraltar" ;;
        "gl") echo "Greenland" ;;
        "gm") echo "Gambia" ;;
        "gn") echo "Guinea" ;;
        "gp") echo "Guadeloupe" ;;
        "gq") echo "Equatorial Guinea" ;;
        "gr") echo "Greece" ;;
        "gs") echo "South Georgia and the South Sandwich Islands" ;;
        "gt") echo "Guatemala" ;;
        "gu") echo "Guam" ;;
        "gw") echo "Guinea-Bissau" ;;
        "gy") echo "Guyana" ;;
        "hk") echo "Hong Kong" ;;
        "hn") echo "Honduras" ;;
        "hr") echo "Croatia" ;;
        "ht") echo "Haiti" ;;
        "hu") echo "Hungary" ;;
        "hm") echo "Heard Island and McDonald Islands" ;;
        "id") echo "Indonesia" ;;
        "ie") echo "Ireland" ;;
        "il") echo "Israel" ;;
        "im") echo "Isle of Man" ;;
        "in") echo "India" ;;
        "io") echo "British Indian Ocean Territory" ;;
        "iq") echo "Iraq" ;;
        "ir") echo "Iran" ;;
        "is") echo "Iceland" ;;
        "it") echo "Italy" ;;
        "je") echo "Jersey" ;;
        "jm") echo "Jamaica" ;;
        "jo") echo "Jordan" ;;
        "jp") echo "Japan" ;;
        "ke") echo "Kenya" ;;
        "kg") echo "Kyrgyzstan" ;;
        "kh") echo "Cambodia" ;;
        "ki") echo "Kiribati" ;;
        "km") echo "Comoros" ;;
        "kn") echo "Saint Kitts Nevis" ;;
        "kp") echo "North Korea" ;;
        "kr") echo "South Korea" ;;
        "kw") echo "Kuwait" ;;
        "ky") echo "Cayman Islands" ;;
        "kz") echo "Kazakhstan" ;;
        "la") echo "Laos" ;;
        "lb") echo "Lebanon" ;;
        "lc") echo "Saint Lucia" ;;
        "li") echo "Liechtenstein" ;;
        "lk") echo "Sri Lanka" ;;
        "lr") echo "Liberia" ;;
        "ls") echo "Lesotho" ;;
        "lt") echo "Lithuania" ;;
        "lu") echo "Luxembourg" ;;
        "lv") echo "Latvia" ;;
        "ly") echo "Libya" ;;
        "ma") echo "Morocco" ;;
        "mc") echo "Monaco" ;;
        "md") echo "Republic Moldova" ;;
        "me") echo "Montenegro" ;;
        "mf") echo "Saint Martin (North)" ;;
        "mg") echo "Madagascar" ;;
        "mh") echo "Marshall Islands" ;;
        "mk") echo "Macedonia Republic" ;;
        "ml") echo "Mali" ;;
        "mm") echo "Myanmar" ;;
        "mn") echo "Mongolia" ;;
        "mo") echo "Macao" ;;
        "mp") echo "Northern Mariana Islands" ;;
        "mq") echo "Martinique" ;;
        "mr") echo "Mauritania" ;;
        "ms") echo "Montserrat" ;;
        "mt") echo "Malta" ;;
        "mu") echo "Mauritius" ;;
        "mv") echo "Maldives" ;;
        "mw") echo "Malawi" ;;
        "mx") echo "Mexico" ;;
        "my") echo "Malaysia" ;;
        "mz") echo "Mozambique" ;;
        "na") echo "Namibia" ;;
        "ne") echo "Niger" ;;
        "ng") echo "Nigeria" ;;
        "nl") echo "Netherlands" ;;
        "no") echo "Norway" ;;
        "nc") echo "New Caledonia" ;;
        "ne") echo "Niger" ;;
        "nf") echo "Norfolk Island" ;;
        "ng") echo "Nigeria" ;;
        "ni") echo "Nicaragua" ;;
        "nl") echo "Netherlands" ;;
        "no") echo "Norway" ;;
        "np") echo "Nepal" ;;
        "nr") echo "Nauru" ;;
        "nu") echo "Niue" ;;
        "nz") echo "New Zealand" ;;
        "om") echo "Oman" ;;
        "pa") echo "Panama" ;;
        "pe") echo "Peru" ;;
        "pf") echo "French Polynesia" ;;
        "pg") echo "Papua New Guinea" ;;
        "ph") echo "Philippines" ;;
        "pk") echo "Pakistan" ;;
        "pl") echo "Poland" ;;
        "pm") echo "Saint Pierre Miquelon" ;;
        "pn") echo "Pitcairn" ;;
        "pr") echo "Puerto Rico" ;;
        "ps") echo "Palestine" ;;
        "pt") echo "Portugal" ;;
        "pw") echo "Palau" ;;
        "py") echo "Paraguay" ;;
        "qa") echo "Qatar" ;;
        "re") echo "Reunion" ;;
        "ro") echo "Romania" ;;
        "rs") echo "Serbia" ;;
        "ru") echo "Russia" ;;
        "rw") echo "Rwanda" ;;
        "sa") echo "Saudi Arabia" ;;
        "sb") echo "Solomon Islands" ;;
        "sc") echo "Seychelles" ;;
        "sd") echo "Sudan" ;;
        "se") echo "Sweden" ;;
        "sg") echo "Singapore" ;;
        "sh") echo "Saint Helena" ;;
        "si") echo "Slovenia" ;;
        "sj") echo "Svalbard Jan Mayen" ;;
        "sk") echo "Slovakia" ;;
        "sl") echo "Sierra Leone" ;;
        "sm") echo "San Marino" ;;
        "sn") echo "Senegal" ;;
        "so") echo "Somalia" ;;
        "ss") echo "South Sudan" ;;
        "sr") echo "Suriname" ;;
        "st") echo "Sao Tome Principe" ;;
        "sv") echo "El Salvador" ;;
        "sx") echo "Sint Maarten (South)" ;;
        "sy") echo "Syria" ;;
        "sz") echo "Eswatini" ;;
        "tc") echo "Turks Caicos Islands" ;;
        "td") echo "Chad" ;;
        "tf") echo "French Southern Territories" ;;
        "tg") echo "Togo" ;;
        "th") echo "Thailand" ;;
        "tj") echo "Tajikistan" ;;
        "tk") echo "Tokelau" ;;
        "tl") echo "Timor-Leste" ;;
        "tm") echo "Turkmenistan" ;;
        "tn") echo "Tunisia" ;;
        "to") echo "Tonga" ;;
        "tr") echo "Turkey" ;;
        "tt") echo "Trinidad Tobago" ;;
        "tv") echo "Tuvalu" ;;
        "tw") echo "Taiwan" ;;
        "tz") echo "Tanzania" ;;
        "ua") echo "Ukraine" ;;
        "ug") echo "Uganda" ;;
        "uk") echo "United Kingdom" ;;
        "um") echo "United States Minor Outlying Islands" ;;
        "us") echo "United States" ;;
        "uy") echo "Uruguay" ;;
        "uz") echo "Uzbekistan" ;;
        "va") echo "Vatican City Holy See" ;;
        "vc") echo "Saint Vincent Grenadines" ;;
        "ve") echo "Venezuela" ;;
        "vg") echo "British Virgin Islands" ;;
        "vi") echo "United States Virgin Islands" ;;
        "vn") echo "Vietnam" ;;
        "vu") echo "Vanuatu" ;;
        "wf") echo "Wallis Futuna" ;;
        "ws") echo "Samoa" ;;
        "xk") echo "Kosovo" ;;
        "ye") echo "Yemen" ;;
        "yt") echo "Mayotte" ;;
        "za") echo "South Africa" ;;
        "zm") echo "Zambia" ;;
        "zw") echo "Zimbabwe" ;;
        "zz") echo "Unknown" ;;
        # Add more cases for other country codes and names here
        *) echo "$code" | tr '[:lower:]' '[:upper:]' ;;
    esac
}

# #
#   continents > list
# #

declare -A continents
continents["AF"]="Africa"
continents["AN"]="Antartica"
continents["AS"]="Asia"
continents["EU"]="Europe"
continents["NA"]="North America"
continents["OC"]="Oceania"
continents["SA"]="South America"

# #
#   continent_africa.upset
# #

declare -A af
af["ao"]="AO"               # Angola
af["bf"]="BF"               # Burkina Faso
af["bi"]="BI"               # Burundi
af["bj"]="BJ"               # Benin
af["bw"]="BW"               # Botswana
af["cd"]="CD"               # DR Congo
af["cf"]="CF"               # Central African Republic
af["cg"]="CG"               # Congo Republic
af["ci"]="CI"               # Ivory Coast
af["cm"]="CM"               # Cameroon
af["cv"]="CV"               # Cabo Verde
af["dj"]="DJ"               # Djibouti
af["dz"]="DZ"               # Algeria
af["eg"]="EG"               # Egypt
af["eh"]="EH"               # Western Sahara
af["er"]="ER"               # Eritrea
af["et"]="ET"               # Ethiopia
af["ga"]="GA"               # Gabon
af["gh"]="GH"               # Ghana
af["gm"]="GM"               # Gambia
af["gn"]="GN"               # Guinea
af["gq"]="GQ"               # Equatorial Guinea
af["gw"]="GW"               # Guinea-Bissau
af["ke"]="KE"               # Kenya
af["km"]="KM"               # Comoros
af["lr"]="LR"               # Liberia
af["ls"]="LS"               # Lesotho
af["ly"]="LY"               # Libya
af["ma"]="MA"               # Morocco
af["mg"]="MG"               # Madagascar
af["ml"]="ML"               # Mali
af["mr"]="MR"               # Mauritania
af["mu"]="MU"               # Mauritius
af["mw"]="MW"               # Malawi
af["mz"]="MZ"               # Mozambique
af["na"]="NA"               # Namibia
af["ne"]="NE"               # Niger
af["ng"]="NG"               # Nigeria
af["re"]="RE"               # Réunion
af["rw"]="RW"               # Rwanda
af["sc"]="SC"               # Seychelles
af["sd"]="SD"               # Sudan
af["sh"]="SH"               # Saint Helena
af["sl"]="SL"               # Sierra Leone
af["sn"]="SN"               # Senegal
af["so"]="SO"               # Somalia
af["ss"]="SS"               # South Sudan
af["st"]="ST"               # São Tomé and Príncipe
af["sz"]="SZ"               # Eswatini
af["tg"]="TG"               # Togo
af["tn"]="TN"               # Tunisia
af["tz"]="TZ"               # Tanzania
af["ug"]="UG"               # Uganda
af["yt"]="YT"               # Mayotte
af["za"]="ZA"               # South Africa
af["zm"]="ZM"               # Zambia
af["zw"]="ZW"               # Zimbabwe

# #
#   continent_antarctica.upset
# #

declare -A an
an["aq"]="AQ"               # Antarctica
an["bv"]="BV"               # Bouvet Island
an["gs"]="GS"               # South Georgia and the South Sandwich Islands
an["hm"]="HM"               # Heard Island and McDonald Islands
an["tf"]="TF"               # French Southern Territories

# #
#   continent_asia.upset
# #

declare -A as
as["ae"]="AE"               # United Arab Emirates
as["af"]="AF"               # Afghanistan
as["am"]="AM"               # Armenia
as["az"]="AZ"               # Azerbaijan
as["bd"]="BD"               # Bangladesh
as["bh"]="BH"               # Bahrain
as["bn"]="BN"               # Brunei
as["bt"]="BT"               # Bhutan
as["cn"]="CN"               # China
as["ge"]="GE"               # Georgia
as["hk"]="HK"               # Hong Kong
as["id"]="ID"               # Indonesia
as["il"]="IL"               # Israel
as["in"]="IN"               # India
as["io"]="IO"               # British Indian Ocean Territory
as["iq"]="IQ"               # Iraq
as["ir"]="IR"               # Iran
as["jo"]="JO"               # Jordan
as["jp"]="JP"               # Japan
as["kg"]="KG"               # Kyrgyzstan
as["kh"]="KH"               # Cambodia
as["kp"]="KP"               # North Korea
as["kr"]="KR"               # South Korea
as["kw"]="KW"               # Kuwait
as["kz"]="KZ"               # Kazakhstan
as["la"]="LA"               # Laos
as["lb"]="LB"               # Lebanon
as["lk"]="LK"               # Sri Lanka
as["mm"]="MM"               # Myanmar
as["mn"]="MN"               # Mongolia
as["mo"]="MO"               # Macao
as["mv"]="MV"               # Maldives
as["my"]="MY"               # Malaysia
as["np"]="NP"               # Nepal
as["om"]="OM"               # Oman
as["ph"]="PH"               # Philippines
as["pk"]="PK"               # Pakistan
as["ps"]="PS"               # Palestine
as["qa"]="QA"               # Qatar
as["sa"]="SA"               # Saudi Arabia
as["sg"]="SG"               # Singapore
as["sy"]="SY"               # Syria
as["th"]="TH"               # Thailand
as["tj"]="TJ"               # Tajikistan
as["tm"]="TM"               # Turkmenistan
as["tr"]="TR"               # Turkey
as["tw"]="TW"               # Taiwan
as["uz"]="UZ"               # Uzbekistan
as["vn"]="VN"               # Vietnam
as["ye"]="YE"               # Yemen

# #
#   continent_europe.upset
# #

declare -A eu
eu["ad"]="AD"               # Andorra
eu["al"]="AL"               # Albania
eu["at"]="AT"               # Austria
eu["ax"]="AX"               # Aland
eu["ba"]="BA"               # Bosnia and Herzegovina
eu["be"]="BE"               # Belgium
eu["bg"]="BG"               # Bulgaria
eu["by"]="BY"               # Belarus
eu["ch"]="CH"               # Switzerland
eu["cy"]="CY"               # Cyprus
eu["cz"]="CZ"               # Czechia
eu["de"]="DE"               # Germany
eu["dk"]="DK"               # Denmark
eu["ee"]="EE"               # Estonia
eu["es"]="ES"               # Spain
eu["fi"]="FI"               # Finland
eu["fo"]="FO"               # Faroe Islands
eu["fr"]="FR"               # France
eu["gb"]="GB"               # United Kingdom
eu["gg"]="GG"               # Guernsey
eu["sm"]="SM"               # San Marino
eu["gi"]="GI"               # Gibraltar
eu["gr"]="GR"               # Greece
eu["hr"]="HR"               # Croatia
eu["hu"]="HU"               # Hungary
eu["ie"]="IE"               # Ireland
eu["im"]="IM"               # Isle of Man
eu["is"]="IS"               # Iceland
eu["it"]="IT"               # Italy
eu["je"]="JE"               # Jersey
eu["li"]="LI"               # Liechtenstein
eu["lt"]="LT"               # Republic of Lithuania
eu["lu"]="LU"               # Luxembourg
eu["lv"]="LV"               # Latvia
eu["mc"]="MC"               # Monaco
eu["md"]="MD"               # Republic of Moldova
eu["me"]="ME"               # Montenegro
eu["mk"]="MK"               # North Macedonia
eu["mt"]="MT"               # Malta
eu["nl"]="NL"               # Netherlands
eu["no"]="NO"               # Norway
eu["pl"]="PL"               # Poland
eu["pt"]="PT"               # Portugal
eu["ro"]="RO"               # Romania
eu["rs"]="RS"               # Serbia
eu["ru"]="RU"               # Russia
eu["se"]="SE"               # Sweden
eu["si"]="SI"               # Slovenia
eu["sj"]="SJ"               # Svalbard and Jan Mayen
eu["sk"]="SK"               # Slovakia
eu["ua"]="UA"               # Ukraine
eu["va"]="VA"               # Vatican City
eu["xk"]="XK"               # Kosovo

# #
#   continent_north_america.upset
# #

declare -A na
na["ag"]="AG"               # Antigua and Barbuda
na["ai"]="AI"               # Anguilla
na["aw"]="AW"               # Aruba
na["bb"]="BB"               # Barbados
na["bl"]="BL"               # Saint Barthélemy
na["bm"]="BM"               # Bermuda
na["bq"]="BQ"               # Bonaire Sint Eustatius and Saba
na["bs"]="BS"               # Bahamas
na["bz"]="BZ"               # Belize
na["ca"]="CA"               # Canada
na["cr"]="CR"               # Costa Rica
na["cu"]="CU"               # Cuba
na["cw"]="CW"               # Curaçao
na["dm"]="DM"               # Dominica
na["do"]="DO"               # Dominican Republic
na["gd"]="GD"               # Grenada
na["gl"]="GL"               # Greenland
na["gp"]="GP"               # Guadeloupe
na["gt"]="GT"               # Guatemala
na["hn"]="HN"               # Honduras
na["ht"]="HT"               # Haiti
na["jm"]="JM"               # Jamaica
na["kn"]="KN"               # St Kitts and Nevis
na["ky"]="KY"               # Cayman Islands
na["lc"]="LC"               # Saint Lucia
na["mf"]="MF"               # Saint Martin
na["mq"]="MQ"               # Martinique
na["ms"]="MS"               # Montserrat
na["mx"]="MX"               # Mexico
na["ni"]="NI"               # Nicaragua
na["pa"]="PA"               # Panama
na["pm"]="PM"               # Saint Pierre and Miquelon
na["pr"]="PR"               # Puerto Rico
na["sv"]="SV"               # El Salvador
na["sx"]="SX"               # Sint Maarten
na["tc"]="TC"               # Turks and Caicos Islands
na["tt"]="TT"               # Trinidad and Tobago
na["us"]="US"               # United States
na["vc"]="VC"               # Saint Vincent and the Grenadines
na["vg"]="VG"               # British Virgin Islands
na["vi"]="VI"               # U.S. Virgin Islands

# #
#   continent_oceania.upset
# #

declare -A oc
oc["as"]="AS"               # American Samoa
oc["au"]="AU"               # Australia
oc["ck"]="CK"               # Cook Islands
oc["cx"]="CX"               # Christmas Island
oc["fj"]="FJ"               # Fiji
oc["fm"]="FM"               # Federated States of Micronesia
oc["ki"]="KI"               # Kiribati
oc["mh"]="MH"               # Marshall Islands
oc["mp"]="MP"               # Northern Mariana Islands
oc["nc"]="NC"               # New Caledonia
oc["nf"]="NF"               # Norfolk Island
oc["nr"]="NR"               # Nauru
oc["nu"]="NU"               # Niue
oc["nz"]="NZ"               # New Zealand
oc["pf"]="PF"               # French Polynesia
oc["pg"]="PG"               # Papua New Guinea
oc["pn"]="PN"               # Pitcairn Islands
oc["pw"]="PW"               # Palau
oc["sb"]="SB"               # Solomon Islands
oc["tk"]="TK"               # Tokelau
oc["tl"]="TL"               # East Timor
oc["to"]="TO"               # Tonga
oc["tv"]="TV"               # Tuvalu
oc["um"]="UM"               # U.S. Minor Outlying Islands
oc["vu"]="VU"               # Vanuatu
oc["wf"]="WF"               # Wallis and Futuna
oc["ws"]="GU"               # Guam
oc["ws"]="WS"               # Samoa

# #
#   continent_south_america.upset
# #

declare -A sa
sa["ar"]="AR"               # Argentina
sa["bo"]="BO"               # Bolivia
sa["br"]="BR"               # Brazil
sa["cl"]="CL"               # Chile
sa["co"]="CO"               # Colombia
sa["ec"]="EC"               # Ecuador
sa["fk"]="FK"               # Falkland Islands
sa["gf"]="GF"               # French Guiana
sa["gy"]="GY"               # Guyana
sa["pe"]="PE"               # Peru
sa["py"]="PY"               # Paraguay
sa["sr"]="SR"               # Suriname
sa["uy"]="UY"               # Uruguay
sa["ve"]="VE"               # Venezuela

# #
#   Sort Results
#   
#   @usage          line=$(parse_spf_record "${ip}" | sort_results)
# #

sort_results()
{

    # Temp files for IPv4 and IPv6
    _ipv4_tmp=$(mktemp) || exit 1
    _ipv6_tmp=$(mktemp) || exit 1

    # Read stdin line by line
    while IFS= read -r line; do
        case "$line" in
            *:*)
                printf '%s\n' "$line" >> "$_ipv6_tmp" ;;
            *)
                printf '%s\n' "$line" >> "$_ipv4_tmp" ;;
        esac
    done

    # Sort IPv4 numerically, remove duplicates
    if [ -s "$_ipv4_tmp" ]; then
        sort -t. -n -k1,1 -k2,2 -k3,3 -k4,4 "$_ipv4_tmp" | uniq
    fi

    # Sort IPv6 lexicographically, remove duplicates
    if [ -s "$_ipv6_tmp" ]; then
        sort "$_ipv6_tmp" | uniq
    fi

    # Clean up temp files
    rm -f "$_ipv4_tmp" "$_ipv6_tmp"

    # #
    #   Unset
    # #

    unset   _ipv4_tmp _ipv6_tmp
}

# #
#   Count file statistics
#       - IPv4 CIDR contributes all IPv4 addresses in the subnet
#       - IPv6 CIDR contributes one entry (do not expand)
#       - Single IPv4/IPv6 contributes one entry
# #

count_ip_stats( )
{
    _fnCountFile=$1
    _fnSubnetIps=0
    _fnTotalIps=0
    _fnTotalSubnets=0

    while IFS= read -r _fnLine; do

        # #
        #   IPv4 CIDR
        # #

        if [[ $_fnLine =~ $regex_ipv4_cidr ]]; then
            _fnCidr="${BASH_REMATCH[2]}"
            if [ "$_fnCidr" -le 32 ]; then
                _fnSubnetIps=$(( 1 << (32 - _fnCidr) ))
                _fnTotalIps=$(( _fnTotalIps + _fnSubnetIps ))
                _fnTotalSubnets=$(( _fnTotalSubnets + 1 ))
            fi

        # #
        #   IPv4 single
        # #

        elif [[ $_fnLine =~ $regex_ipv4 ]]; then
            _fnTotalIps=$(( _fnTotalIps + 1 ))

        # #
        #   IPv6 CIDR (count as one entry, do not expand)
        # #

        elif [[ $_fnLine =~ $regex_ipv6_cidr ]]; then
            _fnCidr="${_fnLine#*/}"
            if [ "$_fnCidr" -le 128 ]; then
                _fnTotalIps=$(( _fnTotalIps + 1 ))
                _fnTotalSubnets=$(( _fnTotalSubnets + 1 ))
            fi

        # #
        #   IPv6 single
        # #

        elif [[ $_fnLine =~ $regex_ipv6 ]] && [[ $_fnLine == *:* ]]; then
            _fnTotalIps=$(( _fnTotalIps + 1 ))
        fi

    done < "${_fnCountFile}"

    total_ips=$_fnTotalIps
    total_subnets=$_fnTotalSubnets

    # #
    #   Unset
    # #

    unset   _fnCountFile _fnSubnetIps _fnTotalIps _fnTotalSubnets _fnLine _fnCidr
}

# #
#   Print › Box › Paragraph
#   
#   Places an ASCII box around text. Supports multi-lines with \n, and also emojis.
#   Func determines the character count if color codes are used and ensures that
#       the box borders are aligned properly.
#   
#   If using emojis; adjust the spacing so that the far-right line will align
#       with the rest. Add the number of spaces to increase the value, which is
#       represented with a number enclosed in square brackets.
#           [1]     add 1 space to the right.
#           [2]     add 2 spaces to the right.
#           [-1]    remove 1 space to the right (needed for some emojis depending on if the emoji is 1 or 2 bytes)
#   
#   You can also hide the last verticle scrollbar by appending the bool "false" as the latest argument.
#       prinp "🎌[41] Finished!" false
#   
#   @usage          prinp "Certificate Generation Successful" "Your new certificate and keys have been generated successfully.\n\nYou can find them in the ${greenl}${app_dir_output}${greyd} folder."
#                   prinp "🎗️[1]  ${file_domain_base}" "The following description will show on multiple lines with a ASCII box around it."
#                   prinp "📄[-1] File Overview" "The following list outlines the files that you have generated using this utility, and what certs/keys may be missing."
#                   prinp "➡️[15]  ${bluel}Paths${end}"
#   
#   @arg    title   Text to show in box.
#           false   (optional) hide right-side │ on title line
#                   prinp "Title" false
#                   prinp "Title" false "Body text"
# #

prinp()
{
    _title="$1"
    _show_right_border=true

    if [ "$2" = "false" ]; then
        _show_right_border=false
        shift 2
    else
        shift
    fi

    _text="$*"
    _indent="  "
    _box_width=110
    _pad=1
    _content_width=$(( _box_width ))
    _inner_width=$(( _box_width - _pad*2 ))
    _hline=$(printf '─%.0s' $(seq 1 "$_content_width"))
    _emoji_adjust=0

    print
    printf "${greyd}%s┌%s┐\n" "$_indent" "$_hline"

    # #
    #   Title
    #   
    #   Extract optional [N] adjustment from title (signed integer), portably
    # #

    _display_title="$_title"

    # #
    #   Get content inside first [...] (if present)
    # #

    if printf '%s\n' "$_title" | grep -q '\[[[:space:]]*[-0-9][-0-9[:space:]]*\]'; then

        # #
        #   Extract numeric inside brackets (allow optional leading -)
        #       - use sed to capture first bracketed token, then strip non-digit except leading -
        # #

        _bracket=$(printf '%s' "$_title" | sed -n 's/.*\[\([-0-9][-0-9]*\)\].*/\1/p')

        # #
        #   Validate numeric and assign, otherwise fallback to 0
        # #
    
        if printf '%s\n' "$_bracket" | grep -qE '^-?[0-9]+$'; then
            _emoji_adjust=$_bracket
        else
            _emoji_adjust=0
        fi

        # #
        #   Remove the first [...] token from the display_title
        # #
    
        _display_title=$(printf '%s' "$_title" | sed 's/\[[^]]*\]//')
    fi

    # #
    #   Ensure emoji_adjust is a decimal integer so math works
    # #

    case "$_emoji_adjust" in
        ''|*[!0-9-]*)
            _emoji_adjust=0
            ;;
    esac

    _title_width=$(( _content_width - _pad ))

    # #
    #   Account for emoji adjustment in visible length calculation
    #   Inner line containing content and trailing |
    # #
  
    _title_vis_len=$(( ${#_display_title} - _emoji_adjust ))

    if [ "$_show_right_border" = "true" ]; then
        printf "${greyd}%s│%*s${bluel}%s${greyd}%*s│\n" \
            "$_indent" "$_pad" "" "$_display_title" "$(( _title_width - _title_vis_len ))" ""
    else
        printf "${greyd}%s│%*s${bluel}%s\n" \
            "$_indent" "$_pad" "" "$_display_title"
    fi

    # #
    #   Only render body text if provided
    # #

    if [ -n "$_text" ]; then
        printf "${greyd}%s│%-${_content_width}s│\n" "$_indent" ""

        # #
        #   Convert literal \n to real newlines
        # #

        _text=$(printf "%b" "$_text")

        # #
        #   Handle each line with ANSI-aware wrapping and true padding
        # #

        printf "%s" "$_text" | while IFS= read -r line || [ -n "$line" ]; do

        # #
        #   Blank line
        # #
    
        if [ -z "$line" ]; then
            printf "${greyd}%s│%-*s│\n" "$_indent" "$_content_width" ""
            continue
        fi

        # #
        #   Optional [N] spacing adjustment in body line (same thing done for title)
        # #    

        _line_emoji_adjust=0
        if printf '%s\n' "$line" | grep -q '\[[[:space:]]*[-0-9][-0-9[:space:]]*\]'; then
            _line_bracket=$(printf '%s' "$line" | sed -n 's/.*\[\([-0-9][-0-9]*\)\].*/\1/p')

            if printf '%s\n' "$_line_bracket" | grep -qE '^-?[0-9]+$'; then
                _line_emoji_adjust=$_line_bracket
            else
                _line_emoji_adjust=0
            fi

            line=$(printf '%s' "$line" | sed 's/\[[^]]*\]//')
        fi

        case "$_line_emoji_adjust" in
            ''|*[!0-9-]*)
                _line_emoji_adjust=0
                ;;
        esac

        _out=""
        for word in $line; do

            # #
            #   Strip ANSI for visible width
            # #
        
            _vis_out=$(printf "%s" "$_out" | sed 's/\x1B\[[0-9;]*[A-Za-z]//g')
            _vis_word=$(printf "%s" "$word" | sed 's/\x1B\[[0-9;]*[A-Za-z]//g')
            _vis_len=$(( ${#_vis_out} + ( ${#_vis_out} > 0 ? 1 : 0 ) + ${#_vis_word} - _line_emoji_adjust ))

            if [ -z "$_out" ]; then
                _out="$word"
            elif [ $_vis_len -le $_inner_width ]; then
                _out="$_out $word"
            else

                # #
                #   Print and pad manually based on visible length
                # #

                _vis_len_full=$(printf "%s" "$_out" | sed 's/\x1B\[[0-9;]*[A-Za-z]//g' | wc -c | tr -d ' ')
                _vis_len_full=$(( _vis_len_full - _line_emoji_adjust ))
                [ $_vis_len_full -lt 0 ] && _vis_len_full=0
                _pad_spaces=$(( _inner_width - _vis_len_full ))
                [ $_pad_spaces -lt 0 ] && _pad_spaces=0
                printf "${greyd}%s│%*s%s%*s│\n" "$_indent" "$_pad" "" "$_out" "$(( _pad + _pad_spaces ))" ""
                _out="$word"
            fi
        done

        # #
        #   Final flush line
        # #
    
        if [ -n "$_out" ]; then
            _vis_len_full=$(printf "%s" "$_out" | sed 's/\x1B\[[0-9;]*[A-Za-z]//g' | wc -c | tr -d ' ')
            _vis_len_full=$(( _vis_len_full - _line_emoji_adjust ))
            [ $_vis_len_full -lt 0 ] && _vis_len_full=0
            _pad_spaces=$(( _inner_width - _vis_len_full ))
            [ $_pad_spaces -lt 0 ] && _pad_spaces=0
            printf "${greyd}%s│%*s%s%*s│\n" "$_indent" "$_pad" "" "$_out" "$(( _pad + _pad_spaces ))" ""
        fi

        done
    fi

    printf "${greyd}%s└%s┘${end}\n" "$_indent" "$_hline"
    print

    # #
    #   Unset
    # #

    unset   _title _title_width _text _indent _pad _padding _content_width \
            _title_length _inner_width _box_width _emoji_adjust \
            _hline _line _out _i _display_title _vis_out _vis_word _vis_len _vis_len_full \
            _line_bracket _line_emoji_adjust _pad_spaces _bracket \
            _show_right_border
}

# #
#   Ensure the programs needed to execute are available
# #

required_Packages()
{
    PKG="awk cat curl sed md5sum mktemp unzip"

    for cmd in $PKG; do
        if ! command -v "${cmd}" >/dev/null 2>&1; then
            error "    ❌ Required dependency not found in PATH: ${redl}${cmd}"
        fi
    done
}

# #
#   Get latest MaxMind GeoLite2 IP Country database and md5 checksum
#       CSV URL: https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country-CSV&license_key=LICENSE_KEY&suffix=zip
#       MD5 URL: https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country-CSV&license_key=LICENSE_KEY&suffix=zip.md5
#   
#   If using --dry, you must manually download the .zip and .zip.md5 files and place them in the local folder assigned to the value
#       $folder_source_local
# #

maxmind_Database_Download( )
{
    echo
    info "    📦 Setup MaxMind databases${greym}"

    local URL_CSV="https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country-CSV&license_key=${argMMLicense}&suffix=zip"
    local URL_MD5="${URL_CSV}.md5" # take URL_CSV value and add .md5 to end for hash file

    # #
    #   Ensure download output paths are always defined.
    #   If no local wildcard match was found earlier, default to filenames in TEMPDIR.
    # #

    if [ -z "${file_source_csv_zip:-}" ]; then
        file_source_csv_zip="GeoLite2-Country-CSV.zip"
    fi

    if [ -z "${file_source_csv_zip_md5:-}" ]; then
        file_source_csv_zip_md5="${file_source_csv_zip}.md5"
    fi

    # #
    #   download files
    #       - will not download if --dryrun specified
    #       - will not download if --local specified
    # #

    if [ "${argDryrun}" != "true" ] && [ "${argUseLocalDB}" != "true" ]; then
        URL_HIDDEN_CSV=$(printf '%s\n' "${URL_CSV}" | sed "s/${argMMLicense}/HIDDEN/g")
        URL_HIDDEN_MD5=$(printf '%s\n' "${URL_MD5}" | sed "s/${argMMLicense}/HIDDEN/g")

        info "    🌎 Downloading ${bluel}${file_source_csv_zip}${end} from ${bluel}${URL_HIDDEN_CSV}"
        if ! curl --silent --show-error --location \
                --user-agent "${app_agent}" \
                --output "${file_source_csv_zip}" "${URL_CSV}"
        then
            error "    ❌ Failed to curl database files from ${redl}${URL_HIDDEN_CSV}${greym}"
        fi

        info "    🌎 Downloading ${bluel}${file_source_csv_zip_md5}${end} from ${bluel}${URL_HIDDEN_MD5}"
        if ! curl --silent --show-error --location \
                --user-agent "${app_agent}" \
                --output "${file_source_csv_zip_md5}" "${URL_MD5}"
        then
            error "    ❌ Failed to curl database files from ${redl}${URL_HIDDEN_MD5}${greym}"
        fi
    fi

    # #
    #   .CSV missing, warn user to provide one or the other
    # #

    if [ ! -f "${file_source_csv_zip}" ] && [ ! -f ${file_source_csv_locs} ]; then
        error "    ❌ Must supply zip ${redl}${file_source_csv_zip}${greym} + md5 ${redl}${file_source_csv_zip_md5}${greym}, or the extracted CSV files ${redd}${file_source_csv_locs}${greym}; cannot locate"
        exit 0
    fi

    # #
    #   Provided the .ZIP, but not the ZIP hash file
    # #

    if [ -f "${file_source_csv_zip}" ] && [ ! -f "${file_source_csv_zip_md5}" ]; then
        error "    ❌ You supplied zip ${redl}${file_source_csv_zip}${greym}, but did not provide the md5 file ${redl}${file_source_csv_zip_md5}${greym}; cannot continue"
        exit 0
    fi

    # #
    #   Provided the LOCATIONS csv file, but may be missing the others
    # #

    if [ -f "${file_source_csv_locs}" ]; then
        if [ ! -f "${file_source_csv_ipv4}" ]; then
            error "    ❌ You provided the LOCATION CSV ${redl}${file_source_csv_locs}${greym}, but did not provide the other CSV file ${redl}${file_source_csv_ipv4}${greym}; cannot continue"
            exit 0
        fi

        if [ ! -f "${file_source_csv_ipv6}" ]; then
            error "    ❌ You provided the LOCATION CSV ${redl}${file_source_csv_locs}${greym}, but did not provide the other CSV file ${redl}${file_source_csv_ipv6}${greym}; cannot continue"
            exit 0
        fi
    fi

    # #
    #   Provided the IPv4 csv file, but may be missing the others
    # #

    if [ -f "${file_source_csv_ipv4}" ]; then
        if [ ! -f "${file_source_csv_locs}" ]; then
            error "    ❌ You supplied IPV4 CSV ${redl}${file_source_csv_ipv4}${greym}, but the locations file ${redl}${file_source_csv_locs}${greym} is missing/empty; cannot continue"
            exit 0
        fi

        if [ ! -f "${file_source_csv_ipv6}" ]; then
            error "    ❌ You supplied IPV4 CSV ${redl}${file_source_csv_ipv4}${greym}, but did not provide the IPv6 CSV file ${redl}${file_source_csv_ipv6}${greym}; cannot continue"
            exit 0
        fi
    fi

    # #
    #   Provided IPv6 csv file, but may be missing the others
    # #

    if [ -f "${file_source_csv_ipv6}" ]; then
        if [ ! -f "${file_source_csv_locs}" ]; then
            error "    ❌ You supplied IPV6 CSV ${redl}${file_source_csv_ipv6}${greym}, but the locations file ${redl}${file_source_csv_locs}${greym} is missing/empty; cannot continue"
            exit 0
        fi

        if [ ! -f "${file_source_csv_ipv4}" ]; then
            error "    ❌ You supplied IPv6 CSV ${redl}${file_source_csv_ipv6}${greym}, but did not provide IPv4 CSV file ${redl}${file_source_csv_ipv4}${greym}; cannot continue"
            exit 0
        fi
    fi

    # #
    #   Zip files provided, check MD5
    # #

    if [ -f "${file_source_csv_zip}" ] && [ -f "${file_source_csv_zip_md5}" ]; then

        info "    📄 Found local Country .zip files ${bluel}${file_source_csv_zip}${greym} and ${bluel}${file_source_csv_zip_md5}${greym}"

        # #
        #   Check for download limit reached
        # #

        md5Response=$(cat "${file_source_csv_zip_md5}")
        case "$md5Response" in
            *"download limit reached"*)
                error "    ❌ MaxMind: Daily API download limit reached"
                exit 0
                ;;
        esac

        # #
        #   Validate checksum
        #   .md5 file is not in expected format; 'md5sum --check' won't work
        # #

        md5_local=$(md5sum "${file_source_csv_zip}" | awk '{print $1}')
        if [ "$md5Response" != "$md5_local" ]; then
            error "    ❌ GeoLite2 MD5 downloaded checksum does not match local md5 checksum"
            exit 0
        fi

        # #
        #   Unzip into current working directory
        # #

        if [ -f "${file_source_csv_zip}" ]; then
            info "    📦 Found zip ${bluel}${file_source_csv_zip}${greym}"
            if unzip -o -j -q -d . "${file_source_csv_zip}"; then
                ok "    📦 Unzip successful ${greenl}${file_source_csv_zip}"
            else
                error "    ❌ Unzip failed ${redl}${file_source_csv_zip}${greym}, aborting${greym}"
                exit 0
            fi
        else
            error "    ❌ Cannot locate zip ${redl}${file_source_csv_zip}"
            exit 0
        fi

    elif [ -f "${file_source_csv_locs}" ] && [ -f "${file_source_csv_ipv4}" ] && [ -f "${file_source_csv_ipv6}" ]; then
        info "    📄 Found Uncompressed set ${bluel}${file_source_csv_locs}${greym},${bluel}${file_source_csv_ipv4}${greym} and ${bluel}${file_source_csv_ipv6}${greym}"
    else
        error "    ❌ Could not locate either ${redl}zip + md5${greym} or ${redl}uncompressed csv${greym}"
        exit 0
    fi
}

# #
#   Maxmind › Load Database
#   
#   Database can either be provided locally, or downloaded from the MaxMind site.
#   This func covers local loading.
# #

maxmind_Database_Load( )
{

    info "    📄 Load COUNTRY Database Files${greym}"

    # #
    #   Called from
    #       readonly CONFIGS_LIST="${file_source_csv_locs} ${file_source_csv_ipv4} ${file_source_csv_ipv6}"
    # #

    local configs=(${CONFIGS_LIST})
    for f in ${configs[@]}; do

        info "    📄 Mounting COUNTRY file ${blued}${TEMPDIR}/${f}"
        if [ ! -f "$f" ]; then
            error "    ❌ Missing COUNTRY database: ${redl}${TEMPDIR}/${f}${greym}"
        fi
    done
}

# #
#   Generate › IPv4
#   
#   Loads the list of countries and pulls out the IPv4 addresses. Each country will have a country .tmp file created and the list of
#   ip addresses will be thrown in that file.
#   
#   Continents will be placed in:
#       blocklists/geolite/country/ipv4/AN.tmp
#       blocklists/geolite/country/ipv4/AF.tmp
#   
#   Countries will be placed in:
#       blocklists/geolite/country/ipv4/AD.tmp
#       blocklists/geolite/country/ipv4/AE.tmp
#       [ ... ]
#   
#   CSV Structure [ GeoLite2-Blocks-IPv4.csv ]
#   
#   Line 0          Line 1          Line 2                              Line 3                              Line 4                  Line 5                          Line 6
#   -------------------------------------------------------------------------------------------------------------------------------------------------------
#   network         geoname_id      registered_country_geoname_id       represented_country_geoname_id      is_anonymous_proxy      is_satellite_provider
#   -------------------------------------------------------------------------------------------------------------------------------------------------------
#   1.0.0.0/24                      2077456                                                                 0                       0
#   1.0.1.0/24      1814991         1814991                                                                 0                       0
#   1.0.164.0/28    1605651         1605651                                                                 0                       0
# #

generate_IPv4( )
{
    echo
    info "    📟 Generate ${bluel}IPv4${greym} ipsets from database"

    # #
    #   remove existing ipv4 folder:
    #       blocklists/geolite/country2/ipv4/
    # #

    rm -rf "${path_storage_ipv4}"
    if [ ! -d "${path_storage_ipv4}" ]; then
        ok "    🗑️  Removed folder ${bluel}${path_storage_ipv4}"
    else
        error "    ❌ Failed to remove folder ${greenl}${path_storage_ipv4}"
    fi

    # #
    #   Create new ipv4 folder:
    #       blocklists/geolite/country2/ipv4/
    # #

    if [ ! -d "${path_storage_ipv4}" ]; then
        mkdir -p "${path_storage_ipv4}"

        if [ -d "${path_storage_ipv4}" ]; then
            ok "    📂 Created folder ${greenl}${path_storage_ipv4}"
        else
            error "    ❌ Failed to create ${redl}${path_storage_ipv4}"
        fi
    fi

    # #
    #   Generate › IPv4 › Import › GeoLite2-Blocks-IPv4.csv
    # #

    info "    ➕ Importing ${bluel}IPv4${greym} from COUNTRY database"

    count_ipv4=0
    OIFS=$IFS
    IFS=','
    while read -ra LINE; do
        [[ $argLimitEntries -gt 0 && $count_ipv4 -ge $argLimitEntries ]] && break
        ((count_ipv4++))

        # #
        #   Generate › IPv4 › CSV Structure [ GeoLite2-Blocks-IPv4.csv ]
        #   
        #   Line 0          Line 1          Line 2                              Line 3                              Line 4                  Line 5                      Line 6
        #   ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        #   network         geoname_id      registered_country_geoname_id       represented_country_geoname_id      is_anonymous_proxy      is_satellite_provider       is_anycast
        #   ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        #   1.0.0.0/24                      2077456                                                                 0                       0
        #   1.0.1.0/24      1814991         1814991                                                                 0                       0
        #   1.0.164.0/28    1605651         1605651                                                                 0                       0
        # #

        ID="${LINE[1]}"
        if [ -z "${ID}" ]; then
            ID="${LINE[2]}"
        fi

        # #
        #   skip entry if both location and registered country are empty
        # #

        if [ -z "${ID}" ]; then
            continue
        fi

        # #
        #   If country code
        # #

        country_code="${map_country[${ID}]}"                                    # AU
        continent_code="${map_continent[${ID}]}"                                # OC
        subnet="${LINE[0]}"                                                     # 1.0.0.0/24
        SET_NAME="${country_code}.${file_target_ext_tmp}"                       # AU.tmp

        # #
        #   Generate › IPv4 › Define Iptables/Ipsets file
        # #

        IPSET_FILE="${path_storage_ipv4}/${SET_NAME}"                           # blocklists/geolite/country/ipv4/AU.tmp

        # #
        #   Generate › IPv4 › Add Continent
        # #

        if [ -z "${country_code}" ] || [ "${country_code}" == "_" ]; then
            SET_NAME="${continent_code}.${file_target_ext_tmp}"
            IPSET_FILE="${path_storage_ipv4}/${SET_NAME}"
            
            if [ "$argDevMode" == "true" ]; then
                debug "    📄 Adding continent ${bluel}${continent_code}${greym} › ${bluel}${IPSET_FILE}${greym}"
                echo -e "+ Item missing country, assigning as Continent | ID ${ID} - ${LINE[2]} | Subnet ${subnet} | Continent ${continent_code} Country ${country_code} | File ${IPSET_FILE} | NAME ${SET_NAME}" >> "${app_file_this}-ipv4-missing.log"
            fi
        fi

        # #
        #   Generate › IPv4 › Debug Output
        # #

        if [ $argDevMode == "true" ]; then
            debug "    📄  Writing IPv4 ${bluel}${subnet}${greym} › ${bluel}${IPSET_FILE}${greym}"
        fi

        # #
        #   Generate › IPv4 › Add IP to Ipset File
        # #

        echo "${subnet}" >> $IPSET_FILE                                         # blocklists/geolite/country/ipv4/AU.tmp

    done < <(sed -e 1d "${TEMPDIR}/${file_source_csv_ipv4}")
    IFS=$OIFS

    # #
    #   Generate › IPv4 › Complete
    # #

    if [ "$count_ipv4" -gt 0 ]; then
        count_ipv4=$(printf "%'d" "$count_ipv4")
        ok "    ✅ Import complete (${count_ipv4} entries processed)"
    else
        error "    ⭕ Import failed or no entries processed"
    fi
}

# #
#   Generate > IPv6
#   
#   Loads the list of countries and pulls out the IPv6 addresses. Each country will have a country .tmp file created and the list of
#   ip addresses will be thrown in that file.
#   
#   Continents will be placed in:
#       blocklists/geolite/country/ipv6/AN.tmp
#       blocklists/geolite/country/ipv6/AF.tmp
#   
#   Countries will be placed in:
#       blocklists/geolite/country/ipv6/AD.tmp
#       blocklists/geolite/country/ipv6/AE.tmp
#       [ ... ]
# #

generate_IPv6( )
{
    echo
    info "    📟 Generate ${bluel}IPv6${greym} ipsets from database"

    # #
    #   Remove existing ipv4 folder:
    #       blocklists/geolite/country2/ipv4/
    # #

    rm -rf "${path_storage_ipv6}"
    if [ ! -d "${path_storage_ipv6}" ]; then
        ok "    🗑️  Removed folder ${bluel}${path_storage_ipv6}"
    else
        error "    ❌ Failed to remove folder ${greenl}${path_storage_ipv6}"
    fi

    # #
    #   Create new ipv6 folder:
    #       blocklists/geolite/country2/ipv6/
    # #

    if [ ! -d "${path_storage_ipv6}" ]; then
        mkdir -p "${path_storage_ipv6}"

        if [ -d "${path_storage_ipv6}" ]; then
            ok "    📂 Created folder ${greenl}${path_storage_ipv6}"
        else
            error "    ❌ Failed to create ${redl}${path_storage_ipv6}"
        fi
    fi

    # #
    #   Generate › IPv6 › Import › GeoLite2-Blocks-IPv6.csv
    # #

    info "    ➕ Importing ${bluel}IPv6${greym} from COUNTRY database"

    count_ipv6=0
    OIFS=$IFS
    IFS=','
    while read -ra LINE; do
        [[ $argLimitEntries -gt 0 && $count_ipv6 -ge $argLimitEntries ]] && break
        ((count_ipv6++))

        # #
        #   Generate › IPv6 › CSV Structure [ GeoLite2-Blocks-IPv6.csv ]
        #   
        #   Line 0          Line 1          Line 2                              Line 3                              Line 4                  Line 5                      Line 6
        #   ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        #   network         geoname_id      registered_country_geoname_id       represented_country_geoname_id      is_anonymous_proxy      is_satellite_provider       is_anycast
        #   ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        #   2001:200::/32   1861060         1861060                                                                 0                       0
        #   2001:208::/32   1880251         1880251                                                                 0                       0
        #   2001:218::/34   1861060         1861060                                                                 0                       0
        # #

        ID="${LINE[1]}"                                                         # 1605651
        if [ -z "${ID}" ]; then
            ID="${LINE[2]}"                                                     # 1605651
        fi

        # #
        #   skip entry if both location and registered country are empty
        # #

        if [ -z "${ID}" ]; then
            continue
        fi

        # #
        #   If country code
        # #

        country_code="${map_country[${ID}]}"
        continent_code="${map_continent[${ID}]}"
        subnet="${LINE[0]}"
        SET_NAME="${country_code}.${file_target_ext_tmp}"

        # #
        #   Generate › IPv6 › Define Iptables/Ipsets file
        # #
  
        IPSET_FILE="${path_storage_ipv6}/${SET_NAME}"                           # blocklists/geolite/country/ipv6/AU.tmp

        # #
        #   Generate › IPv6 › Add Continent
        # #

        if [ -z "${country_code}" ] || [ "${country_code}" == "_" ]; then
            SET_NAME="${continent_code}.${file_target_ext_tmp}"
            IPSET_FILE="${path_storage_ipv6}/${SET_NAME}"

            if [ "$argDevMode" == "true" ]; then
                debug "    📄 Adding continent ${bluel}${continent_code}${greym} › ${bluel}${IPSET_FILE}${greym}"
                echo -e "+ Item missing country, assigning as Continent | ID ${ID} - ${LINE[2]} | Subnet ${subnet} | Continent ${continent_code} Country ${country_code} | File ${IPSET_FILE} | NAME ${SET_NAME}" >> "${app_file_this}-ipv6-missing.log"
            fi
        fi

        # #
        #   Generate › IPv6 › Debug Output
        # #

        if [ $argDevMode == "true" ]; then
            debug "    📄  Writing IPv6 ${bluel}${subnet}${greym} › ${bluel}${IPSET_FILE}${greym}"
        fi

        # #
        #   Generate › IPv6 › Add IP to Ipset File
        # #

        echo "${subnet}" >> $IPSET_FILE                                         # blocklists/geolite/country/ipv6/AU.tmp

    done < <(sed -e 1d "${TEMPDIR}/${file_source_csv_ipv6}")
    IFS=$OIFS

    # #
    #   Generate › IPv6 › Complete
    # #

    if [ "$count_ipv6" -gt 0 ]; then
        count_ipv6=$(printf "%'d" "$count_ipv6")
        ok "    ✅ Import complete (${count_ipv6} entries processed)"
    else
        error "    ⭕ Import failed or no entries processed"
    fi
}

# #
#   Loads the GeoLite2 Geolite2-Country-Locations-en.csv file and grabs a list of all locations, line by line.
#   
#   Two lists will be populated:
#       - continent_code
#       - country_code
#   
#   build map of geoname_id to ISO country code
#   ${map_country[$geoname_id]}='country_iso_code'
#   example row: 6251999,en,NA,"North America",CA,Canada,0
#   
#   CSV Structure [ Geolite2-Country-Locations-en.csv ]
#   
#   Line 0          Line 1          Line 2              Line 3              Line 4                  Line 5                          Line 6
#   -------------------------------------------------------------------------------------------------------------------------------------------------------
#   geoname_id      locale_code     continent_code      continent_name      country_iso_code        country_name                    is_in_european_union
#   -------------------------------------------------------------------------------------------------------------------------------------------------------
#   49518           en              AF                  Africa              RW                      Rwanda                          0
#   69543           en              AS                  Asia                YE                      Yemen                           0
#   146669          en              EU                  Europe              CY                      Cyprus                          1
#   1546748         en              AN                  Antarctica          TF                      French Southern Territories     0
#   1559582         en              OC                  Oceania             PW                      Palau                           0
#   6252001         en              NA                  North America       US                      United States                   0
# #

maxmind_Map_Build( )
{
    echo
    info "    🗺️  Building ${bluel}IP Map${greym}"

    OIFS=$IFS
    IFS=','
    while read -ra LINE; do

        if [ $argDevMode == "true" ]; then
            debug "    🗺️  Map: ${yellowd}ID: ${blued}${LINE[0]}${greyd} › ${yellowd}Lang: ${blued}${LINE[1]}${greyd} › ${yellowd}EU Union: ${blued}${LINE[6]}${greym} › ${yellowd}Continent: ${blued}${LINE[3]} (${LINE[2]})${greyd} › ${yellowd}Country: ${blued}${LINE[5]} (${LINE[4]})${greyd}"
        fi

        # echo "geoname_id: ${LINE[0]} country code: ${LINE[4]}"
        continent_code="${LINE[2]}"
        country_code="${LINE[4]}"
    
        # skip geoname_id which are not country specific (ex: Europe)
        if [[ ! -z $country_code ]]; then
            map_country[${LINE[0]}]=${country_code}
        fi

        if [[ ! -z $continent_code ]]; then
            map_continent[${LINE[0]}]=${continent_code}
        fi

    done < <(sed -e 1d ${file_source_csv_locs})
    IFS=$OIFS
}

# #
#   Merge IPv4 and IPv6 Files
#   
#   Takes all of the ipv6 addresses and merges them with the ipv4 file.
#       blocklists/geolite/country/ipv6/AD.tmp  =>  blocklists/geolite/country/ipv4/AD.tmp
#       [ DELETED ]                             =>                         [ MERGED WITH ]
#   
#   Removes the ipv6 file after the merge is done.
# #

ipsets_Merge( )
{
    echo
    info "    🔀 Start Merge"

    for fullpath_ipv6 in ${path_storage_ipv6}/*.${file_target_ext_tmp}; do
        file_ipv6=$(basename ${fullpath_ipv6})
        dest_file="${path_storage_ipv4}/${file_ipv6}"

        if [ -f "$dest_file" ]; then
            # IPv4 file exists; append IPv6 content
            cat "$fullpath_ipv6" >> "$dest_file"
            ok "    📄 Merged ${greenl}${fullpath_ipv6}${greym} › ${greenl}${dest_file}${greym}"
        else
            # No IPv4 file; move IPv6 file directly
            mv -- "$fullpath_ipv6" "$dest_file"
            ok "    📄 Moved ${greenl}${fullpath_ipv6}${greym} › ${greenl}${dest_file}${greym}"
        fi

        rm -f "$fullpath_ipv6"
    done
}

# #
#   Cleanup Garbage
#   
#   Removes old ipv4 and ipv5 folders
# #

gcc( )
{
    echo
    info "    🗑️  Starting ${bluel}GCC${greym} cleanup"

    # remove blocklists/geolite/country/ipv4
    if [ -d $path_storage_ipv4 ]; then
        rm -rf ${path_storage_ipv4}
        if [ ! -d "${path_storage_ipv4}" ]; then
            ok "    🗑️  Removed folder ${bluel}${path_storage_ipv4}"
        else
            error "    ❌ Failed to remove folder ${greenl}${path_storage_ipv4}"
        fi
    fi

    # remove blocklists/geolite/country/ipv6
    if [ -d $path_storage_ipv6 ]; then
       rm -rf ${path_storage_ipv6}
        if [ ! -d "${path_storage_ipv6}" ]; then
            ok "    🗑️  Removed folder ${bluel}${path_storage_ipv6}"
        else
            error "    ❌ Failed to remove folder ${greenl}${path_storage_ipv6}"
        fi
    fi

    # remove temp
    rm -rf "${app_dir_github}/${folder_target_temp}"
    if [ ! -d "${app_dir_github}/${folder_target_temp}" ]; then
        ok "    🗑️  Removed folder ${bluel}${app_dir_github}/${folder_target_temp}"
    else
        error "    ❌ Failed to remove folder ${greenl}${app_dir_github}/${folder_target_temp}"
    fi
}

# #
#   Generate Continents
#   
#   Loops through array continents to get the 7 main continents.
#   Within each loop, the other country arrays will be checked to see if that parent continent has any countries within it to list under that continent name.
#   
#   CONTINENT files will be created in:
#       blocklists/geolite/country/ipv4/AN.tmp
#       blocklists/geolite/country/ipv4/AF.tmp
#       blocklists/geolite/country/ipv4/EU.tmp
#       blocklists/geolite/country/ipv4/AS.tmp
#       blocklists/geolite/country/ipv4/SA.tmp
#       blocklists/geolite/country/ipv4/NA.tmp
#       blocklists/geolite/country/ipv4/OC.tmp
#   
#   COUNTRY files will be created in:
#       blocklists/geolite/country/ipv4/AD.tmp
#       blocklists/geolite/country/ipv4/AE.tmp
#       blocklists/geolite/country/ipv4/AF.tmp
#       [ ... ]
#   
#   If a country exists within a continent, a new file will be created:
#       blocklists/geolite/country/ipv4/AD.tmp
#   
#   If there are IP addresses with NO country specified, and are continent only, those IPs will be moved to
#   a base (parent) continent file:
#       blocklists/geolite/country/ipv4/EU.tmp
#   
#   After all IPs are added for a continent, the .tmp file will be moved to its final spot:
#       blocklists/geolite/country/ipv4/EU.tmp => blocklists/geolite/country/EU.ipset
# #

generate_Continents( )
{

    echo
    info "    🌎 Generate New ${bluel}Continent${greym}"
    
    # #
    #   continents array
    #       key     value
    #       -------------------
    #       AN      Antartica
    #       AS      Asia
    #   
    #       _continent_name         = South America
    #       _continent_id           = south_america
    #       FILE_CONTINENT_TEMP     = blocklists/geolite/country/ipv4/continent_europe.tmp
    #       _continent_file_perm    = blocklists/geolite/country/ipv4/continent_europe.ipset
    # #

    # loop continents, antartica, europe, north america
    templ_countries_list=""
    count=0
    _continent_build_hasmatch=""

    grand_total_ips=0
    grand_total_subnets=0
    grand_total_lines=0
    for key in "${!continents[@]}"; do
    
        _continent_name=${continents[$key]}
        _continent_id=$( echo "$_continent_name" | sed 's/ /_/g' | tr -d "[.,/\\-\=\+\{\[\]\}\!\@\#\$\%\^\*\'\\\(\)]" | tr '[:upper:]' '[:lower:]')

        _continent_file_temp="$path_storage_ipv4/continent_$_continent_id.$file_target_ext_tmp"             # blocklists/geolite/country/ipv4/continent_europe.tmp
        _continent_file_perm="$folder_target_storage/continent_$_continent_id.$file_target_ext_ipset"       # blocklists/geolite/country/ipv4/continent_europe.ipset

        info "       🗺️  Generating ${bluel}${_continent_name}${end} ${greyl}(${_continent_id})${end}"

        # #
        #   Return each country's ips to be included in continent file
        #       GR
        #       BG
        # #

        templ_countries_list=""
        _continent_abbrev=$(echo "$key" | tr '[:upper:]' '[:lower:]')
        count=1                                                                 # start at one, since the last step is base continent file
        for country in $( eval echo \${$_continent_abbrev${i}[@]} ); do
            time_start_task=$( date +%s )                                       # record start time of script
            CONTINENT_COUNTRY_NAME=$(get_country_name "$country")

            # count number of items in country array for this particular continent
            i_array=$(eval echo \${#$_continent_abbrev${i}[@]})
            i_array=$(( $i_array - 1 ))

            info "          New country ${dim}${bluel}${_continent_name}${greym} › ${bluel}${CONTINENT_COUNTRY_NAME}${greym}(${country})${end}"

            _file_target="$path_storage_ipv4/$country.$file_target_ext_tmp"     # blocklists/geolite/country/ipv4/JE.tmp

            # check if a specific country file exists, if so, open and grab all the IPs in the list. They need to be copied to $_continent_file_temp
            if [ -f "$_file_target" ]; then
                # ./blocklists/geolite/country/ipv4/VU.tmp to ./blocklists/geolite/country/ipv4/continent_oceania.tmp
                mkdir -p "$(dirname "${_continent_file_temp}")"                 # ensure directory exists
                touch "${_continent_file_temp}"                                 # ensure file exists
                cat "$_file_target" | sort_results | awk '{if (++dup[$0] == 1) print $0;}' >> "${_continent_file_temp}"

                : "${_continent_build_hasmatch:=$_file_target}"

                ok "          Added ${greenl}${_continent_name}${greym} › ${greenl}${CONTINENT_COUNTRY_NAME}${greym} to ${greenl}${_continent_file_temp}"
            else
                warn "          No country file ${yellowd}${_file_target}${greym}; skipping"
            fi

            # #
            #   Count and determine how countries are printed in header of file.
            #   depending on the position, the comma will be excluded on the last entry in the list
            # #

            if [ "${i_array}" == "${count}" ]; then
                if [ $((count%3)) -eq 0 ]; then
                    templ_countries_list+=$'\n'"#                   ${CONTINENT_COUNTRY_NAME} (${country})"
                else
                    templ_countries_list+="${CONTINENT_COUNTRY_NAME} (${country})"
                fi
            else
                if [ $((count%3)) -eq 0 ]; then
                    templ_countries_list+=$'\n'"#                   ${CONTINENT_COUNTRY_NAME} (${country}), "
                else
                    templ_countries_list+="${CONTINENT_COUNTRY_NAME} (${country}), "
                fi
            fi

            count=$(( count + 1 ))
        done

        # #
        #   Import the continent file
        #   
        #   Looks for the continent file that contains all non-country assigned IPs. Not all continents will have one.
        #   
        #   _continent_base_target
        #       blocklists/geolite/country/ipv4/AN.tmp
        #       blocklists/geolite/country/ipv4/AF.tmp
        #       blocklists/geolite/country/ipv4/EU.tmp
        #       blocklists/geolite/country/ipv4/continent_oceania.tmp
        # #

        _continent_base_target="$path_storage_ipv4/$key.$file_target_ext_tmp"
        if [ -f "$_continent_base_target" ]; then
            info "          Merge base continent file ${bluel}${_continent_base_target}${greym} › ${bluel}${_continent_file_temp}${end}"
            cat "$_continent_base_target" | sort_results | awk '{if (++dup[$0] == 1) print $0;}' >> "${_continent_file_temp}"
        else
            warn "          Continent ${yellowl}${_continent_name}${greym} doesn't have a base file to import from ${yellowl}${_continent_base_target}${greym}; skipping"
        fi

        # #
        #   Set Continent Name
        # #

        templ_continent_name="${_continent_name}"
        _fnFileTemp="${_continent_file_temp}"

        # #
        #   Perform sed actions on downloaded file.
        # #

        if [ -f "$_fnFileTemp" ]; then

            # normalize CRLF
            sed -i 's/\r$//' "${_fnFileTemp}"

            # remove hyphens from IP ranges (if format is "1.2.3.4 - 1.2.3.5" take left side)
            sed -i 's/-.*//' "${_fnFileTemp}"

            # remove inline comments (strip ' # comment' or ' ; comment' from end of lines ; collapse whitespace, trim)
            sed -i 's/[[:space:]]*[#;].*$//' "${_fnFileTemp}"

            # collapse multiple whitespace into a single space
            sed -i 's/[[:space:]]\+/ /g' "${_fnFileTemp}"

            # trim leading and trailing whitespace
            sed -i 's/^[[:space:]]*//;s/[[:space:]]*$//' "${_fnFileTemp}"

            # remove empty lines (after trimming/comment removal)
            sed -i '/^$/d' "${_fnFileTemp}"

            # #
            #   Dedupe, Sort: Move from .tmp to .sort
            # #

            info "          Sorted and dedup'ed results for ${bluel}$_fnFileTemp${greyd}"
            grep -vE '^[[:space:]]*(#|;|$)' "${_fnFileTemp}" | sort_results > "${_fnFileTemp}.sort"

            mv "${_fnFileTemp}.sort" "${_fnFileTemp}"
            if [[ $? -ne 0 ]]; then
                error "          Could not move file ${redd}${_fnFileTemp}.sort${greym} › ${redd}${_fnFileTemp}${end}"
                exit 1
            else
                ok "          Moved ${greenl}${_fnFileTemp}.sort${greym} › ${greenl}${_fnFileTemp}${greym}"
            fi

        else
            warn "       ⚠️  Skipping ${yellowd}$_fnFileTemp${greym} — no data to process"
            echo
            continue
        fi

        # #
        #   Confirm country temp file exists
        # #

        if [ ! -f "$_file_target" ] && [ ! -f "$_continent_build_hasmatch" ]; then
            warn "       ⚠️  No temp country file ${redd}${_file_target}${greym}. Missing file."
            continue
        fi

        # #
        #   Get Counts
        # #

        info "          Count IPs and subnets in ${bluel}$_fnFileTemp${greyd}"

        count_ip_stats "${_fnFileTemp}"
        total_ips=$total_ips
        total_subnets=$total_subnets

        total_lines=$(wc -l < "${_fnFileTemp}")                                 # count ip lines
        total_lines=$(printf "%'d" "$total_lines")                              # GLOBAL add commas to thousands
        total_subnets=$(printf "%'d" "$total_subnets")                          # GLOBAL add commas to thousands
        total_ips=$(printf "%'d" "$total_ips")                                  # GLOBAL add commas to thousands

        # Add running totals
        (( grand_total_ips += ${total_ips//,/} ))
        (( grand_total_subnets += ${total_subnets//,/} ))
        (( grand_total_lines += ${total_lines//,/} ))

        mv -- "$_fnFileTemp" "${_continent_file_perm}"
        if [[ $? -ne 0 ]]; then
            error "          Could not move file ${redd}${_fnFileTemp}${greym} › ${redd}${_continent_file_perm}${end}"
            exit 1
        else
            ok "          Moved ${greenl}${_fnFileTemp}${greym} › ${greenl}${_continent_file_perm}${greym}"
        fi

        ok "          Added ${fuchsiad}${total_lines} Lines${greyd} | ${fuchsiad}${total_ips} IPs${greym}${greyd} | ${fuchsiad}${total_subnets} Subnets${greym} to ${bluel}${_continent_file_perm}${end}"

        # #
        #   Continents › Template › Initialize
        # #

        templ_now="$(date -u)"                                                  # Get current date in utc format
        templ_id='countries'                                                    # Ipset id, get base filename
        # templ_id=$(basename -- "${_continent_file_perm}")                     # Ipset id, get base filename
        templ_id="${templ_id//[^[:alnum:]]/_}"                                  # Ipset id, only allow alphanum and underscore, /description/* and /category/* files must match this value
        templ_uuid="$(uuidgen -m -N "${templ_id}" -n @url)"                     # UUID associated to each release
        templ_curl_opts=(-sSL -A "$app_agent")                                  # cUrl command

        info "          Fetching blocklist properties from ${bluel}$app_repo_curl_storage${greyd}"

        # #
        #   Continents › Template › External Sources
        # #

        curl "${templ_curl_opts[@]}" "${app_repo_curl_storage}/descriptions/geolite2/${templ_id}.txt" > ${app_dir_github}/${folder_target_temp}/desc.txt &
        curl "${templ_curl_opts[@]}" "${app_repo_curl_storage}/categories/geolite2/${templ_id}.txt" > ${app_dir_github}/${folder_target_temp}/cat.txt &
        curl "${templ_curl_opts[@]}" "${app_repo_curl_storage}/expires/geolite2/${templ_id}.txt" > ${app_dir_github}/${folder_target_temp}/exp.txt &
        curl "${templ_curl_opts[@]}" "${app_repo_curl_storage}/url-source/geolite2/${templ_id}.txt" > ${app_dir_github}/${folder_target_temp}/src.txt &
        wait

        # #
        #   Continents › Template › Get Details
        # #

        templ_desc=$(<"${app_dir_github}/${folder_target_temp}/desc.txt")
        templ_cat=$(<"${app_dir_github}/${folder_target_temp}/cat.txt")
        templ_exp=$(<"${app_dir_github}/${folder_target_temp}/exp.txt")
        templ_url_service=$(<"${app_dir_github}/${folder_target_temp}/src.txt")

        if rm -f "${app_dir_github}/${folder_target_temp}/desc.txt" \
                "${app_dir_github}/${folder_target_temp}/cat.txt" \
                "${app_dir_github}/${folder_target_temp}/exp.txt" \
                "${app_dir_github}/${folder_target_temp}/src.txt"
        then
            ok "          Removed temp files from ${greenl}${folder_target_temp}${greym}: ${greend}${folder_target_temp}/desc.txt${greym}, ${greend}${folder_target_temp}/cat.txt${greym}, ${greend}${folder_target_temp}/exp.txt${greym}, ${greend}${folder_target_temp}/src.txt${greym}"
        else
            error "          Could not remove temp files from ${redd}${app_dir_github}/${folder_target_temp}${end}"
            exit 1
        fi

        # #
        #   Continents › Template › Defaults
        # #

        case "$templ_desc" in *"404: Not Found"*) templ_desc="#   No description provided";; esac
        case "$templ_cat" in *"404: Not Found"*) templ_cat="Uncategorized";; esac
        case "$templ_exp" in *"404: Not Found"*) templ_exp="6 hours";; esac
        case "$templ_url_service" in *"404: Not Found"*) templ_url_service="None";; esac

        # #
        #   ed
        #       0a  top of file
        # #

ed -s ${_continent_file_perm} <<END_ED
0a
# #
#   🧱 Firewall Blocklist - ${_continent_file_perm}
#
#   @repo           https://raw.githubusercontent.com/${app_repo}/${app_repo_branch}/${_continent_file_perm}
#   @service        ${templ_url_service}
#   @id             ${templ_id}
#   @uuid           ${templ_uuid}
#   @updated        ${templ_now}
#   @entries        ${total_ips} ips
#                   ${total_subnets} subnets
#                   ${total_lines} lines
#   @continent      ${templ_continent_name} (${key})
#   @countries      ${templ_countries_list}
#   @expires        ${templ_exp}
#   @category       ${templ_cat}
#
${templ_desc}
# #

.
w
q
END_ED

        # #
        #   Output › Loop › Footer
        # #

        time_elapsed $(( $( date +%s ) - time_start_task ))
        ok "          Finished ${greenl}${yellowl}${D} days ${H} hrs ${M} mins ${S} secs${greyd}"
        echo

    done

    # #
    #   Output › Footer
    # #

    grand_total_lines=$(printf "%'d" "$grand_total_lines")                      # GLOBAL total lines across all files
    grand_total_subnets=$(printf "%'d" "$grand_total_subnets")                  # GLOBAL total subnets across all files
    grand_total_ips=$(printf "%'d" "$grand_total_ips")                          # GLOBAL total ips across all files

    time_elapsed $(( $( date +%s ) - time_start ))
    prinp "🎌[41] Finished!   ${fuchsiad}Lines: ${yellowl}${grand_total_lines}${greyd} | ${fuchsiad}IPs: ${yellowl}${grand_total_ips}${greyd} | ${fuchsiad}Subnets: ${yellowl}${grand_total_subnets}${greyd} | Duration: ${yellowl}${D} days ${H} hrs ${M} mins ${S} secs${greyd}" false
}

# #
#   Generate Countries
#   
#   Loops through each file in blocklists/geolite/country/ipv4/*
#   Counts the statistics:
#       - Number of lines in file
#       - Number of normal IPs
#       - Number of subnets
#   
#   Header will be added to the top of the file which statistics and other info.
#   
#   File will be re-named / moved:
#       blocklists/geolite/country/ipv4/AE.tmp => blocklists/geolite/country/AE.ipset
# #

generate_Countries( )
{

    echo
    info "    🌎 Generate New ${bluel}Countries${greym}"

    # #
    #   Loop each temp file
    #       CA.TMP
    #       US.TMP
    # #

    grand_total_ips=0
    grand_total_subnets=0
    grand_total_lines=0

    #   country_file blocklists/geolite/country/ipv4/SG.tmp
    #   country_file blocklists/geolite/country/ipv4/TH.tmp
    for country_file in ${path_storage_ipv4}/*.${file_target_ext_tmp}; do
        time_start_task=$( date +%s )                                                               # record start time of script
        file_temp_base=$(basename -- ${country_file})                                               # get two letter country code
        country_code="${file_temp_base%.*}"                                                         # base file without extension
        country=$(get_country_name "$country_code")                                                 # get full country name from abbreviation

        info "       🗺️  Assign Country ${dim}${bluel}${country} (${country_code})${greym} to ${dim}${bluel}${country_file}${end}"
        country_id=$(echo "$country" | sed 's/ /_/g' | tr -d "[.,/\\-\=\+\{\[\]\}\!\@\#\$\%\^\*\'\\\(\)]" | tr '[:upper:]' '[:lower:]') # country long name with spaces, special chars removed

        country_file=${country_file#././}                                                           # remove ./ from front which means us with just the temp path
        APP_FILE_PERM="${folder_target_storage}/country_${country_id}.${file_target_ext_ipset}"     # final location where ipset files should be

        # #
        #   Get Counts
        # #

        info "          Count IPs and subnets in ${bluel}$country_file${greyd}"

        count_ip_stats "${country_file}"
        total_ips=$total_ips
        total_subnets=$total_subnets

        total_lines=$(wc -l < "${country_file}")                                # count ip lines
        total_lines=$(printf "%'d" "$total_lines")                              # GLOBAL add commas to thousands
        total_subnets=$(printf "%'d" "$total_subnets")                          # GLOBAL add commas to thousands
        total_ips=$(printf "%'d" "$total_ips")                                  # GLOBAL add commas to thousands

        # Add running totals
        (( grand_total_ips += ${total_ips//,/} ))
        (( grand_total_subnets += ${total_subnets//,/} ))
        (( grand_total_lines += ${total_lines//,/} ))

        mv -- "$country_file" "${APP_FILE_PERM}"
        if [[ $? -ne 0 ]]; then
            error "          Could not move file ${redd}${country_file}${greym} › ${redd}${APP_FILE_PERM}${end}"
            exit 1
        else
            ok "          Moved ${greenl}${country_file}${greym} › ${greenl}${APP_FILE_PERM}${greym}"
        fi

        ok "          Added ${fuchsiad}${total_lines} Lines${greyd} | ${fuchsiad}${total_ips} IPs${greym}${greyd} | ${fuchsiad}${total_subnets} Subnets${greym} to ${bluel}${APP_FILE_PERM}${end}"

        # #
        #   Countries › Template › Initialize
        # #

        templ_now="$(date -u)"                                                  # Get current date in utc format
        templ_id='countries'                                                    # Ipset id, get base filename
        # templ_id=$(basename -- "${APP_FILE_PERM}")                            # Ipset id, get base filename
        templ_id="${templ_id//[^[:alnum:]]/_}"                                  # Ipset id, only allow alphanum and underscore, /description/* and /category/* files must match this value
        templ_uuid="$(uuidgen -m -N "${templ_id}" -n @url)"                     # UUID associated to each release
        templ_curl_opts=(-sSL -A "$app_agent")                                  # cUrl command

        info "          Fetching blocklist properties from ${bluel}$app_repo_curl_storage${greyd}"

        # #
        #   Countries › Template › External Sources
        # #

        curl "${templ_curl_opts[@]}" "${app_repo_curl_storage}/descriptions/geolite2/${templ_id}.txt" > ${app_dir_github}/${folder_target_temp}/desc.txt &
        curl "${templ_curl_opts[@]}" "${app_repo_curl_storage}/categories/geolite2/${templ_id}.txt" > ${app_dir_github}/${folder_target_temp}/cat.txt &
        curl "${templ_curl_opts[@]}" "${app_repo_curl_storage}/expires/geolite2/${templ_id}.txt" > ${app_dir_github}/${folder_target_temp}/exp.txt &
        curl "${templ_curl_opts[@]}" "${app_repo_curl_storage}/url-source/geolite2/${templ_id}.txt" > ${app_dir_github}/${folder_target_temp}/src.txt &
        wait

        # #
        #   Countries › Template › Get Details
        # #

        templ_desc=$(<"${app_dir_github}/${folder_target_temp}/desc.txt")
        templ_cat=$(<"${app_dir_github}/${folder_target_temp}/cat.txt")
        templ_exp=$(<"${app_dir_github}/${folder_target_temp}/exp.txt")
        templ_url_service=$(<"${app_dir_github}/${folder_target_temp}/src.txt")

        if rm -f "${app_dir_github}/${folder_target_temp}/desc.txt" \
                "${app_dir_github}/${folder_target_temp}/cat.txt" \
                "${app_dir_github}/${folder_target_temp}/exp.txt" \
                "${app_dir_github}/${folder_target_temp}/src.txt"
        then
            ok "          Removed temp files from ${greenl}${folder_target_temp}${greym}: ${greend}${folder_target_temp}/desc.txt${greym}, ${greend}${folder_target_temp}/cat.txt${greym}, ${greend}${folder_target_temp}/exp.txt${greym}, ${greend}${folder_target_temp}/src.txt${greym}"
        else
            error "          Could not remove temp files from ${redd}${app_dir_github}/${folder_target_temp}${end}"
            exit 1
        fi

        # #
        #   Countries › Template › Defaults
        # #

        case "$templ_desc" in *"404: Not Found"*) templ_desc="#   No description provided";; esac
        case "$templ_cat" in *"404: Not Found"*) templ_cat="Uncategorized";; esac
        case "$templ_exp" in *"404: Not Found"*) templ_exp="6 hours";; esac
        case "$templ_url_service" in *"404: Not Found"*) templ_url_service="None";; esac

        # #
        #   ed
        #       0a  top of file
        # #

ed -s ${APP_FILE_PERM} <<END_ED
0a
# #
#   🧱 Firewall Blocklist - ${APP_FILE_PERM}
#
#   @repo           https://raw.githubusercontent.com/${app_repo}/${app_repo_branch}/${APP_FILE_PERM}
#   @service        ${templ_url_service}
#   @id             ${templ_id}
#   @uuid           ${templ_uuid}
#   @updated        ${templ_now}
#   @entries        ${total_ips} ips
#                   ${total_subnets} subnets
#                   ${total_lines} lines
#   @country        ${country} (${country_code})
#   @expires        ${templ_exp}
#   @category       ${templ_cat}
#
${templ_desc}
# #

.
w
q
END_ED

        # #
        #   Output › Loop › Footer
        # #
    
        time_elapsed $(( $( date +%s ) - time_start_task ))
        ok "          Finished ${greenl}${yellowl}${D} days ${H} hrs ${M} mins ${S} secs${greyd}"
        echo

    done

    # #
    #   Output › Footer › Country Statistics
    # #

    grand_total_lines=$(printf "%'d" "$grand_total_lines")                      # GLOBAL total lines across all files
    grand_total_subnets=$(printf "%'d" "$grand_total_subnets")                  # GLOBAL total subnets across all files
    grand_total_ips=$(printf "%'d" "$grand_total_ips")                          # GLOBAL total ips across all files

    # #
    #   Output › Footer › Countries
    # #

    time_elapsed $(( $( date +%s ) - time_start ))
    prinp "🎌[41] Finished!   ${fuchsiad}Lines: ${yellowl}${grand_total_lines}${greyd} | ${fuchsiad}IPs: ${yellowl}${grand_total_ips}${greyd} | ${fuchsiad}Subnets: ${yellowl}${grand_total_subnets}${greyd} | Duration: ${yellowl}${D} days ${H} hrs ${M} mins ${S} secs${greyd}" false
}

# #
#   Main Function
#   
#   Accepts -l license parameters
#       ./script -l LICENSE_KEY
# #

main()
{

    # #
    #   Start
    # #

    echo
    echo
    info "    ⭐ Starting ${bluel}${app_file_this}"

    # #
    #   Get license key
    #       ./geolite2.conf
    # #

    if [ -f "${app_dir_this_dir}/${file_cfg}" ]; then
        info "    📄 Loading config ${bluel}${app_dir_this_dir}/${file_cfg}"
        # shellcheck disable=SC1090
        . "${app_dir_this_dir}/${file_cfg}" >/dev/null 2>&1
    fi

    if [ -z "${argUseLocalDB}" ] && [ -z "${argMMLicense}" ]; then
        error "    ❌ Must supply valid MaxMind license key. Aborting ..."
    fi

    # #
    #   Check Packages
    #   
    #   Ensure all the packages we need are installed on the system.
    # #

    required_Packages

    # #
    #   Temp Path
    #   
    #   Local Mode          .github/local
    #   Network Mode        .github/.temp
    # #

    if [ "${argUseLocalDB}" = "false" ]; then
        mkdir -p "${app_dir_github}/${folder_target_temp}"
        if [ -d "${app_dir_github}/${folder_target_temp}" ]; then
            ok "    📂 Created TEMPDIR ${greenl}${app_dir_github}/${folder_target_temp}"
        else
            error "    ❌ Failed to create ${redl}${app_dir_github}/${folder_target_temp}"
        fi

        TEMPDIR="${app_dir_github}/${folder_target_temp}"
    else
        mkdir -p "${app_dir_github}/${folder_source_local}"
        if [ -d "${app_dir_github}/${folder_source_local}" ]; then
            ok "    📂 Created TEMPDIR ${greenl}${app_dir_github}/${folder_source_local}"
        else
            error "    ❌ Failed to create ${redl}${app_dir_github}/${folder_source_local}"
        fi

        TEMPDIR="${app_dir_github}/${folder_source_local}"
    fi

    ok "    📄 Setting TEMPDIR ${greenl}${TEMPDIR}"
    export TEMPDIR

    # #
    #   Switch to tempdir
    # #

    if pushd "${TEMPDIR}" > /dev/null 2>&1; then
        ok "    📁 Using TEMPDIR ${greenl}${TEMPDIR}${greym}"
    else
        error "    ⭕ Failed to enter ${redl}${TEMPDIR}${greym}"
        exit 1
    fi

    # #
    #   Create cache folder
    # #

    mkdir -p "${app_dir_github}/${folder_target_cache}"
    if [ -d "${app_dir_github}/${folder_target_cache}" ]; then
        ok "    📁 Created folder ${greenl}${app_dir_github}/${folder_target_cache}${greym}"
    else
        error "    ⭕  Failed to create directory ${redl}${app_dir_github}/${folder_target_cache}${greym}; aborting"
        exit 1
    fi

    # #
    #   Create temp folder
    # #

    mkdir -p "${app_dir_github}/${folder_target_temp}"
    if [ -d "${app_dir_github}/${folder_target_temp}" ]; then
        ok "    📁 Created folder ${greenl}${app_dir_github}/${folder_target_temp}${greym}"
    else
        error "    ⭕  Failed to create directory ${redl}${app_dir_github}/${folder_target_temp}${greym}; aborting"
        exit 1
    fi

    # #
    #   Create logs folder
    # #

    mkdir -p "${app_dir_github}/${folder_target_logs}"
    if [ -d "${app_dir_github}/${folder_target_logs}" ]; then
        ok "    📁 Created folder ${greenl}${app_dir_github}/${folder_target_logs}${greym}"
    else
        error "    ⭕  Failed to create directory ${redl}${app_dir_github}/${folder_target_logs}${greym}; aborting"
        exit 1
    fi

    # #
    #   Download / Unzip .zip
    # #

    maxmind_Database_Download
    maxmind_Database_Load
    maxmind_Map_Build

    # #
    #   Define > Maps
    # #

    declare -p map_continent > ${app_dir_github}/${folder_target_cache}/MAP_CONTINENT.cache
    declare -p map_country > ${app_dir_github}/${folder_target_cache}/MAP_COUNTRY.cache

    if [ "$argDevMode" == "true" ]; then
        for KEY in "${!map_continent[@]}"; do
            printf "%s --> %s\n" "$KEY" "${map_continent[$KEY]}" >> "${app_dir_github}/${folder_target_logs}/MAP_CONTINENT.log"
            debug "       ${greyd}Writing ${navy}$KEY${greyd} › ${navy}${map_continent[$KEY]}${greyd} to log › ${yellowd}${folder_target_logs}/MAP_CONTINENT.log${greyd}"
        done

        for KEY in "${!map_country[@]}"; do
            printf "%s --> %s\n" "$KEY" "${map_country[$KEY]}" >> "${app_dir_github}/${folder_target_logs}/MAP_COUNTRY.log"
            debug "       ${greyd}Writing ${navy}$KEY${greyd} › ${navy}${map_country[$KEY]}${greyd} to log › ${yellowd}${folder_target_logs}/MAP_COUNTRY.log${greyd}"
        done
    fi

    # #
    #   place set output in current working directory
    # #

    popd > /dev/null 2>&1

    # #
    #   Cleanup old files
    # #

    if [ "$argClean" = true ]; then
        info "    🗑️ Cleaning ${bluel}${folder_target_storage}"
        rm -rf "${folder_target_storage}"/*
        if [ ! -d "${folder_target_storage}" ]; then
            ok "    🗑️  Removed folder ${greenl}${folder_target_storage}"
        else
            error "    ❌ Failed to remove folder ${redl}${folder_target_storage}"
        fi
    fi

    # #
    #   Run actions
    # #

    generate_IPv4
    generate_IPv6
    ipsets_Merge
    generate_Continents
    generate_Countries
    gcc
}

main "$@"