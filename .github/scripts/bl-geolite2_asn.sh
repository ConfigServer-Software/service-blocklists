#!/bin/bash

# #
#   @script             Blocklist › Geolite › ASN
#   @repo               https://github.com/ConfigServerApps/service-blocklists
#   @workflow           blocklist-generate.yml
#   @type               bash script
#   @summary            Blocklists › GeoLite2 ASN IPsets
#                       Generates a set of IPSET files by reading the GeoLite2 csv file and splitting the IPs up into their associated ASN.
#                           blocklists/geolite/asn/3000/asn_3598_microsoft_corp_as.ipset
#                           blocklists/geolite/asn/5000/asn_5761_microsoft_corp_msn_as_saturn.ipset
#                           [...]
#   @path               .github/scripts/bl-geolite2_asn.sh
#   @params             .github/scripts/bl-geolite2_asn.sh
#                           <argFileSaveTo>     str     req     Local file to save IP addresses.
#                           <argUrl>            vararg  req     Blocklist source URL
#   @commands           1.  ./.github/scripts/bl-geolite2_asn.sh --help                                                                         View help menu
#                       2.  ./.github/scripts/bl-geolite2_asn.sh --license <LICENSE_KEY>                                                        Download MaxMind DB from website and process
#                       3.  ./.github/scripts/bl-geolite2_asn.sh --local --asn 7,10                                                             Only processes IPs with ASN 7 and 10
#                       4.  ./.github/scripts/bl-geolite2_asn.sh --local --limit 1000                                                           Limits to first 1000 entries
#                       5.  ./.github/scripts/bl-geolite2_asn.sh --local                                                                        Use local copy of MM database in .github/local folder
#                       6.  ./.github/scripts/bl-geolite2_asn.sh --local --dev                                                                  Use local copy of MM database but doesn't run final steps
#                       7.  ./.github/scripts/bl-geolite2_asn.sh --dry                                                                          Dryrun
#                       8.  ./.github/scripts/bl-geolite2_asn.sh --local --aggressive --folder A --file akamai_core --asn AS20940 AS32787       Aggressive mode; generates two blocklists; one in blocklists/geolite/A/akami_core.ipset, one blocklists/geolite/asn/@general/aggressive.ipset
#                       9.  ./.github/scripts/bl-geolite2_asn.sh --license <LICENSE_KEY> --folder C --file contabo_gmbh                         Download database from MaxMind; custom file/folder
#                       10. ./.github/scripts/bl-geolite2_asn.sh --local --folder C --file contabo_gmbh --asn AS51167                           Local source database; custom file/folder
#   @structure          📁 .github
#                           📁 scripts
#                               📄 bl-geolite2_asn.sh
#                           📁 templates
#                               📁 categories
#                                   📄 *
#                               📁 descriptions
#                                   📄 *
#                               📁 expires
#                                   📄 *
#                               📁 sources
#                                   📄 *
#                           📁 workflows
#                               📄 blocklist-generate.yml
# #

# #
#   📗 Usage
#   
#   This script can download OR use a local copy of MaxMind's GeoLite2 Databases 
#   to extract IPs from the CSV data.
#       - CSV URL: https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN-CSV&license_key=LICENSE_KEY&suffix=zip
#       - MD5 URL: https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN-CSV&license_key=LICENSE_KEY&suffix=zip.md5
#   
#   This script requires a LICENSE KEY to Maxmind in order to obtain these
#   databases. Get a license key at:
#       https://maxmind.com
#   
#   Keep the license key secure, especially if running on GitHub Actions.
#   
#   The license key can be specified to download the latest MaxMind Database one of two ways:
#       1.  Use the argument `--license`` when you run the script command
#       2.  OR; create a new file called `.github/geolite2.conf`, add contents:
#               LICENSE_KEY=YOUR_LICENSE_KEY
#   
#   Once you define a LICENSE KEY, there are two ways to use the MaxMind database
#       1.  Script can download the most recent databases from the webserver,
#       2.  OR; provide local copies of the .csv, or the zip + md5 file which 
#           contains the .csv; pick ONE of the two:
#           1.  Using CSVs:
#               .github/local/GeoLite2-ASN-Blocks-IPv4.csv
#               .github/local/GeoLite2-ASN-Blocks-IPv6.csv
#           1.  Using ZIPs:
#               .github/local/GeoLite2-ASN-CSV.zip
#               .github/local/GeoLite2-ASN-CSV.zip.md5
#   
#   To download new copies of the MaxMind DBs:
#       ./.github/scripts/bl-geolite2_asn.sh --license YOUR_MAXMIND_LICENSE_KEY
#   
#   To use local files, run the command
#       ./.github/scripts/bl-geolite2_asn.sh --local
#   
#   The DB will be opened, and each ASN will be grouped into subfolders. 
#       ASNs are grouped into thousands; if downloading AS7, entry will be placed in folder `/0/`:
#       ./blocklists/geolite/asn/ipv4/0/asn_7_the_defence_science_and_technology_laboratory.tmp
#       ./blocklists/geolite/asn/ipv6/0/asn_7_the_defence_science_and_technology_laboratory.tmp
#   
#   Once it finishes generating all the .tmp files for each ipv4 and ipv6, it will move them out of the ipv4 and ipv6
#   subfolder and bring them two sub-folders back, with the filename .ipset
#       ./blocklists/geolite/asn/asn_7_the_defence_science_and_technology_laboratory.ipset
# #

# #
#   📗 Custom Paths
#   
#   You can force ipsets to be stored in a specific folder and file by passing the args:
#       --folder c --file cloudflare
#   
#   Places all IPSETs in the path:
#       ./blocklists/geolite/asn/c/cloudflare.ipset
#   
#   Store all ASNs to a single file (database download):
#       ./.github/scripts/bl-geolite2_asn.sh --license <LICENSE_KEY> --folder c --file cloudflare --asn 13335,209242,202623,132892,395747,14789,203898
#   
#   Store all ASNs to a single file (local):
#       ./.github/scripts/bl-geolite2_asn.sh --local --folder c --file cloudflare --asn 13335,209242,202623,132892,395747,14789,203898
#       ./.github/scripts/bl-geolite2_asn.sh --local --folder c --file cloudflare --asn AS13335 AS209242 AS202623 AS132892 AS395747 AS14789 AS203898
# #

# #
#   📗 Local Mode
#   
#   Instead of downloading the MaxMind database, you can provide your own local copy.
#       Place your own copies of the csv, or the zip + md5 file which contains the csv; pick ONE of the two:
#           1.  Using CSVs:
#               .github/local/GeoLite2-ASN-Blocks-IPv4.csv
#               .github/local/GeoLite2-ASN-Blocks-IPv6.csv
#           1.  Using ZIPs:
#               .github/local/GeoLite2-ASN-CSV.zip
#               .github/local/GeoLite2-ASN-CSV.zip.md5
#   
#   To specify that you want to run the script in local mode, use the arguments:
#       .github/scripts/bl-geolite2_asn.sh -o
#       .github/scripts/bl-geolite2_asn.sh --local
# #

# #
#   📗 Test Script
#   
#   You can tell the script to only process a certain number of entries, instead of the entire database which takes a long time.
#       Option 1        Generate test csv, first 1000 entries
#                           tail -n +2 "${TEMPDIR}/${file_source_csv_ipv4}" | head -n 1000 > "${TEMPDIR}/GeoLite2-ASN-Blocks-IPv4.csv"
#                           tail -n +2 "${TEMPDIR}/${file_source_csv_ipv6}" | head -n 1000 > "${TEMPDIR}/GeoLite2-ASN-Blocks-IPv6.csv"
#                       Move files to `local` folder.
#   
#       Option 2        Use the argument `--limit, -l`
#                            ./.github/scripts/bl-geolite2_asn.sh --local -a 7,10
#                       The command above will ONLY process any database entry with the ASN 7 and 10.
# #

# #
#   📗 Dryrun Mode
#   
#   Simulates downloading and processing without actually performing the CURL requests.
#       .github/scripts/bl-geolite2_asn.sh -d
#       .github/scripts/bl-geolite2_asn.sh --dry
#   
#   Grab the MaxMind database files. You can download them manually from:
#       - CSV URL: https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN-CSV&license_key=LICENSE_KEY&suffix=zip
#       - MD5 URL: https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN-CSV&license_key=LICENSE_KEY&suffix=zip.md5
#   
#   Place your own copies of the csv, or the zip + md5 file which contains the csv; pick ONE of the two:
#       1.  Using CSVs:
#           .github/local/GeoLite2-ASN-Blocks-IPv4.csv
#           .github/local/GeoLite2-ASN-Blocks-IPv6.csv
#       1.  Using ZIPs:
#           .github/local/GeoLite2-ASN-CSV.zip
#           .github/local/GeoLite2-ASN-CSV.zip.md5
#   
#   Dry-run mode is useful for testing or validating the script without hitting the MaxMind servers.
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

app_name="Blocklist › Geolite2 ASN"                                             # name of app
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
argIncludeBogon="false"                                                         # filter out BOGON IP addresses from list
argTrustedInput="false"                                                         # trusted input mode (skip validation loop)
argSkipBogonFilter="false"                                                      # skip bogon filter loop
argSkipCidrDedup="false"                                                        # skip overlapping CIDR dedupe loop
argIncludeComments="false"                                                      # preserve inline comments in output
argStdout="false"                                                               # output response to console instead of write to file
argTrustedInput="false"                                                         # trusted input mode (skip validation loop)
argASN=""                                                                       # Process specific ASN
argUseLocalDB="false"                                                           # Process local database instead of download
argMMLicense=""                                                                 # MaxMind license key
argLimitEntries=0                                                               # Number of entries to process; set to 0 or unset for full run
argFolder=""
argFile=""
argClean="false"                                                                # geolite2 folder will be wiped before generation
argAggressive="false"

# #
#   Optional Parameters
#   
#   The following list outlines the optional parameters that can be passed
#   when generating a blocklist using this script.
#   
#       CFG_TRUSTED_INPUT=<true|false>                                          Skip per-line IP/CIDR validation loop. Only enable if we trust the source.
#       CFG_SKIP_BOGON_FILTER=<true|false>                                      Skip bogon filtering loop.
#       CFG_SKIP_CIDR_DEDUPE=<true|false>                                       Skip overlapping CIDR dedupe loop.
#       CFG_INCLUDE_COMMENTS=<true|false>                                       Preserve inline # and ; comments after each IP/CIDR entry.
#                                                                                   true                            Automatically enables CFG_SKIP_CIDR_DEDUPE
#       CFG_SORT_PARALLEL=<N>                                                   Pass --parallel=<N> to sort command (if supported).
#                                                                                   sort --parallel                 change the number of sorts run concurrently to N
#       CFG_SORT_BUFFER_SIZE=<size>                                             Pass -S <size> to sort command (example: 50%, 1G).
#                                                                                   sort -S, --buffer-size=SIZE     use SIZE for main memory buffer
#       CFG_STDOUT=<true|false>                                                 Output list; do not write to file
#   
#   Usage:
#       curl -sSL -A "${{ env.USERAGENT }}" ${{ vars.BL_APPLE_INC_PROXY_URL }} \
#           | awk -F',' 'NR>1{print $1}' \
#           | CFG_TRUSTED_INPUT=true CFG_SKIP_BOGON_FILTER=true .github/scripts/bl-format.sh blocklists/privacy/privacy_apple_icloud.ipset
# #

case "${CFG_TRUSTED_INPUT:-false}" in
    1|true|TRUE|yes|YES|on|ON)
        argTrustedInput="true"
        ;;
esac

case "${CFG_SKIP_BOGON_FILTER:-false}" in
    1|true|TRUE|yes|YES|on|ON)
        argSkipBogonFilter="true"
        ;;
esac

case "${CFG_SKIP_CIDR_DEDUPE:-false}" in
    1|true|TRUE|yes|YES|on|ON)
        argSkipCidrDedup="true"
        ;;
esac

case "${CFG_INCLUDE_COMMENTS:-false}" in
    1|true|TRUE|yes|YES|on|ON)
        argIncludeComments="true"
        ;;
esac

case "${CFG_STDOUT:-false}" in
    1|true|TRUE|yes|YES|on|ON)
        argStdout="true"
        ;;
esac

# #
#   If preserving comments from the source; turn off dedupe. Otherwise some
#   comments will be missing since we're merging CIDRs together.
# #

if [ "${argIncludeComments}" = "true" ]; then
    argSkipCidrDedup="true"
fi

# #
#   Define › Time
# #

time_start=$( date +%s )                                                        # record start time of script
SECONDS=0                                                                       # set seconds count for beginning of script

# #
#   Define › Regex (Anchored)
#   
#   These patterns are STRICT matchers, which use ^ and $ anchors; meaning the 
#   ENTIRE string must match exactly.
#   
#   Example:
#       "1.2.3.4"       MATCH
#       "foo 1.2.3.4"   NO MATCH
# #

regex_url='^(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]\.[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]$'
regex_ipv4='^([0-9]{1,3}\.){3}[0-9]{1,3}$'
regex_ipv4_cidr='^([0-9]{1,3}\.){3}[0-9]{1,3}/([0-9]{1,2})$'
#regex_ipv6='^[0-9A-Fa-f:.]*:[0-9A-Fa-f:.]*$'
regex_ipv6='^(([0-9A-Fa-f]{1,4}:){7}[0-9A-Fa-f]{1,4}|(([0-9A-Fa-f]{1,4}:){1,7}:)|(([0-9A-Fa-f]{1,4}:){1,6}:[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){1,5}(:[0-9A-Fa-f]{1,4}){1,2})|(([0-9A-Fa-f]{1,4}:){1,4}(:[0-9A-Fa-f]{1,4}){1,3})|(([0-9A-Fa-f]{1,3}:){1,3}(:[0-9A-Fa-f]{1,4}){1,4})|(([0-9A-Fa-f]{1,4}:){1,2}(:[0-9A-Fa-f]{1,4}){1,5})|([0-9A-Fa-f]{1,4}:)((:[0-9A-Fa-f]{1,4}){1,6})|(:)((:[0-9A-Fa-f]{1,4}){1,7}|:))$'
regex_ipv6_cidr='^[0-9A-Fa-f:.]*:[0-9A-Fa-f:.]*/([0-9]{1,3})$'
regex_ipv4_range='([0-9]{1,3}\.){3}[0-9]{1,3}[[:space:]]*-[[:space:]]*([0-9]{1,3}\.){3}[0-9]{1,3}'

# #
#   Define › Regex (Unanchored)
#   
#   These patterns are derived from the anchored validators above; which remove 
#   ^ and $ so that the regex can match values inside text.
#   
#   Mainly these are used for stripping html and matching IP addresses which are
#   extracted.
# #

regex_ipv4_extract="${regex_ipv4#^}"
regex_ipv4_extract="${regex_ipv4_extract%\$}"
regex_ipv4_cidr_extract="${regex_ipv4_cidr#^}"
regex_ipv4_cidr_extract="${regex_ipv4_cidr_extract%\$}"
regex_ipv6_extract="${regex_ipv6#^}"
regex_ipv6_extract="${regex_ipv6_extract%\$}"
regex_ipv6_cidr_extract="${regex_ipv6_cidr#^}"
regex_ipv6_cidr_extract="${regex_ipv6_cidr_extract%\$}"
regex_ip_extract="${regex_ipv4_extract}|${regex_ipv4_cidr_extract}|${regex_ipv6_extract}|${regex_ipv6_cidr_extract}"

# #
#   Define › Defaults
# #

total_lines=0                                                                   # number of lines in doc
total_subnets=0                                                                 # number of IPs in all subnets combined
total_ips=0                                                                     # number of single IPs (counts each line)

# #
#   define variables
# #

folder_source_local="local"                                                     # local mode enabled: where to fetch local csv from
folder_target_storage="blocklists/geolite/asn"                                  # path to save ipsets
folder_target_temp="temp"                                                       # local mode disabled: where csv will be downloaded to
folder_target_logs=".logs"                                                      # path to store logs
folder_target_cache="cache"                                                     # location where countries and continents are stored as array to file
path_storage_ipv4="./${folder_target_storage}/ipv4"                             # folder to store .tmp ipv4 files
path_storage_ipv6="./${folder_target_storage}/ipv6"                             # folder to store .tmp ipv6 files
file_target_ext_tmp="tmp"                                                       # temp extension for ipsets before work is done
ext_target_ipset="ipset"                                                        # extension for ipsets
folder_source_cache=".daily/geolite2"                                           # cache folder shared across repeated workflow invocations
folder_source_cache_asn_index="asn-index"                                       # per-day ASN index cache folder
folder_target_aggressive="@general"                                             # aggressive subfolder
file_source_csv_ipv4="GeoLite2-ASN-Blocks-IPv4.csv"                             # Geolite2 ASN CSV IPv4
file_source_csv_ipv6="GeoLite2-ASN-Blocks-IPv6.csv"                             # Geolite2 ASN CSV IPv6
file_source_csv_zip="GeoLite2-ASN-CSV.zip"                                      # Geolite2 ASN CSV Zip
file_source_csv_zip_md5="${file_source_csv_zip}.md5"                            # Geolite2 ASN CSV Zip MD5 hash file
file_target_aggressive="aggressive"                                             # filename to store aggressive list
file_cfg="geolite2.conf"                                                        # Optional config file for license key / settings
path_cache_root="${app_dir_github}/${folder_source_cache}"                      # .github/.daily/geolite2
path_cache_asn_index_root="${path_cache_root}/${folder_source_cache_asn_index}" # .github/.daily/geolite2/asn-index
path_cache_asn_index_ipv4="${path_cache_asn_index_root}/ipv4"                   # indexed ASN rows from IPv4 CSV
path_cache_asn_index_ipv6="${path_cache_asn_index_root}/ipv6"                   # indexed ASN rows from IPv6 CSV
file_cache_asn_index_meta="${path_cache_asn_index_root}/meta.env"               # cache fingerprint metadata

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
for f in "${app_dir_github}/${folder_source_local}"/GeoLite2-ASN-CSV*.zip; do
    file_source_csv_zip="$f"
    break
done
for f in "${app_dir_github}/${folder_source_local}"/GeoLite2-ASN-CSV*.zip.md5; do
    file_source_csv_zip_md5="$f"
    break
done
shopt -u nullglob

# #
#   Color Code Test
#   
#   @usage      .github/scripts/bl-geolite2_asn.sh --color
# #

function debug_ColorTest( )
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
#   Helper > Show Color Chart
#   Shows a complete color charge which can be used with the color declarations in this script.
#   
#   @usage      .github/scripts/bt-transmission.sh chart
# #

function debug_ColorChart( )
{
    for fgbg in 38 48 ; do                                  # foreground / background
        for clr in {0..255} ; do                            # colors
            printf "\e[${fgbg};5;%sm  %3s  \e[0m" $clr $clr
            if [ $((($clr + 1) % 6)) == 4 ] ; then          # show 6 colors per lines
                echo
            fi
        done

        echo
    done
    
    exit 1
}

# #
#   func › usage menu
# #

