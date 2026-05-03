#!/bin/bash

# #
#   @script             Blocklist › Helper › Range to CIDR
#   @repo               https://github.com/ConfigServer-Software/service-blocklists
#   @workflow           blocklist-generate.yml
#   @type               bash script
#   @summary            Generate list of IPs in CIDR format from a specified range.
#   @path               .github/scripts/helper-range-cidr.sh
#   @args               .github/scripts/helper-range-cidr.sh
#                           <argFileSource>     str         required
#                           <argFileSaveto>     str         required
#   @commands           1.  .github/scripts/tool-range-ipcalc.sh file_input.txt blocklists/file_output.ipset
#   @structure          📁 .github
#                           📁 scripts
#                               📄 microsoft365.sh
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
#   Define › Set PATH
# #

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"
export LC_NUMERIC=en_US.UTF-8

# #
#   Define › Files
# #

app_file_this=$(basename "$0")                                                  # bl-format.sh   (with ext)
app_file_bin="${app_file_this%.*}"                                              # bl-format      (without ext)

# #
#   Define › Folders
# #

app_dir="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"                        # path where script was last found in
app_dir_this_dir="${PWD}"                                                       # current script directory
app_dir_github="${app_dir_this_dir}/.github"                                    # .github folder

# #
#   Define › Arguments
#   
#   This bash script has the following arguments:
#   
#   @param  argFileSource       str         Source file containing IP ranges
#           argFileSaveto       str         Target file to save with CIDRs
# #

argFileSource=$1
argFileSaveto=$2

# #
#   Define › App
# #

file_ipset_temp="${argFileSaveto}.tmp"                                          # Temp file when building ipset list
file_ipset_target="${argFileSaveto}"                                            # Perm file when building ipset list
folder_target_temp="temp"                                                       # Temp folder when building descriptions, etc.

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

app_name="Blocklist › Helper › ipCalc"                                          # name of app
app_desc="Convert range of IPs to CIDR"                                         # desc
app_ver="1.2.0.0"                                                               # current script version
app_repo="ConfigServerApps/service-blocklists"                                  # repository
app_repo_branch="main"                                                          # repository branch
app_repo_curl_storage="https://raw.githubusercontent.com/${app_repo}/${app_repo_branch}/.github"
app_agent="Mozilla/5.0 (Windows NT 10.0; WOW64) "\
"AppleWebKit/537.36 (KHTML, like Gecko) "\
"Chrome/51.0.2704.103 Safari/537.36 "\
"ConfigServer Security (hello@configserver.dev)"                                # user agent used with curl

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
#   Verify › Arguments
# #

if [ -z "${argFileSource}" ]; then
    error "    ⭕  No source file specified ${yellowd}${app_file_this}${greym}; aborting${end}"
    exit 0
fi

if [ -z "${argFileSaveto}" ]; then
    error "    ⭕  No target file specified ${yellowd}${app_file_this}${greym}; aborting${end}"
    exit 0
fi

# #
#   Define › Time
# #

time_start=$( date +%s )                                                        # record start time of script
SECONDS=0                                                                       # set seconds count for beginning of script

# #
#   Create or Clean file
# #

if [ -f "${file_ipset_target}" ]; then
    info "    📄 Clean ${bluel}${PWD}/${file_ipset_target}${greym}"
   > "${file_ipset_target}"       # clean file
else
    info "    📁 Create ${bluel}${PWD}/${file_ipset_target}${greym}"
    mkdir -p "$(dirname "${file_ipset_target}")"

    if [ -d "$(dirname "${file_ipset_target}")" ]; then
        ok "    📁 Created ${greenl}$( dirname "${file_ipset_target}" )${greym}"
    else
        error "    ⭕  Failed to create directory ${redl}$( dirname "${file_ipset_target}" )${greym}; aborting${greym}"
        exit 1
    fi

    touch "${file_ipset_target}"
    if [ -f "${file_ipset_target}" ]; then
        ok "    📄 Created perm file ${greenl}${PWD}/${file_ipset_target}${greym}"
    else
        error "    ⭕ Failed to create perm file ${bluel}${PWD}/${file_ipset_target}${greym}"
        exit 1
    fi
fi

# #
#   ip ranges converted to CIDR notation
#   
#   ipcalc adds extra lines; use awk to filter out words 'deaggregate', then append.
#   
#   ipcalc is very expensive; so large lists will take a while. Use it generously.
# #

cat "$argFileSource" | \
while IFS= read ip; do
    range_start=$(echo "$ip" | awk -F'-' '{gsub(/ /,"",$1); print $1}')
    range_end=$(echo "$ip"   | awk -F'-' '{gsub(/ /,"",$2); print $2}')

    if [[ -n "$range_start" && -n "$range_end" ]]; then
        info "    📄 Fetching CIDR from range ${bluel}${range_start} - ${range_end}${greym}" >&2
        ipcalc "$range_start" "$range_end" -nr | awk '!/^(deaggregate)/'
    fi
done >> "$file_ipset_target"