opt_usage( )
{
    echo
    printf "  ${bluel}${app_name}${end}\n" 1>&2
    printf "  ${greym}${app_desc}${end}\n" 1>&2
    printf "  ${greyd}version:${end} ${greyd}$app_ver${end}\n" 1>&2
    printf "  ${fuchsiad}$app_file_this${end} ${greyd}[${greym}--help${greyd}]${greyd}  |  ${greyd}[${greym}--version ${greyd}]${greyd}  |  ${greyd}[${greym}--license ${yellowd}\"${argMMLicense:-"XXXX-0000-XXXXX"}\"${greyd} [${greym}--dryrun${greyd}]]${greyd}  |  ${greyd}[${greym}--local${greyd} [${greym}--limit ${yellowd}\"${argLimitEntries:-"1000"}\"${greyd}]]${end}" 1>&2
    echo
    echo
    printf '  %-5s %-40s\n' "${greyd}Syntax:${end}" "" 1>&2
    printf '  %-5s %-30s %-40s\n' "    " "${greyd}Command${end}           " "${fuchsiad}$app_file_this${greyd} [ ${greym}-option ${greyd}[ ${yellowd}arg${greyd} ]${greyd} ]${end}" 1>&2
    printf '  %-5s %-30s %-40s\n' "    " "${greyd}Options${end}           " "${fuchsiad}$app_file_this${greyd} [ ${greym}-h${greyd} | ${greym}--help${greyd} ]${end}" 1>&2
    printf '  %-5s %-30s %-40s\n' "    " "    ${greym}-A${end}            " " ${white}required" 1>&2
    printf '  %-5s %-30s %-40s\n' "    " "    ${greym}-A...${end}         " " ${white}required; multiple can be specified" 1>&2
    printf '  %-5s %-30s %-40s\n' "    " "    ${greym}[ -A ]${end}        " " ${white}optional" 1>&2
    printf '  %-5s %-30s %-40s\n' "    " "    ${greym}[ -A... ]${end}     " " ${white}optional; multiple can be specified" 1>&2
    printf '  %-5s %-30s %-40s\n' "    " "    ${greym}{ -A | -B }${end}   " " ${white}one or the other; do not use both" 1>&2
    printf '  %-5s %-30s %-40s\n' "    " "${greyd}Arguments${end}         " "${fuchsiad}$app_file_this${end} ${greyd}[ ${greym}-d${yellowd} arg${greyd} | ${greym}--name ${yellowd}arg${greyd} ]${end}${yellowd} arg${end}" 1>&2
    printf '  %-5s %-30s %-40s\n' "    " "${greyd}Examples${end}          " "${fuchsiad}$app_file_this${end} ${greym}--license${yellowd} \"${argMMLicense:-"XXXX-0000-XXXXX"}\" ${end}" 1>&2
    printf '  %-5s %-30s %-40s\n' "    " "${greyd}${end}                  " "${fuchsiad}$app_file_this${end} ${greym}--license${yellowd} \"${argMMLicense:-"XXXX-0000-XXXXX"}\" ${greym}--dryrun${yellowd} ${end}" 1>&2
    printf '  %-5s %-30s %-40s\n' "    " "${greyd}${end}                  " "${fuchsiad}$app_file_this${end} ${greym}--local${yellowd} ${end}" 1>&2
    printf '  %-5s %-30s %-40s\n' "    " "${greyd}${end}                  " "${fuchsiad}$app_file_this${end} ${greym}--local${yellowd} ${greym}--asn${yellowd} \"${argASN:-"7,10"}\" ${end}" 1>&2
    printf '  %-5s %-30s %-40s\n' "    " "${greyd}${end}                  " "${fuchsiad}$app_file_this${end} ${greym}--local${yellowd} ${greym}--limit${yellowd} \"1000\" ${end}" 1>&2
    printf '  %-5s %-30s %-40s\n' "    " "${greyd}${end}                  " "${fuchsiad}$app_file_this${end} ${greyd}[ ${greym}--help${greyd} | ${greym}-h${greyd} | ${greym}/?${greyd} ]${end}" 1>&2
    echo
    printf '  %-5s %-40s\n' "${greyd}Options:${end}" "" 1>&2
    printf '  %-5s %-81s %-40s\n' "    " "${bluel}-l${greyd},${bluel}  --license ${yellowd}<string>${end}            " "specifies MaxMind license to download databases ${navy}<default> ${peach}${argMMLicense:-"XXXX-0000-XXXXX"} ${end}" 1>&2
    printf '  %-5s %-81s %-40s\n' "    " "${bluel}-o${greyd},${bluel}  --local ${yellowd}${end}                      " "install local MaxMind database from zip + md5 or .csv ${navy}<default> ${peach}${argUseLocalDB:-"disabled"} ${end}" 1>&2
    printf '  %-5s %-81s %-40s\n' "    " "${bluel}  ${greyd} ${bluel}           ${yellowd}${end}                     " "    ${greyd}does not require Maxmind license key ${end}" 1>&2
    printf '  %-5s %-81s %-40s\n' "    " "${bluel}  ${greyd} ${bluel}           ${yellowd}${end}                     " "    ${greyd}local files must be placed within: ${end}" 1>&2
    printf '  %-5s %-81s %-40s\n' "    " "${bluel}  ${greyd} ${bluel}           ${yellowd}${end}                     " "    ${greym}1.  Using CSVs: ${end}" 1>&2
    printf '  %-5s %-81s %-40s\n' "    " "${bluel}  ${greyd} ${bluel}           ${yellowd}${end}                     " "    ${greyd}        ${app_dir_this_dir}/${folder_source_local}/GeoLite2-ASN-Blocks-IPv4.csv ${end}" 1>&2
    printf '  %-5s %-81s %-40s\n' "    " "${bluel}  ${greyd} ${bluel}           ${yellowd}${end}                     " "    ${greyd}        ${app_dir_this_dir}/${folder_source_local}/GeoLite2-ASN-Blocks-IPv6.csv ${end}" 1>&2
    printf '  %-5s %-81s %-40s\n' "    " "${bluel}  ${greyd} ${bluel}           ${yellowd}${end}                     " "    ${greym}2.  Using ZIPs: ${end}" 1>&2
    printf '  %-5s %-81s %-40s\n' "    " "${bluel}  ${greyd} ${bluel}           ${yellowd}${end}                     " "    ${greyd}        ${app_dir_this_dir}/${folder_source_local}/GeoLite2-ASN-CSV.zip ${end}" 1>&2
    printf '  %-5s %-81s %-40s\n' "    " "${bluel}  ${greyd} ${bluel}           ${yellowd}${end}                     " "    ${greyd}        ${app_dir_this_dir}/${folder_source_local}/GeoLite2-ASN-CSV.zip.md5 ${end}" 1>&2
    printf '  %-5s %-81s %-40s\n' "    " "${bluel}-a${greyd},${bluel}  --asn ${yellowd}<string>${end}                " "process database and only look for ips with specific ASN ${navy}<default> ${peach}${argASN:-"empty"} ${end}" 1>&2
    printf '  %-5s %-81s %-40s\n' "    " "${bluel}-p${greyd},${bluel}  --limit ${yellowd}<string>${end}              " "limit number of entries to process and stop ${navy}<default> ${peach}${argLimitEntries:-"0"} ${end}" 1>&2
    printf '  %-5s %-81s %-40s\n' "    " "${bluel}  ${greyd} ${bluel}           ${yellowd}${end}                     " "    ${greyd}set limit ${fuchsiad}0${end} for no limit ${end}" 1>&2
    printf '  %-5s %-81s %-40s\n' "    " "${bluel}-F${greyd},${bluel}  --folder ${yellowd}<string>${end}             " "puts ipsets in custom folder; instead of folder using ASN ${navy}<default> ${peach}${argFolder:-"empty"} ${end}" 1>&2
    printf '  %-5s %-81s %-40s\n' "    " "${bluel}  ${greyd} ${bluel}           ${yellowd}${end}                     " "    ${greyd}must be used with ${olive}--file, -f${end} arg ${end}" 1>&2
    printf '  %-5s %-81s %-40s\n' "    " "${bluel}-f${greyd},${bluel}  --file ${yellowd}<string>${end}               " "puts ipsets in custom file ${navy}<default> ${peach}${argFile:-"empty"} ${end}" 1>&2
    printf '  %-5s %-81s %-40s\n' "    " "${bluel}  ${greyd} ${bluel}           ${yellowd}${end}                     " "    ${greyd}must be used with ${olive}--folder, -F${end} arg ${end}" 1>&2
    printf '  %-5s %-81s %-40s\n' "    " "${bluel}-a${greyd},${bluel}  --aggressive ${yellowd}${end}                 " "specified list will be placed in two files; one being ${fuchsiad}${folder_target_storage}${end} before generating new ipsets ${navy}<default> ${peach}${argClean:-"disabled"} ${end}" 1>&2
    printf '  %-5s %-81s %-40s\n' "    " "${bluel}-c${greyd},${bluel}  --clean ${yellowd}${end}                      " "wipes all existing files in ${fuchsiad}${folder_target_storage}${end} before generating new ipsets ${navy}<default> ${peach}${argClean:-"disabled"} ${end}" 1>&2
    printf '  %-5s %-81s %-40s\n' "    " "${bluel}-u${greyd},${bluel}  --usage ${yellowd}${end}                      " "explains how to use this script ${end}" 1>&2
    printf '  %-5s %-81s %-40s\n' "    " "${bluel}-p${greyd},${bluel}  --paths ${yellowd}${end}                      " "displays the paths that are important to this script ${end}" 1>&2
    printf '  %-5s %-81s %-40s\n' "    " "${bluel}-D${greyd},${bluel}  --dryrun ${yellowd}${end}                     " "pass dryrun to csf installer script, does not install ${end} ${navy}<default> ${peach}${argDryrun:-"disabled"} ${end}" 1>&2
    printf '  %-5s %-81s %-40s\n' "    " "${bluel}-V${greyd},${bluel}  --version ${yellowd}${end}                    " "current version of this utilty ${end}" 1>&2
    printf '  %-5s %-81s %-40s\n' "    " "${bluel}-d${greyd},${bluel}  --dev ${yellowd}${end}                        " "developer mode; verbose logging ${end}" 1>&2
    printf '  %-5s %-81s %-40s\n' "    " "${bluel}-h${greyd},${bluel}  --help ${yellowd}${end}                       " "show this help menu ${end}" 1>&2
    echo
    echo
}

# #
#   Display help text if command not complete
# #

while [ $# -gt 0 ]; do
    case "$1" in
        -u|--usage)
            echo
            echo "  ${white}To use this script, use one of the following methods:\n"
            echo "  ${greenl}${bold}   License Key / Normal Mode ${end}"
            echo "  ${greym}${bold}   This method requires no files to be added. The asn files will be downloaded from the ${end}"
            echo "  ${greym}${bold}   MaxMind website / servers. ${end}"
            echo "  ${bluel}         ./${app_file_this} -l ABCDEF1234567-01234 ${end}"
            echo "  ${bluel}         ./${app_file_this} -l ABCDEF1234567-01234 ${end}"
            echo
            echo
            echo "  ${greenl}${bold}   Local Mode .................................................................................................. ${dim}[ Option 1 ] ${end}"
            echo "  ${greym}   This mode allows you to use local copies of the GeoLite2 database files to generate an IP list instead of ${end}"
            echo "  ${greym}   downloading a fresh copy of the .CSV / .ZIP files from the MaxMind website. This method requires you to ${end}"
            echo "  ${greym}   place the .ZIP, and .ZIP.MD5 file in the folder ${oranged}${app_dir_github}/${folder_source_local} ${end}"
            echo
            echo "  ${greym}${bold}   Download the following files from the MaxMind website: ${end}"
            echo "  ${bluel}         https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN-CSV&license_key=LICENSE_KEY&suffix=zip ${end}"
            echo "  ${bluel}         https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN-CSV&license_key=LICENSE_KEY&suffix=zip.md5 ${end}"
            echo
            echo "  ${greym}${bold}   Place the ${greend}.ZIP${end} and ${greend}.ZIP.MD5${end} files in: ${end}"
            echo "  ${bluel}         ${app_dir_github}/${folder_source_local} ${end}"
            echo
            echo "  ${greym}${bold}   The filenames MUST be: ${end}"
            echo "  ${bluel}         ${app_dir_github}/${folder_source_local}/GeoLite2-ASN-CSV.zip ${end}"
            echo "  ${bluel}         ${app_dir_github}/${folder_source_local}/GeoLite2-ASN-CSV.zip.md5 ${end}"
            echo
            echo "  ${greym}${bold}   Run the following command: ${end}"
            echo "  ${bluel}         ./${app_file_this} --local ${end}"
            echo "  ${bluel}         ./${app_file_this} -o ${end}"
            echo
            echo
            echo "  ${greenl}${bold}   Local Mode .................................................................................................. ${dim}[ Option 2 ] ${end}"
            echo "  ${greym}   This mode allows you to use local copies of the GeoLite2 database files to generate an IP list instead of ${end}"
            echo "  ${greym}   downloading a fresh copy of the .ZIP files from the MaxMind website. This method requires you to extract ${end}"
            echo "  ${greym}   the .ZIP and place the .CSV files in the folder ${oranged}${app_dir_github}/${folder_source_local} ${end}"
            echo
            echo "  ${greym}${bold}   Download the following file from the MaxMind website: ${end}"
            echo "  ${bluel}         https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN-CSV&license_key=LICENSE_KEY&suffix=zip ${end}"
            echo
            echo "  ${greym}${bold}   Open the .ZIP and extract the following files to the folder ${oranged}${app_dir_github}/${folder_source_local} ${end}"
            echo "  ${bluel}         ${app_dir_github}/${folder_source_local}/GeoLite2-ASN-Blocks-IPv4.csv ${end}"
            echo "  ${bluel}         ${app_dir_github}/${folder_source_local}/GeoLite2-ASN-Blocks-IPv6.csv ${end}"
            echo
            echo "  ${greym}${bold}   Run the following command: ${end}"
            echo "  ${bluel}         ./${app_file_this} --local ${end}"
            echo "  ${bluel}         ./${app_file_this} -o ${end}"
            echo
            echo
            echo "  ${greenl}${bold}   Dry Run ..................................................................................................... ${end}"
            echo "  ${greym}   This mode allows you to simulate downloading the .ZIP files from the MaxMind website. However, the CURL ${end}"
            echo "  ${greym}   commands will not actually be ran. Instead, the script will look for the needed database files in the ${end}"
            echo "  ${greym}   ${folder_target_temp} folder. This method requires you to place either the .ZIP & .ZIP.MD5 files, or extracted CSV files ${end}"
            echo "  ${greym}   in the folder ${oranged}${app_dir_github}/${folder_target_temp} ${end}"
            echo
            echo "  ${greym}${bold}   Place the .ZIP & .MD5 file, OR the .CSV files in the folder ${oranged}${app_dir_github}/${folder_target_temp} ${end}"
            echo "  ${bluel}         ${app_dir_github}/${folder_target_temp}/GeoLite2-ASN-Blocks-IPv4.csv ${end}"
            echo "  ${bluel}         ${app_dir_github}/${folder_target_temp}/GeoLite2-ASN-Blocks-IPv6.csv ${end}"
            echo
            echo "  ${bluel}         ${app_dir_github}/${folder_target_temp}/GeoLite2-ASN-CSV.zip ${end}"
            echo "  ${bluel}         ${app_dir_github}/${folder_target_temp}/GeoLite2-ASN-CSV.zip.md5 ${end}"
            echo
            echo "  ${greym}${bold}   Run the following command: ${end}"
            echo "  ${bluel}         ./${app_file_this} --dry${end}"
            echo "  ${bluel}         ./${app_file_this} -d${end}"
            echo
            exit 1
            ;;

        -p|--paths)
            echo
            echo "  ${white}List of paths important to this script:"
            echo "  ${greenl}📁 ${bold}${oranged}${app_dir_github}/${folder_source_local} ${end}"
            echo "  ${greym}    Folder used when Local Mode enabled ${greend}(--local) ${end}"
            echo "  ${greym}        Can detect GeoLite2 ${bluel}.ZIP${greym} and ${bluel}.ZIP.MD5${greym} files ${end}"
            echo "  ${greym}        Can detect GeoLite2 ${bluel}.CSV${greym} location and IPv4/IPv6 files ${end}"
            echo
            echo
            echo "  ${greenl}📁 ${bold}${oranged}${app_dir_github}/${folder_target_temp} ${end}"
            echo "  ${greym}    Folder used when Dry Run enabled ${greend}(--dry) ${end}"
            echo "  ${greym}        Can detect GeoLite2 ${bluel}.ZIP${greym} and ${bluel}.ZIP.MD5${greym} files ${end}"
            echo "  ${greym}        Can detect GeoLite2 ${bluel}.CSV${greym} location and IPv4/IPv6 files ${end}"
            echo
            echo
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
                    argLimitEntries=$(echo "$1" | cut -d= -f2)
                    ;;
                *)
                    shift
                    argLimitEntries="$1"
                    ;;
            esac
            ;;

        -F|--folder)
            case "$1" in
                *=*)
                    argFolder=$(echo "$1" | cut -d= -f2)
                    ;;
                *)
                    shift
                    argFolder="$1"
                    ;;
            esac

            if [ -z "${argFolder}" ]; then
                echo
                echo "  You must provide a valid folder"
                echo "  Example: ./${app_file_this} --folder=c"
                echo
                exit 1
            fi
            ;;

        -f|--file)
            case "$1" in
                *=*)
                    argFile=$(echo "$1" | cut -d= -f2)
                    ;;
                *)
                    shift
                    argFile="$1"
                    ;;
            esac

            if [ -z "${argFile}" ]; then
                echo
                echo "  You must provide a valid folder"
                echo "  Example: ./${app_file_this} --file=cloudflare"
                echo
                exit 1
            fi
            ;;

        -a|--asn)
            argASN=""
            shift
            while [ $# -gt 0 ] && [[ "$1" != -* ]]; do
                # #
                #   append current token with a space
                # #

                argASN="$argASN $1"
                shift
            done

            argASN="${argASN#"${argASN%%[! ]*}"}"  # trim leading spaces

            if [ -z "$argASN" ]; then
                echo "No ASN specified"
                exit 1
            fi

            # #
            #   remove AS/ASN, replace spaces with commas
            # #

            argASN=$(echo "$argASN" \
                | tr '[:upper:]' '[:lower:]' \
                | sed 's/asn\{0,1\}//g; s/[^0-9, ]//g; s/[[:space:]]\+/,/g; s/,,*/,/g; s/^,//; s/,$//')
            IFS=',' read -ra FILTER_ASNS <<< "$argASN"
            ;;

        -c|--clean)
            argClean=true
            echo "  ${redl}Cleaning storage folder ${folder_target_storage} ${end}"
            ;;
    
        -d|--dev|--debug)
            argDevMode=true
            echo "    ⚠️ Debug Mode › ${blink}${greyd}enabled${greym}${end}"
            ;;

        -o|--local)
            argUseLocalDB=true
            echo "  Local Mode Enabled"
            ;;

        --dry|--dryrun)
            argDryrun=true
            echo "  Dry Run Enabled"
            ;;

        -a|--aggressive)
            argAggressive=true
            ;;

        -v|--version)
            echo
            echo "  ${bluel}${bold}${app_name}${end} - v${app_ver} ${end}"
            echo "  ${greenl}${bold}https://github.com/${app_repo} ${end}"
            echo
            exit 1
            ;;

        -C|--color)
            debug_ColorTest
            exit 1
            ;;

        -G|--graph|--chart)
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
#       Capture end time
#       Calculate elapsed time
#       Calculate days, hours, etc.
#       Output to console
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
#   Reuse mode helper
#       - enabled when BL_GEOLITE2_REUSE_TEMP is truthy
#       - used to skip repeated staging cleanup across many invocations
# #

geolite2_ReuseEnabled( )
{
    case "${BL_GEOLITE2_REUSE_TEMP:-false}" in
        1|true|TRUE|yes|YES)
            return 0
            ;;
    esac

    return 1
}

# #
#   Print › Demo Notifications
#   
#   Outputs a list of example notifications
#   
#   @usage          demoNoti
# #

demoNoti()
{
    verbose "This is an verbose message"
    debug "This is an debug message"
    info "This is an info message"
    ok "This is an ok message"
    warn "This is a warn message"
    danger "This is a danger message"
    error "This is an error message"
}

# #
#   truncate text; add ...
#   
#   @usage
#       truncate "This is a long string" 10 "..."
# #

truncate()
{
    _text=$1
    _maxlen=$2
    _suffix=${3:-}

    _len=$(printf %s "${_text}" | wc -c | tr -d '[:space:]')

    if [ "${_len}" -gt "${_maxlen}" ]; then
        printf '%s%s\n' "$(printf %s "${_text}" | cut -c1-"${_maxlen}")" "${_suffix}"
    else
        printf '%s\n' "${_text}"
    fi

    # #
    #   Unset
    # #

    unset   _text _maxlen _suffix _len
}

# #
#   Print › Line
#   
#   Prints single line horizontal line, no text
#   
#   @usage          prin0
# #

prin0()
{
    _indent="  "
    _box_width=110
    _line_width=$(( _box_width + 2 ))

    _line=""
    _i=1
    while [ "$_i" -le "${_line_width}" ]; do
        _line="${_line}─"
        _i=$(( _i + 1 ))
    done

    printf '\n'
    printf "%b%s%s%b\n" "${greyd}" "${_indent}" "${_line}" "${end}"
    printf '\n'

    # #
    #   Unset
    # #

    unset   _indent _box_width _line_width _line _i
}

# #
#   Print › Box › Single
#   
#   Prints single line with a box surrounding it.
#   
#   @usage          prinb "${APP_NAME_SHORT:-CSF} › Customize csf.config"
# #

prinb()
{
    _title="$*"
    _indent="   "                                                               # Left padding
    _padding=6                                                                  # Extra horizontal space around text
    _title_length=${#_title}
    _inner_width=$(( _title_length + _padding ))
    _box_width=110

    # #
    #   Minimum width for aesthetics
    # #

    if [ "$_inner_width" -lt "$_box_width" ]; then
        _inner_width=$_box_width
    fi

    # #
    #   Horizontal border
    # #

    _line=""
    _i=1
    while [ "$_i" -le "$_inner_width" ]; do
        _line="${_line}─"
        _i=$(( _i + 1 ))
    done

    # #
    #   Draw box
    # #

    printf '\n'
    printf '\n'
    printf "%b%s┌%s┐\n" "${greym}" "$_indent" "$_line"
    printf "%b%s│  %-${_inner_width}s \n" "${greym}" "$_indent" "$_title"
    printf "%b%s└%s┘%b\n" "${greym}" "$_indent" "$_line" "${end}"
    printf '\n'

    # #
    #   Unset
    # #

    unset   _title _indent _padding \
            _title_length _inner_width _box_width \
            _line _i
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
#   Define › Logging › Verbose
# #

log( )
{
    case "${argVerbose:-0}" in
        1|true|TRUE|yes|YES)
            verbose "$@"
            ;;
    esac
}

# #
#   Define › Sudo
# #

check_sudo( )
{
    if [ "$(id -u)" != "0" ]; then
        error "    ❌ Must run script with ${redl}sudo${end}"
        exit 1
    fi
}

# #
#   Define › Run Command
#   
#   Added when dryrun mode was added to the install.sh.
#   Allows for a critical command to be skipped if in --dryrun mode.
#       Throws a debug message instead of executing.
#   
#   argDryrun comes from global export in csf/install.sh
#   
#   @usage          run /sbin/chkconfig csf off
#                   run echo "ConfigServer"
#                   run chmod -v 700 "./${CSF_AUTO_GENERIC}"
# #

run()
{
    if [ "${argDryrun}" = "true" ]; then
        debug "    Drymode (skip): $*"
    else
        debug "    Run: $*"
        "$@"
    fi
}

# #
#   Define
# #

readonly CONFIGS_LIST="${APP_GEO_LOCS_CSV} ${file_source_csv_ipv4} ${file_source_csv_ipv6}"

# #
#   Configure sort options
#   
#   Builds the options array for the `sort` command based on user settings:
#       If `argSortParallel` is valid number and the system supports it, enable parallel sorting with that value.
#       If `argSortBufferSize` is set, apply it as the sort buffer size (-S).
#       Log what gets enabled or warns if values are invalid or unsupported.
# #

configure_sort_options( )
{
    sort_cmd_opts=()

    if [ -n "${argSortParallel}" ]; then
        if [[ "${argSortParallel}" =~ ^[1-9][0-9]*$ ]]; then
            if sort --help 2>/dev/null | grep -q -- '--parallel'; then
                sort_cmd_opts+=( "--parallel=${argSortParallel}" )
                info "    ⚙️  Sort parallelism enabled (${yellowl}${argSortParallel}${greym})"
            else
                warn "    ⚠️  sort --parallel unsupported; running with default sort options"
            fi
        else
            warn "    ⚠️  Invalid CFG_SORT_PARALLEL value ${yellowl}${argSortParallel}${greym}; ignoring"
        fi
    fi

    if [ -n "${argSortBufferSize}" ]; then
        sort_cmd_opts+=( "-S" "${argSortBufferSize}" )
        info "    ⚙️  Sort buffer size set to ${yellowl}${argSortBufferSize}${greym}"
    fi
}

# #
#   Extract canonical IP/CIDR entry from a line
#       Strip inline # / ; comments
#       Normalize whitespace
#       If IPv4 range supplied (A - B), return A
# #

extract_ip_entry( )
{
    _fnEntry="$1"

    _fnEntry="${_fnEntry%%#*}"
    _fnEntry="${_fnEntry%%;*}"

    # #
    #   Trim leading and trailing whitespace
    # #

    _fnEntry="${_fnEntry#"${_fnEntry%%[![:space:]]*}"}"
    _fnEntry="${_fnEntry%"${_fnEntry##*[![:space:]]}"}"

    # #
    #   If IPv4 range is supplied (A - B), keep A
    # #

    if [[ "${_fnEntry}" =~ ^(([0-9]{1,3}\.){3}[0-9]{1,3})[[:space:]]*-[[:space:]]*([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        _fnEntry="${BASH_REMATCH[1]}"
    fi

    printf '%s\n' "${_fnEntry}"

    # #
    #   Unset
    # #

    unset   _fnEntry
}

# #
#   Normalize whitespace-delimited input to one IP/CIDR per line
#       Used in non-comment mode after comment stripping.
# #

normalize_ip_lines( )
{
    _fnNormFile=$1
    _fnNormTmp=$(mktemp) || return 1

    tr -s '[:space:]' '\n' < "${_fnNormFile}" > "${_fnNormTmp}"
    sed -i '/^$/d' "${_fnNormTmp}"

    mv "${_fnNormTmp}" "${_fnNormFile}"

    # #
    #   Unset
    # #

    unset   _fnNormFile _fnNormTmp
}

# #
#   Sort Results
#   
#   @usage          sort_results < "${file_ipset_target}" > "${file_ipset_target}.sort"
#                   grep -vE '^[[:space:]]*(#|;|$)' "${file_ipset_target}" | sort_results > "${file_ipset_target}.sort"
# #

sort_results()
{
    # Temp files for input and split output
    _in_tmp=$(mktemp) || exit 1
    _ipv4_tmp=$(mktemp) || exit 1
    _ipv6_tmp=$(mktemp) || exit 1

    cat > "${_in_tmp}"

    if [ ! -s "${_in_tmp}" ]; then
        rm -f "${_in_tmp}" "${_ipv4_tmp}" "${_ipv6_tmp}"
        unset   _in_tmp _ipv4_tmp _ipv6_tmp
        return 0
    fi

    if [ "${argIncludeComments}" = "true" ]; then

        # #
        #   Read stdin line by line
        # #

        while IFS= read -r line; do
            _fnSortKey=$(extract_ip_entry "${line}")
            [ -z "${_fnSortKey}" ] && continue
            _fnSortPriority=1

            case "${line}" in
                *"#"*|*";"*)
                    _fnSortPriority=0
                    ;;
            esac

            case "${_fnSortKey}" in
                *:*)
                    printf '%s\t%s\t%s\n' "${_fnSortKey}" "${_fnSortPriority}" "${line}" >> "${_ipv6_tmp}"
                    ;;
                *)
                    _fnSortIpv4="${_fnSortKey%%/*}"
                    if [[ "${_fnSortIpv4}" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
                        IFS='.' read -r _fnSortO1 _fnSortO2 _fnSortO3 _fnSortO4 <<< "${_fnSortIpv4}"
                        printf '%03d\t%03d\t%03d\t%03d\t%s\t%s\t%s\n' \
                            "${_fnSortO1}" "${_fnSortO2}" "${_fnSortO3}" "${_fnSortO4}" "${_fnSortKey}" "${_fnSortPriority}" "${line}" >> "${_ipv4_tmp}"
                    fi
                    ;;
            esac
        done < "${_in_tmp}"

        # #
        #   Sort IPv4 numerically, remove duplicates by canonical key
        # #

        if [ -s "${_ipv4_tmp}" ]; then
            LC_ALL=C sort "${sort_cmd_opts[@]}" -s -t$'\t' -n -k1,1 -k2,2 -k3,3 -k4,4 -k5,5 -k6,6n "${_ipv4_tmp}" \
                | awk -F '\t' '!seen[$5]++ { print $7 }'
        fi

        # #
        #   Sort IPv6 lexicographically, remove duplicates by canonical key
        # #

        if [ -s "${_ipv6_tmp}" ]; then
            LC_ALL=C sort "${sort_cmd_opts[@]}" -s -t$'\t' -k1,1 -k2,2n "${_ipv6_tmp}" \
                | awk -F '\t' '!seen[$1]++ { print $3 }'
        fi

        # #
        #   Clean up temp files
        # #
    
        rm -f "${_in_tmp}" "${_ipv4_tmp}" "${_ipv6_tmp}"

        # #
        #   Unset
        # #

        unset   _in_tmp _ipv4_tmp _ipv6_tmp _fnSortKey _fnSortPriority _fnSortIpv4 _fnSortO1 _fnSortO2 _fnSortO3 _fnSortO4
        return 0
    fi

    # #
    #   Fast path › pure IPv4
    # #

    if ! grep -q ':' "${_in_tmp}"; then
        LC_ALL=C sort "${sort_cmd_opts[@]}" -t. -n -k1,1 -k2,2 -k3,3 -k4,4 "${_in_tmp}" | uniq

    # #
    #   Fast path › pure IPv6
    # #

    elif ! grep -q '\.' "${_in_tmp}"; then
        LC_ALL=C sort "${sort_cmd_opts[@]}" "${_in_tmp}" | uniq

    # #
    #   Mixed IPv4/IPv6
    # #

    else
        awk '
        index($0, ":") { print > v6; next }
                        { print > v4 }
        ' v4="${_ipv4_tmp}" v6="${_ipv6_tmp}" "${_in_tmp}"

        # #
        #   Sort IPv4 numerically, remove duplicates
        # #

        if [ -s "${_ipv4_tmp}" ]; then
            LC_ALL=C sort "${sort_cmd_opts[@]}" -t. -n -k1,1 -k2,2 -k3,3 -k4,4 "${_ipv4_tmp}" | uniq
        fi

        # #
        #   Sort IPv6 lexicographically, remove duplicates
        # #
    
        if [ -s "${_ipv6_tmp}" ]; then
            LC_ALL=C sort "${sort_cmd_opts[@]}" "${_ipv6_tmp}" | uniq
        fi
    fi

    # #
    #   Clean up temp files
    # #

    rm -f "${_in_tmp}" "${_ipv4_tmp}" "${_ipv6_tmp}"

    # #
    #   Unset
    # #

    unset   _in_tmp _ipv4_tmp _ipv6_tmp
}

# #
#   Validate › IPv4 › Single
#   
#   @usage          is_valid_ipv4 "${_fnEntry}" && return 0
#                       return 0    success (valid IP)
#                       return 1    failure (invalid IP)
# #

is_valid_ipv4()
{
    _fnIp=$1

    [[ ${_fnIp} =~ ${regex_ipv4} ]] || return 1

    IFS='.' read -r _fnO1 _fnO2 _fnO3 _fnO4 <<< "${_fnIp}"
    for _fnOctet in "${_fnO1}" "${_fnO2}" "${_fnO3}" "${_fnO4}"; do
        [ "${_fnOctet}" -ge 0 ] 2>/dev/null || return 1
        [ "${_fnOctet}" -le 255 ] || return 1
    done

    # #
    #   Unset
    # #

    unset   _fnIp _fnO1 _fnO2 _fnO3 _fnO4 _fnOctet
    return 0
}

# #
#   Validate › IPv4 › CIDR
#   
#   Validates IPV4 CIDR such as 192.168.1.1/24.
#   
#   @usage          is_valid_ipv4_cidr "${_fnEntry}" && return 0
#                       return 0    success (valid IP / CIDR)
#                       return 1    failure (invalid IP / CIDR)
# #

is_valid_ipv4_cidr()
{
    _fnIpCidr=$1
    _fnIp="${_fnIpCidr%/*}"
    _fnCidr="${_fnIpCidr#*/}"

    [[ ${_fnIpCidr} =~ ${regex_ipv4_cidr} ]] || return 1
    is_valid_ipv4 "${_fnIp}" || return 1
    [ "${_fnCidr}" -ge 0 ] 2>/dev/null || return 1
    [ "${_fnCidr}" -le 32 ] || return 1

    # #
    #   Unset
    # #

    unset   _fnIpCidr _fnIp _fnCidr
    return 0
}

# #
#   Validate › IPv6 › Single
#   
#   Validates IPV6 address.
#   
#   @usage          is_valid_ipv6 "${_fnEntry}" && return 0
#                       return 0    success (valid IP)
#                       return 1    failure (invalid IP)
# #

is_valid_ipv6()
{
    _fnIp=$1
    _fnColonCount=0

    [[ ${_fnIp} =~ ${regex_ipv6} ]] || return 1
    printf '%s' "${_fnIp}" | grep -Eq '^[0-9A-Fa-f:.]+$' || return 1
    _fnColonCount=$(printf '%s' "${_fnIp}" | awk -F':' '{print NF-1}')
    [ "${_fnColonCount}" -ge 2 ] || return 1

    # #
    #   Unset
    # #
    unset   _fnIp _fnColonCount
    return 0
}

# #
#   Validate › IPv6 › CIDR
#   
#   Validates IPV6 CIDR address.
#   
#   @usage          is_valid_ipv6_cidr "${_fnEntry}" && return 0
#                       return 0    success (valid IP / CIDR)
#                       return 1    failure (invalid IP / CIDR)
# #

is_valid_ipv6_cidr()
{
    _fnIpCidr=$1
    _fnIp="${_fnIpCidr%/*}"
    _fnCidr="${_fnIpCidr#*/}"

    [[ ${_fnIpCidr} =~ ${regex_ipv6_cidr} ]] || return 1
    is_valid_ipv6 "${_fnIp}" || return 1
    [ "${_fnCidr}" -ge 0 ] 2>/dev/null || return 1
    [ "${_fnCidr}" -le 128 ] || return 1

    # #
    #   Unset
    # #

    unset   _fnIpCidr _fnIp _fnCidr
    return 0
}

# #
#   Validate › Generic IP Entry
# #

is_valid_ip_entry()
{
    _fnEntry=$1

    is_valid_ipv4       "${_fnEntry}" && return 0
    is_valid_ipv4_cidr  "${_fnEntry}" && return 0
    is_valid_ipv6       "${_fnEntry}" && return 0
    is_valid_ipv6_cidr  "${_fnEntry}" && return 0

    # #
    #   Unset
    # #

    unset   _fnEntry

    return 1
}

# #
#   Filter invalid IP entries from file
# #

filter_valid_ip_entries()
{
    _fnValidateFile=$1
    _fnValidateTemp="${_fnValidateFile}.valid"
    _fnValidateRemoved=0

    > "${_fnValidateTemp}"

    while IFS= read -r _fnValidateLine || [ -n "${_fnValidateLine}" ]; do
        [ -z "${_fnValidateLine}" ] && continue
    
        if [ "${argIncludeComments}" = "true" ]; then
            _fnValidateEntry=$(extract_ip_entry "${_fnValidateLine}")

            if [ -n "${_fnValidateEntry}" ] && is_valid_ip_entry "${_fnValidateEntry}"; then
                printf '%s\n' "${_fnValidateLine}" >> "${_fnValidateTemp}"
            else
                _fnValidateRemoved=$(( _fnValidateRemoved + 1 ))
            fi
        else
            if is_valid_ip_entry "${_fnValidateLine}"; then
                printf '%s\n' "${_fnValidateLine}" >> "${_fnValidateTemp}"
            else
                _fnValidateRemoved=$(( _fnValidateRemoved + 1 ))
            fi
        fi
    done < "${_fnValidateFile}"

    mv "${_fnValidateTemp}" "${_fnValidateFile}"

    if [ "${_fnValidateRemoved}" -gt 0 ]; then
        warn "    ⚠️  Removed ${orangel}${_fnValidateRemoved}${greym} invalid IP/CIDR entries"
    fi

    # #
    #   Unset
    # #

    unset   _fnValidateFile _fnValidateTemp _fnValidateRemoved _fnValidateLine _fnValidateEntry
}

# #
#   Count file statistics
#       IPv4 CIDR contributes all IPv4 addresses in the subnet
#       IPv6 CIDR contributes one entry (do not expand)
#       Single IPv4/IPv6 contributes one entry
# #

count_ip_stats( )
{
    _fnCountFile=$1
    _fnStatsLine=""
    _fnTotalIps=0
    _fnTotalSubnets=0

    if [ ! -s "${_fnCountFile}" ]; then
        total_ips=0
        total_subnets=0
        unset   _fnCountFile _fnStatsLine _fnTotalIps _fnTotalSubnets
        return 0
    fi

    _fnStatsLine=$(awk -v include_comments="${argIncludeComments}" '
        function trim(s) {
            sub(/^[[:space:]]+/, "", s)
            sub(/[[:space:]]+$/, "", s)
            return s
        }
        function is_ipv4(ip, octets, i) {
            if (index(ip, ":") > 0) {
                return 0
            }
            if (split(ip, octets, ".") != 4) {
                return 0
            }
            for (i = 1; i <= 4; i++) {
                if (octets[i] !~ /^[0-9]+$/) {
                    return 0
                }
                if (length(octets[i]) < 1 || length(octets[i]) > 3) {
                    return 0
                }
            }
            return 1
        }
        function is_ipv6(ip) {
            return (index(ip, ":") > 0 && ip ~ /^[0-9A-Fa-f:.]+$/)
        }
        BEGIN {
            total_ips = 0
            total_subnets = 0
        }
        {
            entry = $0

            if (include_comments == "true") {
                sub(/[[:space:]]*[#;].*$/, "", entry)
            }

            entry = trim(entry)
            if (entry == "") {
                next
            }

            if (index(entry, "/") > 0) {
                if (split(entry, parts, "/") != 2) {
                    next
                }
                base = parts[1]
                cidr = parts[2]

                if (cidr !~ /^[0-9]+$/) {
                    next
                }
                cidr += 0

                if (is_ipv4(base)) {
                    if (cidr <= 32) {
                        total_ips += (2 ^ (32 - cidr))
                        total_subnets++
                    }
                } else if (is_ipv6(base)) {
                    if (cidr <= 128) {
                        total_ips++
                        total_subnets++
                    }
                }

                next
            }

            if (is_ipv4(entry) || is_ipv6(entry)) {
                total_ips++
            }
        }
        END {
            printf "%.0f %.0f\n", total_ips, total_subnets
        }
    ' "${_fnCountFile}")

    _fnTotalIps=${_fnStatsLine%% *}
    _fnTotalSubnets=${_fnStatsLine##* }

    total_ips=${_fnTotalIps:-0}
    total_subnets=${_fnTotalSubnets:-0}

    # #
    #   Unset
    # #

    unset   _fnCountFile _fnStatsLine _fnTotalIps _fnTotalSubnets
}

# #
#   IPSET › Filter BOGON › IPv4
#   
#   Check if IPv4 matches known bogon ranges
# #

is_bogon_ipv4( )
{
    _fnBogonIp=$1

    case "${_fnBogonIp}" in
        0.*|10.*|127.*|127.0.53.53|169.254.*|192.168.*|255.255.255.255)
            return 0
            ;;

        100.6[4-9].*|100.[7-9][0-9].*|100.1[01][0-9].*|100.12[0-7].*)           # 100.64.0.0/10
            return 0
            ;;

        172.1[6-9].*|172.2[0-9].*|172.3[0-1].*)                                 # 172.16.0.0/12
            return 0
            ;;

        192.0.0.*|192.0.2.*|198.18.*|198.19.*|198.51.100.*|203.0.113.*)
            return 0
            ;;

        22[4-9].*|23[0-9].*|24[0-9].*|25[0-5].*)                                # 224.0.0.0/4 + 240.0.0.0/4
            return 0
            ;;
    esac

    return 1
}

# #
#   IPSET › Filter BOGON › IPv6
#   
#   Check if IPv6 matches known bogon ranges
# #

is_bogon_ipv6( )
{
    _fnBogonIp="${1,,}"
    _fnBogonIp="${_fnBogonIp%%/*}"

    case "${_fnBogonIp}" in
        ::|::1|::ffff:*|::*)                                                        # ::/128 ::1/128 ::ffff:0:0/96 ::/96
            return 0
            ;;

        100:*|100::*)                                                               # 100::/64
            return 0
            ;;

        2001:1[0-9a-f]:*|2001:01[0-9a-f]:*|2001:001[0-9a-f]:*|2001:0001[0-9a-f]:*)  # 2001:10::/28
            return 0
            ;;

        2001:db8:*|3fff:*|fc*|fd*|fe8*|fe9*|fea*|feb*|fec*|fed*|fee*|fef*|ff*)
            return 0
            ;;
    esac

    return 1
}

# #
#   IPSET › Filter BOGON Addresses
#   
#   Some of our IPSETs will include BOGON addresses which may cause issues with
#   users who are not expecting such IPs to be included.
#   
#   This functionality removes the BOGON addresses completely before the list is
#   counted.
#   
#       - Runs only when argIncludeBogon=false
#       - Run before count_ip_stats to ensure count accuracy
# #

filter_bogon_ips( )
{
    _fnBogonFile=$1
    _fnBogonTemp="${1}.bogon"
    _fnBogonLine=""
    _fnBogonBase=""
    _fnBogonBefore=0
    _fnBogonAfter=0
    _fnBogonRemoved=0

    if [ "${argSkipBogonFilter}" = "true" ]; then
        info "    ⚡ Skipping bogon filtering (CFG_SKIP_BOGON_FILTER=true)"
        return 0
    fi

    case "${argIncludeBogon:-true}" in
        1|true|TRUE|yes|YES)
            return 0
            ;;
    esac

    if [ ! -f "${_fnBogonFile}" ]; then
        warn "    ⚠️  Bogon filter skipped; file not found ${yellowl}${_fnBogonFile}${greym}"
        return 0
    fi

    info "    🚫 Filtering bogon IP ranges from ${bluel}${PWD}/${_fnBogonFile}${greym}"

    _fnBogonBefore=$(wc -l < "${_fnBogonFile}")
    > "${_fnBogonTemp}"

    # #
    #   If we specify CFG_INCLUDE_COMMENTS=true
    #       curl -s https://gist.githubusercontent.com/BBcan177/d7105c242f17f4498f81/raw/f69be712a06e998191adfe4c86d74e8cacf08d28/MS-3 | CFG_INCLUDE_COMMENTS=true .github/scripts/bl-format.sh blocklists/3rdparty/BBcan177/ms3.ipset
    # #

    if [ "${argIncludeComments}" = "true" ]; then
        while IFS= read -r _fnBogonLine || [ -n "${_fnBogonLine}" ]; do
            [ -z "${_fnBogonLine}" ] && continue
            _fnBogonEntry=$(extract_ip_entry "${_fnBogonLine}")
            [ -z "${_fnBogonEntry}" ] && continue
            _fnBogonBase="${_fnBogonEntry%%/*}"

            if [[ "${_fnBogonBase}" == *:* ]]; then
                if is_bogon_ipv6 "${_fnBogonEntry}"; then
                    label "        ${bluel}${_fnBogonLine}${greym}"
                    _fnBogonRemoved=$(( _fnBogonRemoved + 1 ))
                    continue
                fi
            elif [[ "${_fnBogonBase}" == *.* ]]; then
                if is_bogon_ipv4 "${_fnBogonBase}"; then
                    label "        ${bluel}${_fnBogonLine}${greym}"
                    _fnBogonRemoved=$(( _fnBogonRemoved + 1 ))
                    continue
                fi
            fi

            printf '%s\n' "${_fnBogonLine}" >> "${_fnBogonTemp}"
        done < "${_fnBogonFile}"

    # #
    #   If we specify CFG_INCLUDE_COMMENTS=false; OR if missing
    # #

    else
        while IFS= read -r _fnBogonLine || [ -n "${_fnBogonLine}" ]; do
            [ -z "${_fnBogonLine}" ] && continue
            _fnBogonBase="${_fnBogonLine%%/*}"

            if [[ "${_fnBogonBase}" == *:* ]]; then
                if is_bogon_ipv6 "${_fnBogonLine}"; then
                    label "       ${bluel}${_fnBogonLine}${greym}"
                    _fnBogonRemoved=$(( _fnBogonRemoved + 1 ))
                    continue
                fi
            elif [[ "${_fnBogonBase}" == *.* ]]; then
                if is_bogon_ipv4 "${_fnBogonBase}"; then
                    label "       ${bluel}${_fnBogonLine}${greym}"
                    _fnBogonRemoved=$(( _fnBogonRemoved + 1 ))
                    continue
                fi
            fi

            printf '%s\n' "${_fnBogonLine}" >> "${_fnBogonTemp}"
        done < "${_fnBogonFile}"
    fi

    mv "${_fnBogonTemp}" "${_fnBogonFile}"

    _fnBogonAfter=$(wc -l < "${_fnBogonFile}")

    ok "    🚫 Removed ${greenl}${_fnBogonRemoved}${greym} bogon entries from ${bluel}${PWD}/${_fnBogonFile}${greym}"

    # #
    #   Unset
    # #

    unset   _fnBogonFile _fnBogonTemp _fnBogonLine _fnBogonEntry _fnBogonBase _fnBogonBefore _fnBogonAfter _fnBogonRemoved _fnBogonIp
}

# #
#   IPSET › Dedup Contained CIDRs
#   
#   Attempts to compress list of CIDRs so that our blocklists are not
#   insanely large with overlapping subnets.
#   
#   Remove any CIDR entry whose address range is fully contained within a
#   larger CIDR that is already in the list.  Also check single IPs (treated
#   as /32 or /128) against existing CIDRs.
#   
#   Supports both IPv4 and IPv6
#   
#   For tests; see python script `verify_cidr.py`:
#       The test script requires two (2) files.
#           1. Original source list of IPs
#           2. New list
#       Test by running:
#           python verify_cidr.py alibaba_old.txt alibaba_new.txt
#   
#   Examples (IPv4):
#       8.217.0.0/16    = keep
#       8.217.0.0/17    = remove  (same base, narrower)
#       8.217.0.0/24    = remove  (same base, narrower)
#   
#       43.106.48.0/20  = keep
#       43.106.49.0/24  = remove  (different base, but /20 covers it)
#       43.106.50.0/23  = remove  (different base, but /20 covers it)
#   
#   Algorithm:
#       Align each entry to true network boundary
#       Sort by network start ascending, then prefix ascending (wider first)
#       Walk the sorted list keeping a running "max covered" end address;
#           any entry whose end less than or equal to max_end is fully contained; skip
#   
#   Notes:
#       Run AFTER sort/dedupe for best results
#       Run BEFORE count_ip_stats for accurate totals
#   
#   Usage:
#       dedup_cidr "${_fnFileTemp}"
# #

dedup_cidr( )
{
    _fnDedupFile=$1
    _fnDedupWorkFile=$1
    _fnDedupLogFile=$1
    _fnDedupUseCommentRemap="false"

    _fnDedupCommentMap=""
    _fnDedupCommentCanon=""
    _fnDedupCommentOut=""
    _fnDedupCommentLine=""
    _fnDedupCommentEntry=""
    _fnDedupCommentBase=""

    if [ "${argSkipCidrDedup}" = "true" ]; then
        info "    ⚡ Skipping overlapping CIDR dedupe (CFG_SKIP_CIDR_DEDUPE=true)"
        return 0
    fi

    if [ ! -f "${_fnDedupFile}" ] || [ ! -s "${_fnDedupFile}" ]; then
        return 0
    fi

    # #
    #   Notes:
    #       Must preserve original commented lines in output.
    #       CIDR overlap dedupe must still run on canonical IP/CIDR keys.
    #       This keeps counts and final entries consistent with non-comment mode.
    # #

    if [ "${argIncludeComments}" = "true" ]; then
        _fnDedupUseCommentRemap="true"
        _fnDedupCommentMap=$(mktemp) || return 1
        _fnDedupCommentCanon=$(mktemp) || { rm -f "${_fnDedupCommentMap}"; return 1; }
        _fnDedupCommentOut=$(mktemp) || { rm -f "${_fnDedupCommentMap}" "${_fnDedupCommentCanon}"; return 1; }

        > "${_fnDedupCommentMap}"
        > "${_fnDedupCommentCanon}"

        while IFS= read -r _fnDedupCommentLine || [ -n "${_fnDedupCommentLine}" ]; do
            [ -z "${_fnDedupCommentLine}" ] && continue
            _fnDedupCommentEntry=$(extract_ip_entry "${_fnDedupCommentLine}")
            [ -z "${_fnDedupCommentEntry}" ] && continue

            printf '%s\t%s\n' "${_fnDedupCommentEntry}" "${_fnDedupCommentLine}" >> "${_fnDedupCommentMap}"

            case "${_fnDedupCommentEntry}" in
                */32)
                    _fnDedupCommentBase="${_fnDedupCommentEntry%%/*}"
                    if [[ "${_fnDedupCommentBase}" == *.* ]]; then
                        printf '%s\t%s\n' "${_fnDedupCommentBase}" "${_fnDedupCommentLine}" >> "${_fnDedupCommentMap}"
                    fi
                    ;;
                */128)
                    _fnDedupCommentBase="${_fnDedupCommentEntry%%/*}"
                    if [[ "${_fnDedupCommentBase}" == *:* ]]; then
                        printf '%s\t%s\n' "${_fnDedupCommentBase}" "${_fnDedupCommentLine}" >> "${_fnDedupCommentMap}"
                    fi
                    ;;
            esac

            printf '%s\n' "${_fnDedupCommentEntry}" >> "${_fnDedupCommentCanon}"
        done < "${_fnDedupFile}"

        if [ ! -s "${_fnDedupCommentCanon}" ]; then
            > "${_fnDedupFile}"
            rm -f "${_fnDedupCommentMap}" "${_fnDedupCommentCanon}" "${_fnDedupCommentOut}"
            unset   _fnDedupFile _fnDedupWorkFile _fnDedupLogFile _fnDedupUseCommentRemap \
                    _fnDedupCommentMap _fnDedupCommentCanon _fnDedupCommentOut \
                    _fnDedupCommentLine _fnDedupCommentEntry _fnDedupCommentBase
            return 0
        fi

        _fnDedupWorkFile="${_fnDedupCommentCanon}"
    fi

    # #
    #   Create all our vars
    # #

    _fnDedupV4=$(mktemp) || return 1
    _fnDedupV6=$(mktemp) || return 1
    _fnDedupOther=$(mktemp) || return 1
    _fnDedupOut=$(mktemp) || return 1
    _fnDedupBefore=0
    _fnDedupAfter=0
    _fnDedupRemoved=0

    if [ ! -f "$_fnDedupWorkFile" ] || [ ! -s "$_fnDedupWorkFile" ]; then
        rm -f "$_fnDedupV4" "$_fnDedupV6" "$_fnDedupOther" "$_fnDedupOut"
        if [ "${_fnDedupUseCommentRemap}" = "true" ]; then
            > "${_fnDedupFile}"
            rm -f "${_fnDedupCommentMap}" "${_fnDedupCommentCanon}" "${_fnDedupCommentOut}"
        fi
        unset   _fnDedupFile _fnDedupWorkFile _fnDedupLogFile _fnDedupUseCommentRemap \
                _fnDedupCommentMap _fnDedupCommentCanon _fnDedupCommentOut \
                _fnDedupCommentLine _fnDedupCommentEntry _fnDedupCommentBase \
                _fnDedupV4 _fnDedupV6 _fnDedupOther _fnDedupOut \
                _fnDedupBefore _fnDedupAfter _fnDedupRemoved
        return 0
    fi

    info "    🔍 Removing overlapping CIDR ranges from ${bluel}${_fnDedupLogFile}${greym}"
    _fnDedupBefore=$(wc -l < "$_fnDedupWorkFile")

    # #
    #   Classify lines
    #       IPv4 CIDR / single      _fnDedupV4       (singles promoted to /32)
    #       IPv6 CIDR / single      _fnDedupV6       (singles promoted to /128)
    #       Other                   _fnDedupOther    (pass-through)
    # #

    awk '
    /\// && /:/  { print > v6; next }
    /:/          { print $0 "/128" > v6; next }
    /\// && /\./ { print > v4; next }
    /\./         { print $0 "/32" > v4; next }
                 { print > ot }
    ' v4="$_fnDedupV4" v6="$_fnDedupV6" ot="$_fnDedupOther" "$_fnDedupWorkFile"

    # #
    #   IPv4 containment & adjacency aggregation dedup
    #   
    #   Ensure that we keep blocklists as small as possible. Not only for each
    #   individual set, but for the blocklist as a whole.
    #   
    #   Without this, blocklists are significantly bigger and can cause load
    #   delays in CSF or other 3rd party apps loading these lists.
    #   
    #       Convert each entry to normalized [start,end] range
    #       Sort by start/end
    #       Merge overlapping and adjacent ranges
    #       Emit minimal covering CIDR set
    # #

    if [ -s "$_fnDedupV4" ]; then
        awk -F'[./]' '
        NF >= 5 {
            ip  = $1*16777216 + $2*65536 + $3*256 + $4
            pfx = int($5)
            if (pfx < 0 || pfx > 32) { printf "_ %s\n", $0; next }
            size = int(2^(32 - pfx))
            net  = int(ip / size) * size
            end  = net + size - 1
            printf "%010.0f %010.0f\n", net, end
            next
        }
        NF < 5 { printf "_ %s\n", $0 }
        ' "$_fnDedupV4" \
        | sort -k1,1n -k2,2n \
        | awk '
        function int_to_ip(n, o1, o2, o3, o4) {
            o1 = int(n / 16777216); n -= o1 * 16777216
            o2 = int(n / 65536);    n -= o2 * 65536
            o3 = int(n / 256);      o4 = n - (o3 * 256)
            return o1 "." o2 "." o3 "." o4
        }
        function max_aligned_block(start, block) {
            if (start == 0) return 4294967296
            block = 1
            while ((block * 2) <= 4294967296 && (start % (block * 2)) == 0) {
                block *= 2
            }
            return block
        }
        function emit_range(start, end, remaining, block, prefix, tmp, cidr) {
            while (start <= end) {
                remaining = (end - start) + 1
                block = max_aligned_block(start)
                while (block > remaining) block /= 2

                prefix = 32
                tmp = block
                while (tmp > 1) { tmp /= 2; prefix-- }

                cidr = int_to_ip(start)
                if (prefix == 32) print cidr
                else print cidr "/" prefix

                start += block
            }
        }
        /^_ / {
            sub(/^_ /, "")
            print
            next
        }
        {
            s = $1 + 0
            e = $2 + 0

            if (!have) {
                cur_s = s
                cur_e = e
                have = 1
                next
            }

            if (s <= (cur_e + 1)) {
                if (e > cur_e) cur_e = e
                next
            }

            emit_range(cur_s, cur_e)
            cur_s = s
            cur_e = e
        }
        END {
            if (have) emit_range(cur_s, cur_e)
        }
        ' >> "$_fnDedupOut"
    fi

    # #
    #   IPv6 containment dedup
    #   
    #   Same algorithm v4; but uses fully-expanded 32-char lowercase hex for
    #   network/end addresses so that lexicographic comparison == numeric.
    # #

    if [ -s "$_fnDedupV6" ]; then
        awk '
        function expand_v6(addr,    a, nl, nr, miss, j, i, n, g, res, lg, rg, groups) {
            sub(/\/.*/, "", addr); addr = tolower(addr)
            if (index(addr, "::")) {
                split(addr, a, "::")
                nl = split(a[1], lg, ":"); if (a[1] == "") nl = 0
                nr = split(a[2], rg, ":"); if (a[2] == "") nr = 0
                miss = 8 - nl - nr; j = 0
                for (i = 1; i <= nl; i++) groups[++j] = lg[i]
                for (i = 1; i <= miss; i++) groups[++j] = "0"
                for (i = 1; i <= nr; i++) groups[++j] = rg[i]
                n = j
            } else { n = split(addr, groups, ":") }
            res = ""
            for (i = 1; i <= n; i++) {
                g = groups[i]; while (length(g) < 4) g = "0" g; res = res g
            }
            while (length(res) < 32) res = res "0"
            return res
        }

        function v6_net_hex(hex32, pfx,    fc, rem, c, v, nv, res) {
            fc = int(pfx / 4); rem = pfx % 4
            res = substr(hex32, 1, fc)
            if (rem > 0) {
                c = substr(hex32, fc + 1, 1)
                v = index("0123456789abcdef", c) - 1
                if      (rem == 1) nv = int(v/8)*8
                else if (rem == 2) nv = int(v/4)*4
                else               nv = int(v/2)*2
                res = res substr("0123456789abcdef", nv + 1, 1)
                fc++
            }
            while (length(res) < 32) res = res "0"
            return res
        }

        function v6_end_hex(hex32, pfx,    fc, rem, c, v, nv, res) {
            fc = int(pfx / 4); rem = pfx % 4
            res = substr(hex32, 1, fc)
            if (rem > 0) {
                c = substr(hex32, fc + 1, 1)
                v = index("0123456789abcdef", c) - 1
                if      (rem == 1) nv = int(v/8)*8 + 7
                else if (rem == 2) nv = int(v/4)*4 + 3
                else               nv = int(v/2)*2 + 1
                res = res substr("0123456789abcdef", nv + 1, 1)
                fc++
            }
            while (length(res) < 32) res = res "f"
            return res
        }

        {
            line = $0
            addr = line; sub(/\/[0-9]+$/, "", addr)
            pfx  = line; sub(/.*\//, "", pfx); pfx = int(pfx)
            if (pfx < 0 || pfx > 128) { printf "_ %s\n", line; next }
            hex = expand_v6(addr)
            net = v6_net_hex(hex, pfx)
            e   = v6_end_hex(hex, pfx)
            printf "%s %03d %s %s\n", net, pfx, e, line
        }
        ' "$_fnDedupV6" \
        | sort -k1,1 -k2,2n \
        | awk '
        /^_ / { sub(/^_ /, ""); print; next }
        {
            e = $3; pfx = $2 + 0
            orig = ""; for (i = 4; i <= NF; i++) orig = (i == 4 ? $i : orig " " $i)
            if (NR == 1 || (e "") > (me "")) {
                if (pfx == 128) sub(/\/128$/, "", orig)
                print orig
                me = e
            }
        }
        ' >> "$_fnDedupOut"
    fi

    # #
    #   Other lines (pass-through)
    # #

    if [ -s "$_fnDedupOther" ]; then
        cat "$_fnDedupOther" >> "$_fnDedupOut"
    fi

    mv "$_fnDedupOut" "$_fnDedupWorkFile"
    rm -f "$_fnDedupV4" "$_fnDedupV6" "$_fnDedupOther"

    _fnDedupAfter=$(wc -l < "$_fnDedupWorkFile")
    _fnDedupRemoved=$(( _fnDedupBefore - _fnDedupAfter ))

    if [ "${_fnDedupUseCommentRemap}" = "true" ]; then
        awk -F'\t' '
        NR == FNR {
            key = $1
            sub(/^[^\t]*\t/, "", $0)
            if (!(key in line_by_key)) line_by_key[key] = $0
            next
        }
        {
            if ($0 in line_by_key) print line_by_key[$0]
        }
        ' "${_fnDedupCommentMap}" "${_fnDedupCommentCanon}" > "${_fnDedupCommentOut}"

        mv "${_fnDedupCommentOut}" "${_fnDedupFile}"
        rm -f "${_fnDedupCommentMap}" "${_fnDedupCommentCanon}"
    fi

    if [ "$_fnDedupRemoved" -gt 0 ]; then
        ok "    🔍 Removed ${greenl}${_fnDedupRemoved}${greym} overlapping CIDR entries from ${bluel}${_fnDedupLogFile}${greym}"
    else
        ok "    🔍 No overlapping CIDRs found in ${bluel}${_fnDedupLogFile}${greym}"
    fi

    # #
    #   Unset
    # #

    unset   _fnDedupFile _fnDedupWorkFile _fnDedupLogFile _fnDedupUseCommentRemap \
            _fnDedupCommentMap _fnDedupCommentCanon _fnDedupCommentOut \
            _fnDedupCommentLine _fnDedupCommentEntry _fnDedupCommentBase \
            _fnDedupV4 _fnDedupV6 _fnDedupOther _fnDedupOut \
            _fnDedupBefore _fnDedupAfter _fnDedupRemoved
}

# #
#   Check if specified file contains valid IP entries.
#   
#   Requires an input file to be passed as argument:
#       has_valid_ip_entries "${file_ipset_target}"
# #

has_valid_ip_entries()
{
    _fnArgFile=$1
    _fnValidLine=""
    _fnValidEntry=""

    if [ ! -f "${_fnArgFile}" ]; then
        return 1
    fi

    # #
    #   If we specify CFG_INCLUDE_COMMENTS=true
    #       curl -s https://gist.githubusercontent.com/BBcan177/d7105c242f17f4498f81/raw/f69be712a06e998191adfe4c86d74e8cacf08d28/MS-3 | CFG_INCLUDE_COMMENTS=true .github/scripts/bl-format.sh blocklists/3rdparty/BBcan177/ms3.ipset
    # #

    if [ "${argIncludeComments}" = "true" ]; then
        while IFS= read -r _fnValidLine || [ -n "${_fnValidLine}" ]; do
            _fnValidEntry=$(extract_ip_entry "${_fnValidLine}")
            [ -z "${_fnValidEntry}" ] && continue

            if is_valid_ip_entry "${_fnValidEntry}"; then
                unset _fnArgFile _fnValidLine _fnValidEntry
                return 0
            fi
        done < "${_fnArgFile}"

    # #
    #   If we specify CFG_INCLUDE_COMMENTS=false; OR if missing
    # #

    else

        # #
        #   use grep instead of is_valid_ip_entry; avoid large slowdown from per-line read
        # #

        if grep -Eq "^(${regex_ipv4}|${regex_ipv4_cidr}|${regex_ipv6}|${regex_ipv6_cidr})$" "${_fnArgFile}"; then
            unset _fnArgFile _fnValidLine _fnValidEntry
            return 0
        fi
    fi

    # #
    #   Unset
    # #

    unset   _fnArgFile _fnValidLine _fnValidEntry

    return 1
}

# #
#   Cleanup Garbage
#   
#   Removes old ipv4 and ipv6 folders
# #

gcc( )
{
    echo
    info "    🗑️ Starting ${bluel}GCC${greym} cleanup"

    # #
    #   Remove temp
    #       ./blocklists/geolite/asn/ipv4
    # #

    if geolite2_ReuseEnabled; then
        info "    ♻️ Skipping staging cleanup for reuse ${bluel}${path_storage_ipv4}${greym}"
    else
        if [ -d ${path_storage_ipv4} ]; then
            rm -rf "${path_storage_ipv4}"
            if [ ! -d "${path_storage_ipv4}" ]; then
                ok "    🗑️ Removed folder ${greenl}${path_storage_ipv4}"
            else
                error "    ❌ Failed to remove folder ${redl}${path_storage_ipv4}"
            fi
        fi
    fi

    # #
    #   Remove temp
    #       ./blocklists/geolite/asn/ipv6
    # #

    if geolite2_ReuseEnabled; then
        info "    ♻️ Skipping staging cleanup for reuse ${bluel}${path_storage_ipv6}${greym}"
    else
        if [ -d ${path_storage_ipv6} ]; then
            rm -rf "${path_storage_ipv6}"
            if [ ! -d "${path_storage_ipv6}" ]; then
                ok "    🗑️ Removed folder ${greenl}${path_storage_ipv6}"
            else
                error "    ❌ Failed to remove folder ${redl}${path_storage_ipv6}"
            fi
        fi
    fi

    # #
    #   Remove temp
    #       .github/temp
    # #

    case "${BL_GEOLITE2_REUSE_TEMP:-false}" in
        1|true|TRUE|yes|YES)
            info "    ♻️ Skipping temp cleanup for reuse ${bluel}${app_dir_github}/${folder_target_temp}${greym}"
            ;;
        *)
            rm -rf "${app_dir_github}/${folder_target_temp}"
            if [ ! -d "${app_dir_github}/${folder_target_temp}" ]; then
                ok "    🗑️ Removed folder ${greenl}${app_dir_github}/${folder_target_temp}"
            else
                error "    ❌ Failed to remove folder ${redl}${app_dir_github}/${folder_target_temp}"
            fi
            ;;
    esac

}

# #
#   Developer › Test IP Sorting
# #

if [ "$argDevMode" = true ]; then

sort_results <<'EOF'
192.168.1.5
10.0.0.1
192.168.1.10
fe80::1
::1
2001:db8::1
10.0.0.2
EOF

# #
#   Developer › IPv6 Regex Test
#   
#   Outputs an ipv6 test to ensure our regex is matching correctly.
# #

cat << 'EOF' | while IFS= read -r ip; do
# #
#   Valid
# #

2001:db8::1
::1
fe80::1234:5678:abcd:ef12
2001:0db8:85a3:0000:0000:8a2e:0370:7334
::
1234:5678:9abc:def0:1234:5678:9abc:def0

# #
#   Invalid
# #

:::::
abc:def
12345::1
1:2:3:4:5:6:7:8:9
EOF
    # Preserve blank lines
    [[ -z "$ip" ]] && { printf "\n"; continue; }

    # Skip empty lines
    [[ -z "$ip" ]] && continue

    # Print comments (with leading space preserved)
    [[ "$ip" =~ ^[[:space:]]*# ]] && { printf "${greym} %s\n" "$ip"; continue; }

    if [[ "$ip" =~ $regex_ipv6 ]]; then
        printf "${greenl} OK   %s${end}\n" "$ip"
    else
        printf "${redd} BAD  %s${end}\n" "$ip"
    fi
done

fi

# #
#   Blocklist › Fallback › Download
#   
#   If we cannot download from the source website, revert to a fallback list to 
#   ensure our blocklist is not pushed empty.
# #

list_fallback_download()
{
    echo "Exec list_fallback_download"
}

# #
#   Blocklist › Fallback › Load
#   
#   Load fallback static blocks from .github/blocks/<category>.
#   
#   Must define the category when calling this script with something such as:
#       ./.github/scripts/bl-block.sh blocklists/privacy/@general.ipset privacy
#       ./.github/scripts/bl-mip.sh blocklists/privacy/privacy_anthropic.ipset '${{ vars.BL_PRIVACY_MIP_ANTHROPIC_SRC }}' privacy/anthropic
# #

list_fallback_load()
{
    echo "Exec list_fallback_load"
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
#   Get latest MaxMind GeoLite2 IP ASN database and md5 checksum
#       CSV URL: https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN-CSV&license_key=LICENSE_KEY&suffix=zip
#       MD5 URL: https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN-CSV&license_key=LICENSE_KEY&suffix=zip.md5
#   
#   If using --dry, you must manually download the .zip and .zip.md5 files and place them in the local folder assigned to the value
#       $folder_source_local
# #

maxmind_Database_Download( )
{

    info "    📦 Getting ready to download MaxMind databases${greym}"

    local URL_CSV="https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN-CSV&license_key=${argMMLicense}&suffix=zip"
    local URL_MD5="${URL_CSV}.md5" # take URL_CSV value and add .md5 to end for hash file
    local PATH_CACHE_DIR="${app_dir_github}/${folder_source_cache}"
    local CACHE_ZIP="${PATH_CACHE_DIR}/${file_source_csv_zip}"
    local CACHE_MD5="${PATH_CACHE_DIR}/${file_source_csv_zip_md5}"

    # #
    #   download files
    #       - will not download if --dryrun specified
    #       - will not download if --local specified
    # #

    if [ "${argDryrun}" != "true" ] && [ "${argUseLocalDB}" != "true" ]; then
        mkdir -p "${PATH_CACHE_DIR}"

        if [ -f "${file_source_csv_zip}" ] && [ -f "${file_source_csv_zip_md5}" ]; then
            info "    📦 Reusing existing ASN files in ${bluel}${TEMPDIR}${greym}"
        elif [ -f "${CACHE_ZIP}" ] && [ -f "${CACHE_MD5}" ]; then
            info "    📦 Restoring cached ASN files from ${bluel}${PATH_CACHE_DIR}${greym}"
            cp -f "${CACHE_ZIP}" "${file_source_csv_zip}"
            cp -f "${CACHE_MD5}" "${file_source_csv_zip_md5}"
        else
            if [ -n "${argMMLicense}" ]; then
                URL_HIDDEN_CSV=$(printf '%s\n' "${URL_CSV}" | sed "s/${argMMLicense}/HIDDEN/g")
                URL_HIDDEN_MD5=$(printf '%s\n' "${URL_MD5}" | sed "s/${argMMLicense}/HIDDEN/g")
            else
                URL_HIDDEN_CSV="${URL_CSV}"
                URL_HIDDEN_MD5="${URL_MD5}"
            fi

            info "    🌎 Downloading ${bluel}${file_source_csv_zip}${end} from ${bluel}${URL_HIDDEN_CSV}"
            if ! curl --silent --show-error --location \
                    --user-agent "${app_agent}" \
                    --output "${file_source_csv_zip}" "${URL_CSV}"
            then
                error "    ❌ Failed to curl database files from ${redl}${URL_HIDDEN_CSV}${greym}"
                exit 1
            fi

            info "    🌎 Downloading ${bluel}${file_source_csv_zip_md5}${end} from ${bluel}${URL_HIDDEN_MD5}"
            if ! curl --silent --show-error --location \
                    --user-agent "${app_agent}" \
                    --output "${file_source_csv_zip_md5}" "${URL_MD5}"
            then
                error "    ❌ Failed to curl database files from ${redl}${URL_HIDDEN_MD5}${greym}"
                exit 1
            fi

            cp -f "${file_source_csv_zip}" "${CACHE_ZIP}"
            cp -f "${file_source_csv_zip_md5}" "${CACHE_MD5}"
        fi
    fi

    # #
    #   .CSV missing, warn user to provide one or the other
    # #


    if [ ! -f "${file_source_csv_zip}" ]; then
        error "    ❌ Must supply zip ${redl}${file_source_csv_zip}${greym} + md5 ${redl}${file_source_csv_zip_md5}${greym}; cannot locate"
        exit 1
    fi

    # #
    #   Provided the .ZIP, but not the ZIP hash file
    # #

    if [ -f "${file_source_csv_zip}" ] && [ ! -f "${file_source_csv_zip_md5}" ]; then
        error "    ❌ You supplied zip ${redl}${file_source_csv_zip}${greym}, but did not provide the md5 file ${redl}${file_source_csv_zip_md5}${greym}; cannot continue"
        exit 1
    fi

    # #
    #   Provided the IPv4 csv file, but may be missing the others
    # #

    if [ -f "${file_source_csv_ipv4}" ]; then
        if [ ! -f "${file_source_csv_ipv6}" ]; then
            error "    ❌ You supplied IPv4 CSV ${redl}${file_source_csv_ipv4}${greym}, but did not provide IPv6 CSV file ${redl}${file_source_csv_ipv6}${greym}; cannot continue"
        fi
    fi

    # #
    #   Provided IPv6 csv file, but may be missing the others
    # #

    if [ -f "${file_source_csv_ipv6}" ]; then
        if [ ! -f "${file_source_csv_ipv4}" ]; then
            error "    ❌ You supplied IPv6 CSV ${redl}${file_source_csv_ipv6}${greym}, but did not provide IPv4 CSV file ${redl}${file_source_csv_ipv4}${greym}; cannot continue"
        fi
    fi

    # #
    #   Zip files provided, check MD5
    # #

    if [ -f "${file_source_csv_zip}" ] && [ -f "${file_source_csv_zip_md5}" ]; then

        info "    📄 Found ASN .zip database ${bluel}${file_source_csv_zip}${greym} and ${bluel}${file_source_csv_zip_md5}${greym}"

        # #
        #   Check for download limit reached
        # #

        md5Response=$(cat "${file_source_csv_zip_md5}")
        case "$md5Response" in
            *"download limit reached"*)
                error "    ❌ MaxMind: Daily API download limit reached"
                exit 1
                ;;
        esac

        if ! unzip -tq "${file_source_csv_zip}" >/dev/null 2>&1; then
            if grep -qi "download limit reached" "${file_source_csv_zip}"; then
                error "    ❌ MaxMind: API download limit reached; received a non-zip response"
            else
                error "    ❌ Downloaded file is not a valid ZIP archive (${redl}${file_source_csv_zip}${greym})"
            fi
            exit 1
        fi

        # #
        #   Validate checksum
        #   .md5 file is not in expected format; 'md5sum --check' won't work
        # #

        md5_local=$(md5sum "${file_source_csv_zip}" | awk '{print $1}')
        if [ "$md5Response" != "$md5_local" ]; then
            error "    ❌ GeoLite2 MD5 downloaded checksum does not match local md5 checksum"
            exit 1
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
                exit 1
            fi
        else
            error "    ❌ Cannot locate zip ${redl}${file_source_csv_zip}"
        fi

    elif [ -f "${APP_GEO_LOCS_CSV}" ] && [ -f "${file_source_csv_ipv4}" ] && [ -f "${file_source_csv_ipv6}" ]; then
        info "    📄 Found Uncompressed set ${bluel}${APP_GEO_LOCS_CSV}${greym},${bluel}${file_source_csv_ipv4}${greym} and ${bluel}${file_source_csv_ipv6}${greym}"
    else
        error "    ❌ Could not locate either ${redl}zip + md5${greym} or ${redl}uncompressed csv${greym}"
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

    info "    📄 Load ASN Database Files${greym}"

    # #
    #   Called from
    #       readonly CONFIGS_LIST="${APP_GEO_LOCS_CSV} ${file_source_csv_ipv4} ${file_source_csv_ipv6}"
    # #

    local configs=(${CONFIGS_LIST})
    for f in ${configs[@]}; do

        info "    📄 Mounting ASN file ${bluel}${TEMPDIR}/${f}"
        if [ ! -f "$f" ]; then
            error "    ❌ Missing ASN database: ${redl}${TEMPDIR}/${f}${greym}"
        fi
    done
}

# #
#   ASN Index › Fingerprint
#   
#   Generates a deterministic fingerprint/hash for the ASN CSV source files
#   by calculating the MD5 checksum of both the IPv4 and IPv6 CSV datasets
#   and combining them into a single colon-separated string.
#   
#   Used to detect dataset changes and determine whether the ASN index
#   should be rebuilt or refreshed.
#   
#   Returns:
#       stdout : "<md5_ipv4>:<md5_ipv6>"
#       0      : success
#       1      : one or both CSV source files are missing
# #

asn_Index_Fingerprint( )
{
    _fnCsvIpv4="${TEMPDIR}/${file_source_csv_ipv4}"
    _fnCsvIpv6="${TEMPDIR}/${file_source_csv_ipv6}"

    if [ ! -f "${_fnCsvIpv4}" ] || [ ! -f "${_fnCsvIpv6}" ]; then
        printf ''
        return 1
    fi

    md5sum "${_fnCsvIpv4}" "${_fnCsvIpv6}" \
        | awk 'BEGIN{ORS=":"} {print $1} END{print ""}' \
        | sed 's/:$//'

    unset   _fnCsvIpv4 _fnCsvIpv6
    return 0
}

# #
#   ASN Index › Build / Reuse
#   
#   Builds a reusable ASN row cache once per database fingerprint so subsequent
#   script invocations can avoid re-importing the full IPv4/IPv6 CSV files.
# #

asn_Index_Prepare( )
{
    _fnFingerprint="$(asn_Index_Fingerprint)"
    _fnStoredFingerprint=""

    if [ -z "${_fnFingerprint}" ]; then
        warn "    ⚠️ ASN index cache skipped; missing CSV database files"
        return 0
    fi

    if [ -f "${file_cache_asn_index_meta}" ]; then
        _fnStoredFingerprint="$(grep -m1 '^FINGERPRINT=' "${file_cache_asn_index_meta}" | cut -d'=' -f2-)"
    fi

    if [ "${_fnStoredFingerprint}" = "${_fnFingerprint}" ] \
        && [ -d "${path_cache_asn_index_ipv4}" ] \
        && [ -d "${path_cache_asn_index_ipv6}" ]
    then
        info "    ♻️ Reusing ASN index cache ${bluel}${path_cache_asn_index_root}${greym}"
        return 0
    fi

    info "    🧱 Building ASN index cache ${bluel}${path_cache_asn_index_root}${greym}"
    rm -rf "${path_cache_asn_index_root}"
    mkdir -p "${path_cache_asn_index_ipv4}" "${path_cache_asn_index_ipv6}"

    while IFS=',' read -r _fnSubnet _fnAsn _fnOrg _; do
        [ -z "${_fnSubnet}" ] && continue
        [ -z "${_fnAsn}" ] && continue
        printf '%s,%s,%s\n' "${_fnSubnet}" "${_fnAsn}" "${_fnOrg}" >> "${path_cache_asn_index_ipv4}/${_fnAsn}.csv"
    done < <(tail -n +2 "${TEMPDIR}/${file_source_csv_ipv4}")

    while IFS=',' read -r _fnSubnet _fnAsn _fnOrg _; do
        [ -z "${_fnSubnet}" ] && continue
        [ -z "${_fnAsn}" ] && continue
        printf '%s,%s,%s\n' "${_fnSubnet}" "${_fnAsn}" "${_fnOrg}" >> "${path_cache_asn_index_ipv6}/${_fnAsn}.csv"
    done < <(tail -n +2 "${TEMPDIR}/${file_source_csv_ipv6}")

    {
        echo "FINGERPRINT=${_fnFingerprint}"
        echo "GENERATED_AT=$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
    } > "${file_cache_asn_index_meta}"

    ok "    ✅ ASN index cache ready ${greenl}${path_cache_asn_index_root}${greym}"

    unset   _fnFingerprint _fnStoredFingerprint _fnSubnet _fnAsn _fnOrg
}

# #
#   ASN Index › Hydrate Custom Target
#   
#   Fast path used when --folder, --file, and --asn are provided. Pulls subnet
#   rows from pre-indexed ASN files instead of scanning full CSV databases.
#   
#   @return
#       0   handled (used cache path)
#       1   not handled (caller should run full import path)
# #

asn_Index_Hydrate_CustomTarget( )
{
    _fnIpVersion="$1"
    _fnTargetRoot="$2"
    _fnIndexRoot=""
    _fnTargetSubfolder=""
    _fnTargetFile=""
    _fnMatchedAny=false
    _fnMetaOrg=""

    if [ -z "${argFolder}" ] || [ -z "${argFile}" ] || [ -z "${argASN}" ]; then
        return 1
    fi

    case "${_fnIpVersion}" in
        ipv4)
            _fnIndexRoot="${path_cache_asn_index_ipv4}"
            ;;
        ipv6)
            _fnIndexRoot="${path_cache_asn_index_ipv6}"
            ;;
        *)
            return 1
            ;;
    esac

    if [ ! -d "${_fnIndexRoot}" ]; then
        return 1
    fi

    _fnTargetSubfolder="${_fnTargetRoot}/${argFolder}"
    if [ ! -d "${_fnTargetSubfolder}" ]; then
        mkdir -p "${_fnTargetSubfolder}"
        if [ -d "${_fnTargetSubfolder}" ]; then
            ok "    📂 Created ${greenl}${_fnTargetSubfolder}"
        else
            error "    ❌ Failed to create ${redl}${_fnTargetSubfolder}"
            return 0
        fi
    fi

    _fnTargetFile="${_fnTargetSubfolder}/${argFile}.${file_target_ext_tmp}"
    rm -f "${_fnTargetFile}"

    IFS=',' read -ra _fnFilterAsns <<< "${argASN}"
    for _fnAsnRaw in "${_fnFilterAsns[@]}"; do
        _fnAsn="$(echo "${_fnAsnRaw}" | tr -d '[:space:]')"
        [ -z "${_fnAsn}" ] && continue

        _fnIndexFile="${_fnIndexRoot}/${_fnAsn}.csv"
        if [ ! -f "${_fnIndexFile}" ]; then
            continue
        fi

        if [ "${_fnMatchedAny}" = "false" ]; then
            _fnMetaOrg="$(head -n1 "${_fnIndexFile}" | cut -d',' -f3-)"
            [ -z "${_fnMetaOrg}" ] && _fnMetaOrg="${argFile}"
            {
                echo "# META_ASN=${argASN}"
                echo "# META_ORG=${_fnMetaOrg}"
            } >> "${_fnTargetFile}"
            _fnMatchedAny=true
        fi

        cut -d',' -f1 "${_fnIndexFile}" >> "${_fnTargetFile}"
    done

    if [ "${_fnMatchedAny}" = "false" ]; then
        warn "    ⚠️ No ASN rows matched cached ${_fnIpVersion} index for ${argFolder}/${argFile}"
        unset   _fnIpVersion _fnTargetRoot _fnIndexRoot _fnTargetSubfolder _fnTargetFile _fnMatchedAny _fnMetaOrg _fnFilterAsns _fnAsnRaw _fnAsn _fnIndexFile
        return 0
    fi

    info "    ⚡ Reused cached ${bluel}${_fnIpVersion}${greym} ASN index for ${bluel}${argFolder}/${argFile}${greym}"

    unset   _fnIpVersion _fnTargetRoot _fnIndexRoot _fnTargetSubfolder _fnTargetFile _fnMatchedAny _fnMetaOrg _fnFilterAsns _fnAsnRaw _fnAsn _fnIndexFile
    return 0
}

# #
#   Generate › IPv4
# #

generate_IPv4()
{
    info "    📟 Generate ${bluel}IPv4${greym} ipsets from ASN database"

    # #
    #   remove existing ipv4 folder:
    #       blocklists/geolite/asn/ipv4/
    # #

    if geolite2_ReuseEnabled; then
        info "    ♻️ Reusing staging folder ${bluel}${path_storage_ipv4}${greym}"
    else
        rm -rf "${path_storage_ipv4}"
        if [ ! -d "${path_storage_ipv4}" ]; then
            ok "    🗑️ Removed folder ${bluel}${path_storage_ipv4}"
        else
            error "    ❌ Failed to remove folder ${greenl}${path_storage_ipv4}"
        fi
    fi

    # #
    #   Create new ipv4 folder:
    #       blocklists/geolite/asn/ipv4/
    # #

    if [ ! -d "${path_storage_ipv4}" ]; then
        mkdir -p "${path_storage_ipv4}"

        if [ -d "${path_storage_ipv4}" ]; then
            ok "    📂 Created ${greenl}${path_storage_ipv4}"
        else
            error "    ❌ Failed to create ${redl}${path_storage_ipv4}"
        fi
    fi

    # #
    #   Fast path
    #       If custom target args are supplied and ASN index exists, hydrate
    #       target from cache and skip full CSV import scan.
    # #

    if asn_Index_Hydrate_CustomTarget "ipv4" "${path_storage_ipv4}"; then
        return 0
    fi

    # #
    #   Start import
    # #

    info "    ➕ Importing ${bluel}IPv4${greym} from ASN database"

    # #
    #   Pre-split ASN filter once if provided
    #       argASN can be formatted as:
    #           .github/scripts/bl-geolite2_asn_custom.sh --local --asn AS49581 AS212513
    # #

    IFS=',' read -ra FILTER_ASNS <<< "${argASN:-}"

    # #
    #   Track created folders to avoid repeated mkdir
    # #

    declare -A created_folders

    count=0
    bShowMessageASN="true"
    bShowMessageARG="true"

    while IFS=',' read -r ipset_read_subnet ipset_read_asn ipset_read_orgname _; do
        ((count++))
        [[ $argLimitEntries -gt 0 && $count -gt $argLimitEntries ]] && break
        [[ -z "${ipset_read_subnet}" || -z "${ipset_read_asn}" ]] && continue

        # #
        #   Filter by specific ASN if needed
        # #
    
        if [ "${#FILTER_ASNS[@]}" -gt 0 ]; then

            if [ "$bShowMessageASN" = "true" ]; then
                debug "    ➕ Custom list of ASNs provided using --asn, -a"
                bShowMessageASN="false"
            fi

            match=false
            OLD_IFS=$IFS
            IFS=','
    
            for asn in $argASN; do
                if [ "${ipset_read_asn}" = "$asn" ]; then
                    match=true
                    break
                fi
            done
    
            IFS=$OLD_IFS

            [ "$match" = true ] || continue
        fi

        #   debug "    ➕ Start Process ${bluel}${ipset_read_subnet}${greym} › ASN ${bluel}${ipset_read_asn}${greym} › Org ${bluel}${ipset_read_orgname}${greym}${greym}"

        # #
        #   Clean org name. Transform to lower-case, strip special chars.
        #   Will be used as folder name
        # #

        ipset_orgname=$(echo "${ipset_read_orgname}" \
            | tr '[:upper:]' '[:lower:]' \
            | sed 's/[^a-z0-9]/_/g; s/_\+/_/g; s/^_//; s/_$//')

        # #
        #   If flags are used:
        #       --folder=, --arg=
        # #

        if [[ -n "${argFolder}" && -n "${argFile}" ]]; then

            if [ "${bShowMessageARG}" = "true" ]; then
                debug "    📂 Args --folder, --file specified, generating subfolder"
                bShowMessageARG="false"
            fi

            # #
            #   Create top-level folder
            #       blocklists/geolite/asn/ipv4/FOLDERNAME
            # #
        
            top_folder="${argFolder}"
            path_ipset_subfolder="${path_storage_ipv4}/${top_folder}"

            if [ ! -d "${path_ipset_subfolder}" ]; then
                mkdir -p "${path_ipset_subfolder}"

                if [ -d "${path_ipset_subfolder}" ]; then
                    ok "    📂 Created ${greenl}${path_ipset_subfolder}"
                else
                    error "    ❌ Failed to create ${redl}${path_ipset_subfolder}"
                fi
            fi

            path_ipset="${path_ipset_subfolder}/${argFile}.${file_target_ext_tmp}"

        # #
        #   --folder=, --file= not specified
        #   Default to normal folder naming scheme.
        # #

        else
            if [ "${bShowMessageARG}" = "true" ]; then
                debug "    📂 Missing args --folder, --file, using ASN grouping subfolder structure"
                bShowMessageARG="false"
            fi

            # #
            #   Default numeric grouping
            #   
            #   If --asn=4564 is provided; folder name will be 4000
            #   If --asn=53924 is provided, folder name will be 53000
            # #
        
            folder_asn_group=$((ipset_read_asn / 1000 * 1000))
            path_ipset_subfolder="${path_storage_ipv4}/${folder_asn_group}"

            # #
            #   Folder doesn't exist, create
            # #

            if [[ -z "${created_folders[${path_ipset_subfolder}]}" ]]; then

                if [ ! -d "${path_ipset_subfolder}" ]; then
                    mkdir -p "${path_ipset_subfolder}"

                    if [ -d "${path_ipset_subfolder}" ]; then
                        ok "    📂 Created ${greenl}${path_ipset_subfolder}"
                    else
                        error "    ❌ Failed to create ${redl}${path_ipset_subfolder}"
                    fi
                fi

                created_folders[${path_ipset_subfolder}]=1
            fi
            path_ipset="${path_ipset_subfolder}/asn_${ipset_read_asn}_${ipset_orgname}.${file_target_ext_tmp}"
        fi

        debug "    ➕ Adding IP/Subnet › IP ${bluel}${ipset_read_subnet}${greym} › ASN ${bluel}${ipset_read_asn}${greym} › Org ${bluel}${ipset_read_orgname}${greym} › File ${bluel}${path_ipset}${greym}"

        # #
        #   Add ASN and OrgName to top of file as placeholder, will be used to generate header at end 
        #   and the existing META_ lines will be removed.
        # #

        if [ ! -f "${path_ipset}" ]; then
            {
                echo "# META_ASN=${ipset_read_asn}"
                echo "# META_ORG=${ipset_read_orgname}"
            } >> "${path_ipset}"
        fi

        # #
        #   Write ip / subnet to file
        # #

        echo "${ipset_read_subnet}" >> "${path_ipset}"

        # #
        #   Append to aggressive raw if --aggressive
        # #

        if [ "${argAggressive}" = "true" ]; then
            aggressive_raw="${folder_target_storage}/${folder_target_aggressive}/${file_target_aggressive}.${file_target_ext_tmp}"
            mkdir -p "$(dirname "${aggressive_raw}")"
            echo "${ipset_read_subnet}" >> "${aggressive_raw}"
        fi

    done < <(tail -n +2 "${TEMPDIR}/${file_source_csv_ipv4}")
}

# #
#   Generate › IPv6
# #

generate_IPv6()
{
    info "    📟 Generate ${bluel}IPv6${greym} ipsets from ASN database"

    # #
    #   Remove existing ipv4 folder:
    #       blocklists/geolite/asn/ipv4/
    # #

    if geolite2_ReuseEnabled; then
        info "    ♻️ Reusing staging folder ${bluel}${path_storage_ipv6}${greym}"
    else
        rm -rf "${path_storage_ipv6}"
        if [ ! -d "${path_storage_ipv6}" ]; then
            ok "    🗑️ Removed folder ${bluel}${path_storage_ipv6}"
        else
            error "    ❌ Failed to remove folder ${greenl}${path_storage_ipv6}"
        fi
    fi

    # #
    #   Create new ipv6 folder:
    #       blocklists/geolite/asn/ipv6/
    # #

    if [ ! -d "${path_storage_ipv6}" ]; then
        mkdir -p "${path_storage_ipv6}"

        if [ -d "${path_storage_ipv6}" ]; then
            ok "    📂 Created ${greenl}${path_storage_ipv6}"
        else
            error "    ❌ Failed to create ${redl}${path_storage_ipv6}"
        fi
    fi

    # #
    #   Fast path
    #       If custom target args are supplied and ASN index exists, hydrate
    #       target from cache and skip full CSV import scan.
    # #

    if asn_Index_Hydrate_CustomTarget "ipv6" "${path_storage_ipv6}"; then
        return 0
    fi

    # #
    #   Start import
    # #

    info "    ➕ Importing ${bluel}IPv6${greym} from ASN database"

    # #
    #   Pre-split ASN filter once if provided
    #       argASN can be formatted as:
    #           .github/scripts/bl-geolite2_asn_custom.sh --local --asn AS49581 AS212513
    # #

    IFS=',' read -ra FILTER_ASNS <<< "${argASN:-}"

    # #
    #   Track created folders to avoid repeated mkdir
    # #

    declare -A created_folders

    count=0
    bShowMessageASN="true"
    bShowMessageARG="true"

    while IFS=',' read -r ipset_read_subnet ipset_read_asn ipset_read_orgname _; do
        ((count++))
        [[ $argLimitEntries -gt 0 && $count -gt $argLimitEntries ]] && break
        [[ -z "${ipset_read_subnet}" || -z "${ipset_read_asn}" ]] && continue

        # #
        #   Filter by specific ASN if needed
        # #
    
        if [ "${#FILTER_ASNS[@]}" -gt 0 ]; then

            if [ "$bShowMessageASN" = "true" ]; then
                debug "    ➕ Custom list of ASNs provided using --asn, -a"
                bShowMessageASN="false"
            fi

            match=false
            OLD_IFS=$IFS
            IFS=','
    
            for asn in $argASN; do
                if [ "${ipset_read_asn}" = "$asn" ]; then
                    match=true
                    break
                fi
            done
    
            IFS=$OLD_IFS

            [ "$match" = true ] || continue
        fi

        #   debug "    ➕ Start Process ${bluel}${ipset_read_subnet}${greym} › ASN ${bluel}${ipset_read_asn}${greym} › Org ${bluel}${ipset_read_orgname}${greym}${greym}"

        # #
        #   Clean org name. Transform to lower-case, strip special chars.
        #   Will be used as folder name
        # #

        ipset_orgname=$(echo "${ipset_read_orgname}" \
            | tr '[:upper:]' '[:lower:]' \
            | sed 's/[^a-z0-9]/_/g; s/_\+/_/g; s/^_//; s/_$//')

        # #
        #   If flags are used:
        #       --folder=, --arg=
        # #

        if [[ -n "${argFolder}" && -n "${argFile}" ]]; then
    
            if [ "${bShowMessageARG}" = "true" ]; then
                debug "    📂 Args --folder, --file specified, generating subfolder"
                bShowMessageARG="false"
            fi

            # #
            #   Create top-level folder
            #       blocklists/geolite/asn/ipv4/FOLDERNAME
            # #
        
            top_folder="${argFolder}"
            path_ipset_subfolder="${path_storage_ipv6}/${top_folder}"

            if [ ! -d "${path_ipset_subfolder}" ]; then
                mkdir -p "${path_ipset_subfolder}"

                if [ -d "${path_ipset_subfolder}" ]; then
                    ok "    📂 Created ${greenl}${path_ipset_subfolder}"
                else
                    error "    ❌ Failed to create ${redl}${path_ipset_subfolder}"
                fi
            fi

            path_ipset="${path_ipset_subfolder}/${argFile}.${file_target_ext_tmp}"

        # #
        #   --folder=, --file= not specified
        #   Default to normal folder naming scheme.
        # #

        else
            if [ "${bShowMessageARG}" = "true" ]; then
                debug "    📂 Missing args --folder, --file, using ASN grouping subfolder structure"
                bShowMessageARG="false"
            fi

            # #
            #   Default numeric grouping
            #   
            #   If --asn=4564 is provided; folder name will be 4000
            #   If --asn=53924 is provided, folder name will be 53000
            # #

            folder_asn_group=$((ipset_read_asn / 1000 * 1000))
            path_ipset_subfolder="${path_storage_ipv6}/${folder_asn_group}"

            # #
            #   Folder doesn't exist, create
            # #

            if [[ -z "${created_folders[${path_ipset_subfolder}]}" ]]; then

                if [ ! -d "${path_ipset_subfolder}" ]; then
                    mkdir -p "${path_ipset_subfolder}"

                    if [ -d "${path_ipset_subfolder}" ]; then
                        ok "    📂 Created ${greenl}${path_ipset_subfolder}"
                    else
                        error "    ❌ Failed to create ${redl}${path_ipset_subfolder}"
                    fi
                fi

                created_folders[${path_ipset_subfolder}]=1
            fi
            path_ipset="${path_ipset_subfolder}/asn_${ipset_read_asn}_${ipset_orgname}.${file_target_ext_tmp}"
        fi

        debug "    ➕ Adding IP/Subnet › IP ${bluel}${ipset_read_subnet}${greym} › ASN ${bluel}${ipset_read_asn}${greym} › Org ${bluel}${ipset_read_orgname}${greym} › File ${bluel}${path_ipset}${greym}"

        # #
        #   Add ASN and OrgName to top of file as placeholder, will be used to generate header at end 
        #   and the existing META_ lines will be removed.
        # #

        if [ ! -f "${path_ipset}" ]; then
            {
                echo "# META_ASN=${ipset_read_asn}"
                echo "# META_ORG=${ipset_read_orgname}"
            } >> "${path_ipset}"
        fi

        # #
        #   write ip / subnet to file
        # #

        echo "${ipset_read_subnet}" >> "${path_ipset}"

        # #
        #   Append to aggressive raw if --aggressive
        # #

        if [ "${argAggressive}" = "true" ]; then
            aggressive_raw="${folder_target_storage}/${folder_target_aggressive}/${file_target_aggressive}.${file_target_ext_tmp}"
            mkdir -p "$(dirname "${aggressive_raw}")"
            echo "${ipset_read_subnet}" >> "${aggressive_raw}"
        fi

    done < <(tail -n +2 "${TEMPDIR}/${file_source_csv_ipv6}")
}

# #
#   Ipsets › Merge
#   
#   Merge IPv4 and IPv6 Files
#   
#   Takes all of the ipv6 addresses and merges them with the ipv4 file.
#       blocklists/country/geolite/ipv6/AD.tmp  =>  blocklists/country/geolite/ipv4/AD.tmp
#       [ DELETED ]                             =>                         [ MERGED WITH ]
#   
#   Removes the ipv6 file after the merge is done.
# #

ipsets_Merge()
{
    echo
    info "    🔀 Merge › Start"

    # #
    #   Recursively find all IPv6 tmp files
    # #

    find "${path_storage_ipv6}" -type f -name "*.${file_target_ext_tmp}" | while read fullpath_ipv6; do
        file_ipv6=$(basename "${fullpath_ipv6}")
        dest_dir="${path_storage_ipv4}/$(basename $(dirname "${fullpath_ipv6}"))"

        if [ ! -d "${dest_dir}" ]; then
            mkdir -p "${dest_dir}"

            if [ -d "${dest_dir}" ]; then
                ok "    📂 Created ${greenl}${dest_dir}"
            else
                error "    ❌ Failed to create ${redl}${dest_dir}"
            fi
        fi

        # #
        #   merge ipv5 temp with perm file
        # #

        info "    🔀 Merge › ${bluel}${fullpath_ipv6}${end} › ${bluel}${dest_dir}/${file_ipv6}"
        cat "${fullpath_ipv6}" >> "${dest_dir}/${file_ipv6}"
        
        # #
        #   delete old ipv6 temp folder
        # #

        rm -f "${fullpath_ipv6}"
        if [ ! -d "${fullpath_ipv6}" ]; then
            ok "    🗑️ Removed folder ${greenl}${fullpath_ipv6}"
        else
            error "    ❌ Failed to remove folder ${redl}${fullpath_ipv6}"
        fi
    done
}

# #
#   Ipsets › Finalize
#   
#   move .tmp files to .ipset
#   also generates @/aggressive.ipset if --aggressive is used
# #

ipsets_Finalize()
{
    echo

    info "    🚛 Finalize › Start"

    # #
    #   Ensure permanent storage directory exists.
    #   Location where finalized ipset files are written to.
    #       blocklists/geolite/asn
    # #

    if [ ! -d "${folder_target_storage}" ]; then
        mkdir -p "${folder_target_storage}"
        if [ -d "${folder_target_storage}" ]; then
            ok "    📂 Created ${greenl}${folder_target_storage}"
        else
            error "    ❌ Failed to create ${redl}${folder_target_storage}"
        fi
    fi

    # #
    #   Aggressive mode paths
    #   
    #       aggressive_raw      › temporary merged list (pre-dedup)
    #       aggressive_file     › final aggressive ipset file
    # #

    aggressive_raw="${folder_target_storage}/${folder_target_aggressive}/${file_target_aggressive}.${file_target_ext_tmp}"
    aggressive_file="${folder_target_storage}/${folder_target_aggressive}/${file_target_aggressive}.${ext_target_ipset}"
    
    # #
    #   Remove any existing aggressive output file.
    #   Ensures a clean rebuild every run.
    # #

    if [ -f "${aggressive_file}" ]; then
        rm -f "${aggressive_file}"
        if [ ! -d "${aggressive_file}" ]; then
            ok "    🗑️ Removed folder ${greenl}${aggressive_file}"
        else
            error "    ❌ Failed to remove folder ${redl}${aggressive_file}"
        fi
    fi

    # #
    #   Process both IPv4 and IPv6 staging directories.
    #   Create each of the .tmp files being processed.
    # #

    for DIR in "${path_storage_ipv4}" "${path_storage_ipv6}"; do
        if [ -d "${DIR}" ]; then

            # #
            #   Iterate recursively over all .tmp files.
            #   These are converted from .tmp to final .ipset files
            # #

            while IFS= read -r -d '' tmpfile; do
                relative_subfolder=$(dirname "${tmpfile#${DIR}/}")
                target_dir="${folder_target_storage}/${relative_subfolder}"
                mkdir -p "${target_dir}"
                if [ -d "${target_dir}" ]; then
                    ok "    📂 Created ${greenl}${target_dir}"
                else
                    error "    ❌ Failed to create ${redl}${target_dir}"
                fi

                # #
                #   Build final filename
                #   Strips .tmp extension and replaces with .ipset
                #   
                #   basename_tmp    asn_212513_osnet_telekomunikasyon_dis_ticaret_limited_sirketi
                #   tmpfile         ./blocklists/geolite/asn/ipv4/212000/asn_212513_osnet_telekomunikasyon_dis_ticaret_limited_sirketi.tmp
                #   target_file     blocklists/geolite/asn/212000/asn_212513_osnet_telekomunikasyon_dis_ticaret_limited_sirketi.ipset
                #   target_dir      blocklists/geolite/asn/212000
                # #

                basename_tmp=$(basename "${tmpfile}" .${file_target_ext_tmp})             # asn_212513_osnet_telekomunikasyon_dis_ticaret_limited_sirketi
                target_file="${target_dir}/${basename_tmp}.${ext_target_ipset}"             # blocklists/geolite/asn/212000/asn_212513_osnet_telekomunikasyon_dis_ticaret_limited_sirketi.ipset


                # #
                #   Determine ASN and organization name
                #   
                #   Priority:
                #       › CLI-provided ASN arguments
                #       › Metadata embedded in the temp file
                #       › Filename fallback
                #   
                #   Only execute if argFolder + argFile + argASN specified
                # #

                if [[ -n "${argFolder}" && -n "${argFile}" && "${#argASN[@]}" -gt 0 ]]; then
                    debug "    ℹ️  Getting ASN and Org from list"

                    # #
                    #   Build comma+space ASN list for header output
                    # #
    
                    debug "    ℹ️  Found ASNs ${argASN[@]}"
                    ipset_read_asn=$(IFS=', '; echo "${argASN[*]}")

                    # #
                    #   Read organization name from META_ORG tag if present
                    # #

                    meta_org=$(grep -m1 '^# META_ORG=' "${tmpfile}" | cut -d'=' -f2)
                    ipset_read_orgname="${meta_org:-${basename_tmp}}"

                    # #
                    #   Normalize org name for safe filenames
                    # #

                    ipset_read_orgname=$(echo "${ipset_orgname}" \
                        | tr '[:upper:]' '[:lower:]' \
                        | sed 's/[^a-z0-9]/_/g; s/_\+/_/g; s/_$//')

                    ipset_display_org=$(echo "${ipset_read_orgname}" \
                        | tr '_' ' ' \
                        | sed 's/\b\(.\)/\u\1/g')

                    debug "    ℹ️  Assigning ASN ${ipset_read_asn}"

                # #
                #   Custom --folder and --file not specified
                # #

                else
                    debug "    ℹ️  Getting ASN and Org from temp file"

                    # #
                    #   Default behavior: read ASN & ORG from temp file
                    # #

                    ipset_read_asn=$(grep -m1 '^# META_ASN=' "${tmpfile}" | cut -d'=' -f2)
                    ipset_read_orgname=$(grep -m1 '^# META_ORG=' "${tmpfile}" | cut -d'=' -f2 | sed 's/^"\(.*\)"$/\1/')

                fi

                # #
                #   Formatter-style cleanup:
                #       - match bl-format.sh normalization rules exactly
                #       - sort and deduplicate with IPv4/IPv6 awareness
                #       - filter bogon addresses
                #       - compute stats from cleaned data
                # #

                tmp_clean="${tmpfile}.clean"
                cat "${tmpfile}" > "${tmp_clean}"

                # normalize CRLF
                sed -i 's/\r$//' "${tmp_clean}"

                # remove hyphens from IP ranges (if format is "1.2.3.4 - 1.2.3.5" take left side)
                sed -i 's/-.*//' "${tmp_clean}"

                # remove inline comments (strip ' # comment' or ' ; comment' from end of lines ; collapse whitespace, trim)
                sed -i 's/[[:space:]]*[#;].*$//' "${tmp_clean}"

                # collapse multiple whitespace into a single space
                sed -i 's/[[:space:]]\+/ /g' "${tmp_clean}"

                # trim leading and trailing whitespace
                sed -i 's/^[[:space:]]*//;s/[[:space:]]*$//' "${tmp_clean}"

                # remove empty lines (after trimming/comment removal)
                sed -i '/^$/d' "${tmp_clean}"
                sort_results < "${tmp_clean}" > "${tmp_clean}.sort"
                mv "${tmp_clean}.sort" "${tmp_clean}"
                filter_bogon_ips "${tmp_clean}"

                count_ip_stats "${tmp_clean}"
                _count_total_ips=$total_ips
                _count_total_subnets=$total_subnets

                _count_total_ips=$(printf "%'d" "$_count_total_ips")                        # LOCAL add commas to thousands
                _count_total_subnets=$(printf "%'d" "$_count_total_subnets")                # LOCAL add commas to thousands

                total_lines=$(wc -l < "${tmp_clean}")
                total_lines=$(printf "%'d" "$total_lines")
                total_ips=${_count_total_ips}
                total_subnets=${_count_total_subnets}

                # #
                #   Define › Template
                # #

                templ_now="$(date -u '+%a %b %d %T %Z %Y')"                                     # Get current date in utc format
                templ_url="https://raw.githubusercontent.com/${app_repo}/${app_repo_branch}/${folder_target_storage}/${relative_subfolder}/${basename_tmp}.${ext_target_ipset}"
                templ_path="${folder_target_storage}/${relative_subfolder}/${basename_tmp}.${ext_target_ipset}" # blocklists/geolite/asn/3000/asn_13335_cloudflare_inc.ipset
                templ_path="${templ_path#blocklists/}"                                          # geolite/asn/3000/asn_13335_cloudflare_inc.ipset
                templ_path="${templ_path%.ipset}"                                               # remove extension
                templ_id="${templ_path//\//_}"                                                  # geolite_asn_3000_asn_13335_cloudflare_inc
                templ_id="${templ_id//[^[:alnum:]@]/_}"                                         # sanitize; special characters to underscore.
                templ_id="${templ_id}_ipset"                                                    # match your existing format
                templ_uuid="$(uuidgen -m -N "${templ_id}" -n @url)"                             # stable release ID
                templ_run_uuid="$(uuidgen)"                                                     # UNIQUE per execution
                templ_tmp_prefix="${app_dir_github}/${folder_target_temp}/${templ_run_uuid}"
                templ_curl_opts=(-sSL -A "$app_agent")                                          # cUrl command

                # #
                #   Template › External Sources
                # #

                if [ ! -d "${app_dir_github}/${folder_target_temp}" ]; then
                    mkdir -p "${app_dir_github}/${folder_target_temp}"
                fi

                if [ ! -d "${app_dir_github}/${folder_target_temp}" ]; then
                    error "          Could not create temp folder ${redd}${app_dir_github}/${folder_target_temp}${end}"
                    exit 1
                fi

                info "    ⚙️  Loading curl opts ${bluel}${templ_curl_opts[*]}${greym}"
                info "    ⭐ Downloading external template sources"
                label "     ${bluel}${app_repo_curl_storage}/templates/descriptions/${templ_path}.txt${greym} -> ${bluel}${templ_tmp_prefix}_desc.txt${greym}"
                label "     ${bluel}${app_repo_curl_storage}/templates/categories/${templ_path}.txt${greym} -> ${bluel}${templ_tmp_prefix}_cat.txt${greym}"
                label "     ${bluel}${app_repo_curl_storage}/templates/expires/${templ_path}.txt${greym} -> ${bluel}${templ_tmp_prefix}_exp.txt${greym}"
                label "     ${bluel}${app_repo_curl_storage}/templates/sources/${templ_path}.txt${greym} -> ${bluel}${templ_tmp_prefix}_src.txt${greym}"

                # #
                #   Template › Get
                # #

                curl "${templ_curl_opts[@]}" \
                    "${app_repo_curl_storage}/templates/descriptions/${templ_path}.txt" \
                    > "${templ_tmp_prefix}_desc.txt" &

                curl "${templ_curl_opts[@]}" \
                    "${app_repo_curl_storage}/templates/categories/${templ_path}.txt" \
                    > "${templ_tmp_prefix}_cat.txt" &

                curl "${templ_curl_opts[@]}" \
                    "${app_repo_curl_storage}/templates/expires/${templ_path}.txt" \
                    > "${templ_tmp_prefix}_exp.txt" &

                curl "${templ_curl_opts[@]}" \
                    "${app_repo_curl_storage}/templates/sources/${templ_path}.txt" \
                    > "${templ_tmp_prefix}_src.txt" &

                wait

                # #
                #   Template › Write Variable from Temp File
                # #

                templ_desc=$(<"${templ_tmp_prefix}_desc.txt")
                templ_cat=$(<"${templ_tmp_prefix}_cat.txt")
                templ_exp=$(<"${templ_tmp_prefix}_exp.txt")
                templ_src=$(<"${templ_tmp_prefix}_src.txt")

                # #
                #   Template › Remove Temp File
                # #

                if rm -f "${templ_tmp_prefix}_desc.txt" "${templ_tmp_prefix}_cat.txt" "${templ_tmp_prefix}_exp.txt" "${templ_tmp_prefix}_src.txt"; then
                    ok "    🗑️  Removed temp files from ${greenl}${app_dir_github}/${folder_target_temp}${greym}: ${greend}desc.txt${greym}, ${greend}cat.txt${greym}, ${greend}exp.txt${greym}, ${greend}src.txt${greym}"
                else
                    error "    ⭕ Could not remove temp files from ${redd}${app_dir_github}/${folder_target_temp}${end}"
                    exit 1
                fi

                # #
                #   Template › Default Values
                # #

                [ -z "$templ_desc" ] || [[ "$templ_desc" == *"404: Not Found"* ]] && templ_desc="#   No description provided"
                [ -z "$templ_cat"  ] || [[ "$templ_cat"  == *"404: Not Found"* ]] && templ_cat="Uncategorized"
                [ -z "$templ_exp"  ] || [[ "$templ_exp"  == *"404: Not Found"* ]] && templ_exp="6 hours"
                [ -z "$templ_src"  ] || [[ "$templ_src"  == *"404: Not Found"* ]] && templ_src="None"

                # #
                #   Output › Header
                # #

                echo
                prinp "📄[-1] ${target_file}" \
                "${greym}File: 	    ${greyd}.............${yellowl} ${target_file} \
                ${greyd}\n${greym}Id: 	    ${greyd}...............${yellowl} ${templ_id}${greyd} \
                ${greyd}\n${greym}UUID:	        ${greyd}.............${yellowl} ${templ_uuid}${greyd} \
                ${greyd}\n${greym}Category:	        ${greyd}.........${yellowl} ${templ_cat}${greyd} \
                ${greyd}\n${greym}Script:	       ${greyd}...........${yellowl} ${app_file_this}${greyd} \
                ${greyd}\n${greym}Source:	         ${greyd}...........${yellowl} ${templ_src}${greyd}"

                # #
                #   Build ASN header block
                #       - Match bl-whois template style
                #       - Start with @asn on first line
                #       - Wrap every 5 ASNs
                # #

                _asn_source="${ipset_read_asn}"
                _asn_source=$(printf '%s' "${_asn_source}" | sed 's/[[:space:]]*,[[:space:]]*/,/g; s/[[:space:]]\+/,/g; s/,,*/,/g; s/^,//; s/,$//')
                IFS=',' read -r -a _asn_parts <<< "${_asn_source}"
                _asn_values=()

                for _asn_part in "${_asn_parts[@]}"; do
                    _asn_part=$(printf '%s' "${_asn_part}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                    [ -z "${_asn_part}" ] && continue

                    if printf '%s\n' "${_asn_part}" | grep -qE '^([Aa][Ss])?[0-9]+$'; then
                        _asn_digits=$(printf '%s' "${_asn_part}" | sed -E 's/^([Aa][Ss])?([0-9]+)$/\2/')
                        _asn_values+=( "AS${_asn_digits}" )
                    fi
                done

                if [ "${#_asn_values[@]}" -eq 0 ]; then
                    if printf '%s\n' "${ipset_read_asn}" | grep -qE '^[0-9]+$'; then
                        _asn_values=( "AS${ipset_read_asn}" )
                    elif [ -n "${ipset_read_asn}" ]; then
                        _asn_values=( "${ipset_read_asn}" )
                    else
                        _asn_values=( "None" )
                    fi
                fi

                _asn_header_block=""
                _asn_step=0
                for _asn_entry in "${_asn_values[@]}"; do
                    if [ "${_asn_step}" -eq 0 ]; then
                        _asn_header_block="#   @asn            ${_asn_entry}"
                    elif [ $(( _asn_step % 5 )) -eq 0 ]; then
                        _asn_header_block="${_asn_header_block}\n#                   ${_asn_entry}"
                    else
                        _asn_header_block="${_asn_header_block}, ${_asn_entry}"
                    fi
                    _asn_step=$(( _asn_step + 1 ))
                done

                # #
                #   Write ipset header and metadata block
                # #

                {
                    echo "# #"
                    echo "#   🧱 Firewall Blocklist - ${target_file}"
                    echo "#"
                    echo "#   @blocklist      ${templ_url}"
                    echo "#   @source         ${templ_src}"
                    echo "#   @id             ${templ_id}"
                    echo "#   @uuid           ${templ_uuid}"
                    echo "#   @updated        ${templ_now}"
                    echo "#   @entries        ${total_ips} ips"
                    echo "#                   ${total_subnets} subnets"
                    echo "#                   ${total_lines} lines"
                    printf "%b\n" "${_asn_header_block}"
                    echo "#   @expires        ${templ_exp}"
                    echo "#   @category       ${templ_cat}"
                    echo "#"
                    echo "#   Includes both IPv4 and IPv6 networks merged"
                    echo "# #"
                    echo
                } > "${target_file}"

                # #
                #   Append cleaned IP ranges
                # #

                cat "${tmp_clean}" >> "${target_file}"

                # #
                #   Aggressive mode
                #   Merge all IPs into a single raw list
                # #

                if [ "${argAggressive}" = "true" ]; then
                    mkdir -p "$(dirname "${aggressive_raw}")"
                    cat "${tmp_clean}" >> "${aggressive_raw}"
                fi

                # #
                #   Cleanup temp file after successful processing
                # #

                rm -f "${tmpfile}"
                rm -f "${tmp_clean}"
                ok "    🚛 Moved ${bluel}${tmpfile}${greym} › ${bluel}${target_file}${greym}"

                unset   _asn_source _asn_parts _asn_values _asn_part _asn_digits \
                        _asn_header_block _asn_step _asn_entry
            done < <(find "${DIR}" -type f -name "*.${file_target_ext_tmp}" -print0)
        fi
    done

    # #
    #   Finalize aggressive blocklist
    #   Deduplicate, recalculate metrics, and write final file
    # #

    if [ "${argAggressive}" = "true" ] && [ -s "${aggressive_raw}" ]; then
        aggressive_dir="${folder_target_storage}/${folder_target_aggressive}"
        mkdir -p "${aggressive_dir}"

        # #
        #   Formatter-style cleanup for aggressive output
        # #

        dedup_file="${aggressive_raw}.dedup"
        cat "${aggressive_raw}" > "${dedup_file}"

        # normalize CRLF
        sed -i 's/\r$//' "${dedup_file}"

        # remove hyphens from IP ranges (if format is "1.2.3.4 - 1.2.3.5" take left side)
        sed -i 's/-.*//' "${dedup_file}"

        # remove inline comments (strip ' # comment' or ' ; comment' from end of lines ; collapse whitespace, trim)
        sed -i 's/[[:space:]]*[#;].*$//' "${dedup_file}"

        # collapse multiple whitespace into a single space
        sed -i 's/[[:space:]]\+/ /g' "${dedup_file}"

        # trim leading and trailing whitespace
        sed -i 's/^[[:space:]]*//;s/[[:space:]]*$//' "${dedup_file}"

        # remove empty lines (after trimming/comment removal)
        sed -i '/^$/d' "${dedup_file}"

        # #
        #   Dedupe, Sort: Move from .tmp to .sort
        # #

        info "    🔃 Sorting and deduplicating results"
        grep -vE '^[[:space:]]*(#|;|$)' "${dedup_file}" | sort_results > "${dedup_file}.sort"

        # #
        #   Move from .sort to .tmp
        # #

        mv "${dedup_file}.sort" "${dedup_file}"

        # #
        #   IPSET › Filter BOGON
        #       - Optional
        #       - Run before count_ip_stats for accurate totals
        # #

        filter_bogon_ips "${dedup_file}"

        # #
        #   Calculate list statistics
        #       - local only (global totals are calculated after final dedupe)
        # #

        info "    📊 Fetching statistics for clean file ${bluel}${dedup_file}${greym}"

        # #
        #   Recalculate totals for merged list
        # #

        count_ip_stats "${dedup_file}"
        _count_total_ips=$total_ips
        _count_total_subnets=$total_subnets

        _count_total_ips=$(printf "%'d" "$_count_total_ips")                        # LOCAL add commas to thousands
        _count_total_subnets=$(printf "%'d" "$_count_total_subnets")                # LOCAL add commas to thousands

        total_lines=$(wc -l < "${dedup_file}")
        total_lines=$(printf "%'d" "$total_lines")
        total_ips=${_count_total_ips}
        total_subnets=${_count_total_subnets}

        # #
        #   Write final aggressive ipset header
        # #

        # #
        #   Define › Template
        # #

        templ_now="$(date -u '+%a %b %d %T %Z %Y')"                                     # Get current date in utc format
        templ_url="https://raw.githubusercontent.com/${app_repo}/${app_repo_branch}/${folder_target_storage}/${folder_target_aggressive}/${file_target_aggressive}.${ext_target_ipset}"
        templ_path="${folder_target_storage}/${folder_target_aggressive}/${file_target_aggressive}.${ext_target_ipset}" # blocklists/geolite/asn/@general/aggressive.ipset
        templ_path="${templ_path#blocklists/}"                                          # geolite/asn/@general/aggressive.ipset
        templ_path="${templ_path%.ipset}"                                               # remove extension
        templ_id="${templ_path//\//_}"                                                  # geolite_asn_@general_aggressive
        templ_id="${templ_id//[^[:alnum:]@]/_}"                                         # sanitize; special characters to underscore.
        templ_id="${templ_id}_ipset"                                                    # match your existing format
        templ_uuid="$(uuidgen -m -N "${templ_id}" -n @url)"                             # stable release ID
        templ_run_uuid="$(uuidgen)"                                                     # UNIQUE per execution
        templ_tmp_prefix="${app_dir_github}/${folder_target_temp}/${templ_run_uuid}"
        templ_curl_opts=(-sSL -A "$app_agent")                                          # cUrl command

        # #
        #   Template › External Sources
        # #

        if [ ! -d "${app_dir_github}/${folder_target_temp}" ]; then
            mkdir -p "${app_dir_github}/${folder_target_temp}"
        fi
        if [ ! -d "${app_dir_github}/${folder_target_temp}" ]; then
            error "          Could not create temp folder ${redd}${app_dir_github}/${folder_target_temp}${end}"
            exit 1
        fi

        info "    ⚙️  Loading curl opts ${bluel}${templ_curl_opts[*]}${greym}"
        info "    ⭐ Downloading external template sources"
        label "     ${bluel}${app_repo_curl_storage}/templates/descriptions/${templ_path}.txt${greym} -> ${bluel}${templ_tmp_prefix}_desc.txt${greym}"
        label "     ${bluel}${app_repo_curl_storage}/templates/categories/${templ_path}.txt${greym} -> ${bluel}${templ_tmp_prefix}_cat.txt${greym}"
        label "     ${bluel}${app_repo_curl_storage}/templates/expires/${templ_path}.txt${greym} -> ${bluel}${templ_tmp_prefix}_exp.txt${greym}"
        label "     ${bluel}${app_repo_curl_storage}/templates/sources/${templ_path}.txt${greym} -> ${bluel}${templ_tmp_prefix}_src.txt${greym}"

        # #
        #   Template › Get
        # #

        curl "${templ_curl_opts[@]}" \
            "${app_repo_curl_storage}/templates/descriptions/${templ_path}.txt" \
            > "${templ_tmp_prefix}_desc.txt" &

        curl "${templ_curl_opts[@]}" \
            "${app_repo_curl_storage}/templates/categories/${templ_path}.txt" \
            > "${templ_tmp_prefix}_cat.txt" &

        curl "${templ_curl_opts[@]}" \
            "${app_repo_curl_storage}/templates/expires/${templ_path}.txt" \
            > "${templ_tmp_prefix}_exp.txt" &

        curl "${templ_curl_opts[@]}" \
            "${app_repo_curl_storage}/templates/sources/${templ_path}.txt" \
            > "${templ_tmp_prefix}_src.txt" &

        wait

        # #
        #   Template › Write Variable from Temp File
        # #

        templ_desc=$(<"${templ_tmp_prefix}_desc.txt")
        templ_cat=$(<"${templ_tmp_prefix}_cat.txt")
        templ_exp=$(<"${templ_tmp_prefix}_exp.txt")
        templ_src=$(<"${templ_tmp_prefix}_src.txt")

        # #
        #   Template › Remove Temp File
        # #

        if rm -f "${templ_tmp_prefix}_desc.txt" "${templ_tmp_prefix}_cat.txt" "${templ_tmp_prefix}_exp.txt" "${templ_tmp_prefix}_src.txt"; then
            ok "    🗑️  Removed temp files from ${greenl}${app_dir_github}/${folder_target_temp}${greym}: ${greend}desc.txt${greym}, ${greend}cat.txt${greym}, ${greend}exp.txt${greym}, ${greend}src.txt${greym}"
        else
            error "    ⭕ Could not remove temp files from ${redd}${app_dir_github}/${folder_target_temp}${end}"
            exit 1
        fi

        # #
        #   Template › Default Values
        # #

        [ -z "$templ_desc" ] || [[ "$templ_desc" == *"404: Not Found"* ]] && templ_desc="#   No description provided"
        [ -z "$templ_cat"  ] || [[ "$templ_cat"  == *"404: Not Found"* ]] && templ_cat="Uncategorized"
        [ -z "$templ_exp"  ] || [[ "$templ_exp"  == *"404: Not Found"* ]] && templ_exp="6 hours"
        [ -z "$templ_src"  ] || [[ "$templ_src"  == *"404: Not Found"* ]] && templ_src="None"

        # #
        #   Output › Header
        # #

        echo
        prinp "📄[-1] ${file_target_aggressive}.${ext_target_ipset}" \
        "${greym}File: \t    ${greyd}.............${yellowl} ${file_target_aggressive}.${ext_target_ipset}${greyd} \
        ${greyd}\n${greym}Id: \t    ${greyd}...............${yellowl} ${templ_id}${greyd} \
        ${greyd}\n${greym}UUID:\t        ${greyd}.............${yellowl} ${templ_uuid}${greyd} \
        ${greyd}\n${greym}Category:\t        ${greyd}.........${yellowl} ${templ_cat}${greyd} \
        ${greyd}\n${greym}Script:\t       ${greyd}...........${yellowl} ${app_file_this}${greyd} \
        ${greyd}\n${greym}Source:	         ${greyd}...........${yellowl} ${templ_src}${greyd}"
        {
            echo "# #"
            echo "#   🧱 Firewall Blocklist - ${aggressive_file}"
            echo "#"
            echo "#   @blocklist      ${templ_url}"
            echo "#   @source         ${templ_src}"
            echo "#   @id             ${templ_id}"
            echo "#   @uuid           ${templ_uuid}"
            echo "#   @updated        ${templ_now}"
            echo "#   @entries        ${total_ips} ips"
            echo "#                   ${total_subnets} subnets"
            echo "#                   ${total_lines} lines"
            echo "#   @expires        ${templ_exp}"
            echo "#   @category       ${templ_cat}"
            echo "#"
            echo "#   This blocklist contains IP ranges belonging to nearly every major VPS and hosting provider."
            echo "#   These networks are frequently used to deploy brute-force tools, scanning utilities, proxy"
            echo "#   relays, port sniffers, and many other forms of malicious traffic against exposed servers."
            echo "#   "
            echo "#   Providers such as Microsoft, Google, Amazon AWS, Azure, Hetzner, Contabo, HostGator,"
            echo "#   InMotion, OVH, DigitalOcean, Linode, and many others will be completely restricted here."
            echo "#   "
            echo "#   Use this blocklist only if you are certain that you want to block nearly all cloud or"
            echo "#   VPS infrastructure providers from reaching your server or hosted applications directly."
            echo "#   "
            echo "#   Includes all IPv4 and IPv6 networks merged"
            echo "# #"
            echo
        } > "${aggressive_file}"

        # Append deduplicated IPs
        grep -vE '^[#;]' "${dedup_file}" >> "${aggressive_file}"

        rm -f "${aggressive_raw}" "${dedup_file}"
        if [ ! -d "${aggressive_raw}" ]; then
            ok "    🗑️ Removed folder ${greenl}${aggressive_raw}"
        else
            error "    ❌ Failed to remove folder ${redl}${aggressive_raw}"
        fi
        
        if [ ! -d "${dedup_file}" ]; then
            ok "    🗑️ Removed folder ${greenl}${dedup_file}"
        else
            error "    ❌ Failed to remove folder ${redl}${dedup_file}"
        fi

        ok "    🚛 Finalized ${greenl}${aggressive_file}"
        label "       ${greyd}› IPs: ${total_ips} › Subnets: ${total_subnets} › Lines: ${total_lines}${greym}"
    fi

}

# #
#   Summary › Final Totals
#   
#   Calculates totals across all generated .ipset files and prints a footer
#   consistent with other blocklist scripts.
# #

summary_PrintFooter( )
{
    _fnTargetFile=$1
    _fnTotalIps=0
    _fnTotalSubnets=0
    _fnTotalLines=0
    _fnFileLines=0
    if [ -n "${_fnTargetFile}" ] && [ -f "${_fnTargetFile}" ]; then
        _fnFileLines=$(grep -vE '^[[:space:]]*(#|;|$)' "${_fnTargetFile}" | wc -l)
        _fnTotalLines=$(( _fnTotalLines + _fnFileLines ))

        count_ip_stats "${_fnTargetFile}"
        _fnTotalIps=$(( _fnTotalIps + total_ips ))
        _fnTotalSubnets=$(( _fnTotalSubnets + total_subnets ))

        label "          Created file: ${bluel}${_fnTargetFile}${greym}"
    else
        while IFS= read -r -d '' _fnIpsetFile; do
            _fnFileLines=$(grep -vE '^[[:space:]]*(#|;|$)' "${_fnIpsetFile}" | wc -l)
            _fnTotalLines=$(( _fnTotalLines + _fnFileLines ))

            count_ip_stats "${_fnIpsetFile}"
            _fnTotalIps=$(( _fnTotalIps + total_ips ))
            _fnTotalSubnets=$(( _fnTotalSubnets + total_subnets ))
        done < <(find "${folder_target_storage}" -type f -name "*.${ext_target_ipset}" -print0)
    fi

    total_lines=$(printf "%'d" "${_fnTotalLines}")
    total_subnets=$(printf "%'d" "${_fnTotalSubnets}")
    total_ips=$(printf "%'d" "${_fnTotalIps}")

    # #
    #   Finished
    #       - Capture end time
    #       - Calculate elapsed time
    #       - Calculate days, hours, etc.
    #       - Output to console
    # #

    time_end=$( date +%s )
    T=$(( time_end - time_start ))
    D=$(( T / 86400 ))
    H=$(( (T % 86400) / 3600 ))
    M=$(( (T % 3600) / 60 ))
    S=$(( T % 60 ))

    prinp "🎌[41] Finished!   ${fuchsiad}IPs: ${yellowl}${total_ips}${fuchsiad}   Subnets: ${yellowl}${total_subnets}${greyd}${fuchsiad}   Duration: ${yellowl}${D} days ${H} hrs ${M} mins ${S} secs${greyd}" false

    unset   _fnTargetFile _fnTotalIps _fnTotalSubnets _fnTotalLines _fnFileLines _fnIpsetFile \
            time_end T D H M S
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
    # #
    #   License fallback order:
    #       1) --license / -l argument
    #       2) MAXMIND_LICENSE_KEY env var
    #       3) API_GEOLITE2_KEY env var
    #       4) LICENSE_KEY from geolite2.conf
    # #

    if [ -z "${argMMLicense}" ]; then
        if [ -n "${MAXMIND_LICENSE_KEY:-}" ]; then
            argMMLicense="${MAXMIND_LICENSE_KEY}"
        elif [ -n "${API_GEOLITE2_KEY:-}" ]; then
            argMMLicense="${API_GEOLITE2_KEY}"
        elif [ -n "${LICENSE_KEY:-}" ]; then
            argMMLicense="${LICENSE_KEY}"
        fi
    fi

    if [ "${argUseLocalDB}" != "true" ] && [ -z "${argMMLicense}" ]; then
        error "    ❌ Must supply valid MaxMind license key. Aborting ..."
        exit 1
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
            ok "    📂 Created ${greenl}${app_dir_github}/${folder_source_local}"
        else
            error "    ❌ Failed to create ${redl}${app_dir_github}/${folder_source_local}"
        fi

        TEMPDIR="${app_dir_github}/${folder_source_local}"
    fi

    ok "    📄 Set TEMPDIR ${greenl}${TEMPDIR}"
    export TEMPDIR

    # #
    #   Place geolite data in temporary directory
    # #

    info "    ⚙️ Creating tempdir folder ${bluel}${TEMPDIR}"
    OLD_PWD=$(pwd)
    cd "${TEMPDIR}" || exit 1

    # #
    #   Download / Unzip .zip
    # #

    maxmind_Database_Download
    maxmind_Database_Load
    asn_Index_Prepare

    # #
    #   Place set output in current working directory
    # #

    cd "$OLD_PWD" || exit 1

    # #
    #   Cleanup old files
    # #

    if [ "$argClean" = true ]; then
        info "    🗑️ Cleaning ${bluel}${folder_target_storage}"
        rm -rf "${folder_target_storage}"/*
        if [ ! -d "${folder_target_storage}" ]; then
            ok "    🗑️ Removed folder ${greenl}${folder_target_storage}"
        else
            error "    ❌ Failed to remove folder ${redl}${folder_target_storage}"
        fi
    fi

    # #
    #   Cleanup › ipv4
    # #

    if geolite2_ReuseEnabled; then
        info "    ♻️ Reuse mode enabled; skipping pre-run cleanup for ${bluel}${path_storage_ipv4}${greym}"
    else
        rm -rf "${path_storage_ipv4}"
        if [ ! -d "${path_storage_ipv4}" ]; then
            ok "    🗑️ Removed folder ${greenl}${path_storage_ipv4}"
        else
            error "    ❌ Failed to remove folder ${redl}${path_storage_ipv4}"
        fi
    fi
    
    if [ ! -d "${path_storage_ipv4}" ]; then
        mkdir -p "${path_storage_ipv4}"

        if [ -d "${path_storage_ipv4}" ]; then
            ok "    📂 Created ${greenl}${path_storage_ipv4}"
        else
            error "    ❌ Failed to create ${redl}${path_storage_ipv4}"
        fi
    fi

    # #
    #   Cleanup › ipv6
    # #

    if geolite2_ReuseEnabled; then
        info "    ♻️ Reuse mode enabled; skipping pre-run cleanup for ${bluel}${path_storage_ipv6}${greym}"
    else
        rm -rf "${path_storage_ipv6}"
        if [ ! -d "${path_storage_ipv6}" ]; then
            ok "    🗑️ Removed folder ${greenl}${path_storage_ipv6}"
        else
            error "    ❌ Failed to remove folder ${redl}${path_storage_ipv6}"
        fi
    fi

    if [ ! -d "${path_storage_ipv6}" ]; then
        mkdir -p "${path_storage_ipv6}"

        if [ -d "${path_storage_ipv6}" ]; then
            ok "    📂 Created ${greenl}${path_storage_ipv6}"
        else
            error "    ❌ Failed to create ${redl}${path_storage_ipv6}"
        fi
    fi

    # #
    #   Run actions
    # #

    generate_IPv4
    generate_IPv6
    ipsets_Merge
    ipsets_Finalize
    gcc
    summary_PrintFooter "${target_file}"
}

main "$@"