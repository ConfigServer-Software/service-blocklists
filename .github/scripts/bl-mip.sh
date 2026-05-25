#!/bin/bash

# #
#   @script             Blocklist › MIP IP Fetcher
#   @repo               https://github.com/ConfigServerApps/service-blocklists
#   @workflow           blocklist-generate.yml
#   @type               bash script
#   @summary            Fetche list of IPs from MIP website service online.
#                       If a new version of IPs cannot be fetched, fallback to 
#                       an existing local list within the '.github/blocks' folder.
#   @path               .github/scripts/bl-mip.sh
#   @params             .github/scripts/bl-mip.sh
#                           <argFileSaveTo>     str     req     Local file to save IP addresses.
#                           <argUrl>            str     req     MIP source URL; use ${i} for page number iteration.
#                           <argFallbackBlock>  str     req     Local fallback file in `.github/blocks` folder.
#   @commands           1.  ./.github/scripts/bl-mip.sh blocklists/privacy/privacy_anthropic.ipset 'https://myip.ms/browse/comp_ip/${i}/ownerID/1603724/ownerID_A' privacy/anthropic
#                       2.  CFG_SKIP_CIDR_DEDUPE=true CFG_SKIP_BOGON_FILTER=true ./.github/scripts/bl-mip.sh blocklists/privacy/privacy_anthropic.ipset 'https://myip.ms/browse/comp_ip/${i}/ownerID/1603724/ownerID_A' privacy/anthropic
#   @structure          📁 .github
#                           📁 scripts
#                               📄 bl-mip.sh
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

app_file_this=$(basename "$0")                                                  # bl-mip.sh     (with ext)
app_file_bin="${app_file_this%.*}"                                              # bl-mip        (without ext)

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
#   @param  argFileSaveTo       str         Local file to save IP addresses.
#           argUrl              str         MIP source URL; use ${i} for page number iteration.
#           argFallbackBlock    str         Local fallback file in /blocks folder.
# #

argFileSaveTo=$1
argUrl=$2
argFallbackBlock=${3:-Unknown}

# #
#   Define › App
# #

file_ipset_temp="${argFileSaveTo}.tmp"                                          # Temp file when building ipset list
file_ipset_target="${argFileSaveTo}"                                            # Perm file when building ipset list
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

app_name="Blocklist ›  MIP Service"                                             # name of app
app_desc="Fetch list of IP addresses from MIP service"                          # desc
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
argSortParallel="${CFG_SORT_PARALLEL:-}"                                        # optional sort --parallel value
argSortBufferSize="${CFG_SORT_BUFFER_SIZE:-}"                                   # optional sort -S value
did_load_fallback="false"                                                       # track whether fallback lists were merged
sort_cmd_opts=()                                                                # optional sort command tuning

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
#   Verify › Arguments
# #

if [ -z "${argFileSaveTo}" ]; then
    error "    ⭕  No target file specified ${yellowd}${app_file_this}${greym}; aborting${end}"
    exit 0
fi

if [ -z "${argUrl}" ]; then
    error "    ⭕  No MIP source URL template specified ${yellowd}${app_file_this}${greym}; aborting${end}"
    exit 0
fi

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
    info "    🗑️  Starting ${bluel}GCC${greym} cleanup"

    rm -rf "${app_dir_github}/${folder_target_temp}"

    if [ ! -d "${app_dir_github}/${folder_target_temp}" ]; then
        ok "    🗑️  Removed folder ${bluel}${app_dir_github}/${folder_target_temp}"
    else
        error "    ❌ Failed to remove folder ${greenl}${app_dir_github}/${folder_target_temp}"
    fi
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
#   Fetch Page
# #

fetch_page()
{
    _fnFetchUrl=$1
    _fnFetchAttempt=1
    _fnFetchMaxAttempts="${MIP_FETCH_RETRIES:-5}"
    _fnFetchConnectTimeout="${MIP_CONNECT_TIMEOUT:-10}"
    _fnFetchMaxTime="${MIP_MAX_TIME:-30}"
    _fnFetchExit=0
    _fnFetchContent=""
    _fnFetchUA="${MIP_UA:-Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:148.0) Gecko/20100101 Firefox/148.0}"
    _fnFetchCookie="${MIP_COOKIE:-}"

    case "${_fnFetchMaxAttempts}" in
        ''|*[!0-9]*)
            _fnFetchMaxAttempts=5
            ;;
    esac
    [ "${_fnFetchMaxAttempts}" -lt 1 ] && _fnFetchMaxAttempts=1
    case "${_fnFetchConnectTimeout}" in
        ''|*[!0-9]*) _fnFetchConnectTimeout=10 ;;
    esac
    [ "${_fnFetchConnectTimeout}" -lt 1 ] && _fnFetchConnectTimeout=10
    case "${_fnFetchMaxTime}" in
        ''|*[!0-9]*) _fnFetchMaxTime=30 ;;
    esac
    [ "${_fnFetchMaxTime}" -lt 1 ] && _fnFetchMaxTime=30

    while [ "${_fnFetchAttempt}" -le "${_fnFetchMaxAttempts}" ]; do
        info "    🌐 MIP fetch attempt ${bluel}${_fnFetchAttempt}/${_fnFetchMaxAttempts}${greym}: ${bluel}${_fnFetchUrl}${greym}" >&2
        sleep $(( RANDOM % 3 + 3 ))

        if [ -n "${_fnFetchCookie}" ]; then
            _fnFetchContent=$( curl -ksSL \
                --compressed \
                --connect-timeout "${_fnFetchConnectTimeout}" \
                --max-time "${_fnFetchMaxTime}" \
                -A "${_fnFetchUA}" \
                -b "${_fnFetchCookie}" \
                -H "Referer: ${_fnFetchUrl}" \
                -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
                -H "Accept-Language: en-US,en;q=0.9" \
                "${_fnFetchUrl}" )
            _fnFetchExit=$?
        else
            _fnFetchContent=$( curl -ksSL \
                --compressed \
                --connect-timeout "${_fnFetchConnectTimeout}" \
                --max-time "${_fnFetchMaxTime}" \
                -A "${_fnFetchUA}" \
                -H "Referer: ${_fnFetchUrl}" \
                -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
                -H "Accept-Language: en-US,en;q=0.9" \
                "${_fnFetchUrl}" )
            _fnFetchExit=$?
        fi

        # #
        #   Re-try
        # #

        if [ "${_fnFetchExit}" -ne 0 ]; then
            warn "    ⚠️  MIP request failed with curl exit ${yellowl}${_fnFetchExit}${greym} (attempt ${yellowl}${_fnFetchAttempt}${greym})" >&2
            _fnFetchAttempt=$(( _fnFetchAttempt + 1 ))
            continue
        fi

        if echo "${_fnFetchContent}" | grep -qiE "prove you.?re not a robot|/images/robots\.png"; then
            warn "    ⚠️  Robot challenge detected from MIP (attempt ${yellowl}${_fnFetchAttempt}${greym}), retrying" >&2
            _fnFetchAttempt=$(( _fnFetchAttempt + 1 ))
            continue
        elif echo "${_fnFetchContent}" | grep -qiE "You do not have permission to access this document"; then
            warn "    ⚠️  Rejected permission (attempt ${yellowl}${_fnFetchAttempt}${greym}), using fallback" >&2
            unset   _fnFetchUrl _fnFetchAttempt _fnFetchMaxAttempts _fnFetchConnectTimeout _fnFetchMaxTime _fnFetchExit _fnFetchContent _fnFetchUA _fnFetchCookie
            return 2
        fi

        printf '%s\n' "${_fnFetchContent}"
        unset   _fnFetchUrl _fnFetchAttempt _fnFetchMaxAttempts _fnFetchConnectTimeout _fnFetchMaxTime _fnFetchExit _fnFetchContent _fnFetchUA _fnFetchCookie
        return 0
    done

    error "    ⭕ Failed to fetch valid MIP page ${redl}${_fnFetchUrl}${greym} after ${redl}${_fnFetchMaxAttempts}${greym} attempts${greym}" >&2

    unset   _fnFetchUrl _fnFetchAttempt _fnFetchMaxAttempts _fnFetchConnectTimeout _fnFetchMaxTime _fnFetchExit _fnFetchContent _fnFetchUA _fnFetchCookie

    return 1
}

# #
#   Expand source URL template and inject a page number by replacing {i} or ${i} placeholders,
#   or using printf-style (%d) formatting if present. outputs formatted URL.
#   
#   https://myip.ms/browse/${i}/ownerid/xxxxxx/ownerid_A => https://myip.ms/browse/1/ownerid/xxxxxx/ownerid_A
# #

expand_mip_url()
{
    _fnUrlTemplate=$1
    _fnPageNum=$2
    _fnUrlExpanded="${_fnUrlTemplate//\$\{i\}/${_fnPageNum}}"
    _fnUrlExpanded="${_fnUrlExpanded//\{i\}/${_fnPageNum}}"

    # #
    #   If placeholder got stripped before reaching script (e.g. .../comp_ip//ownerID/...),
    #   inject the page number into the empty comp_ip segment.
    # #

    if [[ "${_fnUrlExpanded}" == *"/comp_ip//"* ]]; then
        _fnUrlExpanded="${_fnUrlExpanded/\/comp_ip\/\//\/comp_ip\/${_fnPageNum}\/}"
    fi

    if [ "${_fnUrlExpanded}" = "${_fnUrlTemplate}" ] && [[ "${_fnUrlTemplate}" == *%d* ]]; then
        printf "${_fnUrlTemplate}" "${_fnPageNum}"
    else
        printf '%s\n' "${_fnUrlExpanded}"
    fi

    unset _fnUrlTemplate _fnPageNum _fnUrlExpanded
}

# #
#   Blocklist › Fallback › Download
#   
#   If we cannot download from the source website, revert to a fallback list to 
#   ensure our blocklist is not pushed empty.
# #

list_fallback_download()
{
    _fnArgLocalFile=$1
    _fnArgFile=$2
    _fnListNum=${3:-1}

    # #
    #   Define › Generic
    # #

    _fnFileTemp="${_fnArgFile}.tmp"
    _count_total_ips=0
    _count_total_subnets=0

    # #
    #   Create the file if it doesn't exist
    # #

    prinp "📄[-1] Processing fallback list #${_fnListNum}"

    if [ ! -f "${_fnFileTemp}" ]; then
        touch "${_fnFileTemp}"

        if [ -f "${_fnFileTemp}" ]; then
            ok "    📄 Created temp file ${greenl}${PWD}/${_fnFileTemp}${greym}"
        else
            error "    ⭕ Failed to create temp file ${bluel}${PWD}/${_fnFileTemp}${greym}"
            exit 1
        fi
    fi

    info "    📒 Reading fallback static block ${bluel}${PWD}/${_fnArgLocalFile}${greym}"

    # #
    #   Read stdin into temp file
    # #

    cat "${_fnArgLocalFile}" > "${_fnFileTemp}"

    # #
    #   Running sed
    # #

    info "    ✴️  Performing sed operations on ${bluel}${_fnFileTemp}${greym}"

    # #
    #   Perform sed actions on downloaded file.
    # #

    # normalize CRLF
    sed -i 's/\r$//' "${_fnFileTemp}"

    # remove right side from IPv4 ranges when format is "1.2.3.4 - 1.2.3.5"
    sed -E -i 's/^([[:space:]]*[0-9]{1,3}(\.[0-9]{1,3}){3})[[:space:]]*-[[:space:]]*[0-9]{1,3}(\.[0-9]{1,3}){3}/\1/' "${_fnFileTemp}"

    # #
    #   If we specify CFG_INCLUDE_COMMENTS=true
    #       curl -s https://gist.githubusercontent.com/BBcan177/d7105c242f17f4498f81/raw/f69be712a06e998191adfe4c86d74e8cacf08d28/MS-3 | CFG_INCLUDE_COMMENTS=true .github/scripts/bl-format.sh blocklists/3rdparty/BBcan177/ms3.ipset
    # #

    if [ "${argIncludeComments}" = "true" ]; then
        info "    ⚡ Preserving inline comments (CFG_INCLUDE_COMMENTS=true)"

    # #
    #   If we specify CFG_INCLUDE_COMMENTS=false; OR if missing
    # #

    else
        # remove inline comments (strip ' # comment' or ' ; comment' from end of lines ; collapse whitespace, trim)
        sed -i 's/[[:space:]]*[#;].*$//' "${_fnFileTemp}"

        # collapse multiple whitespace into a single space
        sed -i 's/[[:space:]]\+/ /g' "${_fnFileTemp}"
    fi

    # trim leading and trailing whitespace
    sed -i 's/^[[:space:]]*//;s/[[:space:]]*$//' "${_fnFileTemp}"

    # remove empty lines (after trimming/comment removal)
    sed -i '/^$/d' "${_fnFileTemp}"

    # #
    #   Normalize whitespace-delimited values into one IP/CIDR per line.
    # #

    if [ "${argIncludeComments}" != "true" ]; then
        info "    ✴️  Normalize input to one IP/CIDR per line in ${bluel}${_fnFileTemp}${greym}"
        normalize_ip_lines "${_fnFileTemp}"
    fi

    # #
    #   Drop malformed entries before sorting (optional trusted-input fast path)
    # #

    if [ "${argTrustedInput}" = "true" ]; then
        info "    ⚡ Trusted input mode enabled; skipping per-line IP validation"
    else
        info "    ✴️  Verify valid ip entries in ${bluel}${_fnFileTemp}${greym}. This may take some time."
        filter_valid_ip_entries "${_fnFileTemp}"
    fi

    # #
    #   Dedupe, Sort: Move from .tmp to .sort
    # #

    info "    🔃 Sorting and deduplicating fallback results"

    if [ "${argIncludeComments}" = "true" ]; then
        grep -vE '^[[:space:]]*(#|;|$)' "${_fnFileTemp}" | sort_results > "${_fnFileTemp}.sort"
    else
        sort_results < "${_fnFileTemp}" > "${_fnFileTemp}.sort"
    fi

    # #
    #   Move from .sort to .tmp
    # #

    mv "${_fnFileTemp}.sort" "${_fnFileTemp}"

    # #
    #   IPSET › Filter BOGON
    #   
    #   Removes any BOGON addresses that may be within the list.
    #       Optional
    #       Run before count_ip_stats for accurate totals
    # #

    filter_bogon_ips "${_fnFileTemp}"

    # #
    #   Calculate list statistics
    #       local only (global totals are calculated after final dedupe)
    # #

    info "    📊 Fetching statistics for clean file ${bluel}${PWD}/${_fnFileTemp}${greym}"

    count_ip_stats "${_fnFileTemp}"
    _count_total_ips=$total_ips
    _count_total_subnets=$total_subnets

    _count_total_ips=$(printf "%'d" "$_count_total_ips")                        # LOCAL add commas to thousands
    _count_total_subnets=$(printf "%'d" "$_count_total_subnets")                # LOCAL add commas to thousands

    # #
    #   Move to target
    # #

    info "    🚛 Move ${bluel}${_fnFileTemp}${greym} to ${bluel}${_fnArgFile}${greym}"

    # #
    #   Ensure dest file ends with newline before append
    # #

    if [ -s "${_fnArgFile}" ] && [ "$(tail -c1 "${_fnArgFile}")" != "" ]; then
        echo >> "${_fnArgFile}"
    fi

    cat "${_fnFileTemp}" >> "${_fnArgFile}"                                     # Copy .tmp to permanent file
    rm -f "${_fnFileTemp}"                                                      # Delete temp file

    if [ ! -f "${_fnFileTemp}" ]; then
        ok "    📄 Removed temp file ${greenl}${PWD}/${_fnFileTemp}${greym}"
    else
        error "    ⭕  Unable to delete temp file ${redl}${PWD}/${_fnFileTemp}${greym}"
    fi

    ok "    ➕ Added ${greenl}${_count_total_ips}${greym} IP addresses and ${greenl}${_count_total_subnets}${greym} subnets to ${greenl}${PWD}/${_fnArgFile}${greym}"

    # #
    #   Unset
    # #

    unset   _fnArgLocalFile _fnArgFile _fnFileTemp _fnListNum \
            _count_total_ips _count_total_subnets
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
    _fnArgFile=$1
    _fnCategory=$2
    _fnListNum=${3:-1}

    # #
    #   Define › Generic
    # #

    _fnResolvedCategory="${_fnCategory}"
    _fnTargetParent=""

    if [ -z "${_fnCategory}" ]; then
        warn "    ⚠️  Stdin did not return any valid IP entries, and no fallback category was provided"
        return 1
    fi

    if [ ! -d ".github/blocks/" ]; then
        warn "    ❌ No static blocklist folder found at ${orangel}.github/blocks/${greym}"
        return 1
    fi

    # #
    #   Resolve fallback category from target path when only leaf category is given.
    #   
    #   @example        target          blocklists/privacy/proton_vpn.ipset
    #                   category        proton_vpn
    #                   resolved        privacy/proton_vpn
    # #

    if [[ "${_fnCategory}" != */* ]] && [[ "${_fnCategory}" != *ipset ]]; then
        _fnTargetParent="$(dirname "${_fnArgFile}")"
        _fnTargetParent="${_fnTargetParent#blocklists/}"
        if [ -n "${_fnTargetParent}" ] && [ "${_fnTargetParent}" != "." ] && [ "${_fnTargetParent}" != "blocklists" ]; then
            _fnResolvedCategory="${_fnTargetParent}/${_fnCategory}"
        fi
    fi

    APP_BLOCK_TARGET=".github/blocks/${_fnResolvedCategory}/*.ipset"
    if [[ "${_fnResolvedCategory}" == *ipset ]]; then
        APP_BLOCK_TARGET=".github/blocks/${_fnResolvedCategory}"
    fi

    shopt -s nullglob
    _fnBlockFiles=( ${APP_BLOCK_TARGET} )
    shopt -u nullglob

    if [ ${#_fnBlockFiles[@]} -eq 0 ]; then
        warn "    ❌ No fallback static blocklist found at ${yellowl}${APP_BLOCK_TARGET}${greym}"
        unset _fnArgFile _fnCategory _fnListNum APP_BLOCK_TARGET _fnBlockFiles
        return 1
    fi

    info "    📦 Stdin list is empty, using fallback category ${bluel}${_fnResolvedCategory}${greym}"
    for APP_FILE_TEMP in "${_fnBlockFiles[@]}"; do
        list_fallback_download "${APP_FILE_TEMP}" "${_fnArgFile}" "${_fnListNum}"
        _fnListNum=$(( _fnListNum + 1 ))
    done

    # #
    #   Unset
    # #

    unset   _fnArgFile _fnCategory _fnResolvedCategory _fnTargetParent \
            _fnListNum APP_BLOCK_TARGET APP_FILE_TEMP _fnBlockFiles
}

# #
#   Blocklist › Main › Load
#   
#   @usage          list_main_load "${file_ipset_target}" "$i"
#   @args           _fnArgFile          Output filename to add ips to
#                   _fnListNum          Blocklist number (#1 out of #2) - visual only
# #

list_main_load()
{
    _fnArgFile=$1
    _fnListNum=${2:-1}

    # #
    #   Define › Generic
    # #

    _fnFileTemp="${_fnArgFile}.tmp"
    _count_total_ips=0
    _count_total_subnets=0

    # #
    #   Create the file if it doesn't exist
    # #

    prinp "📄[-1] Processing list #${_fnListNum}"

    if [ ! -f "${_fnFileTemp}" ]; then
        touch "${_fnFileTemp}"

        if [ -f "${_fnFileTemp}" ]; then
            ok "    📄 Created temp file ${greenl}${PWD}/${_fnFileTemp}${greym}"
        else
            error "    ⭕ Failed to create temp file ${bluel}${PWD}/${_fnFileTemp}${greym}"
            exit 1
        fi
    fi

    _fnPageStart="${MIP_PAGE_START:-1}"
    case "${_fnPageStart}" in
        ''|*[!0-9]*) _fnPageStart=1 ;;
    esac
    [ "${_fnPageStart}" -lt 1 ] && _fnPageStart=1

    # #
    #   Loop through range of pages and save raw MIP HTML first.
    #   Parsing is done in a separate step so fetch-loop logs are not swallowed by the extraction pipeline.
    # #

    _fnRawTemp="${_fnFileTemp}.raw"
    : > "${_fnRawTemp}"
    _fnFirstPageUrl="$(expand_mip_url "${argUrl}" "${_fnPageStart}")"
    info "    🌐 Fetching MIP page ${yellowl}${_fnPageStart}${greym}: ${bluel}${_fnFirstPageUrl}${greym}"
    _fnFirstPageContent="$(fetch_page "${_fnFirstPageUrl}")"
    _fnFetchStatus=$?
    if [ "${_fnFetchStatus}" -ne 0 ]; then
        warn "    ⚠️  Unable to fetch first MIP page (status ${yellowl}${_fnFetchStatus}${greym}); using fallback"
        rm -f "${_fnRawTemp}"
        unset   _fnArgFile _fnFileTemp _fnListNum _count_total_ips _count_total_subnets \
                _fnPageStart _fnRawTemp _fnFirstPageUrl _fnFirstPageContent _fnFetchStatus
        return 1
    fi
    printf '%s\n' "${_fnFirstPageContent}" >> "${_fnRawTemp}"

    _fnDetectedPageEnd=$(printf '%s\n' "${_fnFirstPageContent}" | grep -oP '(?<=href="#)[0-9]+' | sort -n | tail -1)
    case "${_fnDetectedPageEnd}" in
        ''|*[!0-9]*) _fnDetectedPageEnd="${_fnPageStart}" ;;
    esac

    if [ -n "${MIP_PAGE_END:-}" ]; then
        _fnPageEnd="${MIP_PAGE_END}"
    else
        _fnPageEnd="${_fnDetectedPageEnd}"
    fi

    case "${_fnPageEnd}" in
        ''|*[!0-9]*) _fnPageEnd="${_fnDetectedPageEnd}" ;;
    esac
    [ "${_fnPageEnd}" -lt "${_fnPageStart}" ] && _fnPageEnd="${_fnPageStart}"

    info "    🌎 Fetching MIP pages ${yellowl}${_fnPageStart}${greym}-${yellowl}${_fnPageEnd}${greym} using ${bluel}${argUrl}${greym}"

    _fnPageNum=$(( _fnPageStart + 1 ))
    while [ "${_fnPageNum}" -le "${_fnPageEnd}" ]; do
        _fnPageUrl="$(expand_mip_url "${argUrl}" "${_fnPageNum}")"

        info "    🌐 Fetching MIP page ${yellowl}${_fnPageNum}${greym}: ${bluel}${_fnPageUrl}${greym}"

        _fnPageContent="$(fetch_page "${_fnPageUrl}")"
        _fnFetchStatus=$?
        if [ "${_fnFetchStatus}" -ne 0 ]; then
            warn "    ⚠️  Unable to fetch MIP page ${yellowl}${_fnPageNum}${greym} (status ${yellowl}${_fnFetchStatus}${greym}); using fallback"
            rm -f "${_fnRawTemp}"
            unset   _fnArgFile _fnFileTemp _fnListNum _count_total_ips _count_total_subnets \
                    _fnPageStart _fnDetectedPageEnd _fnPageEnd _fnPageNum _fnPageUrl _fnRawTemp \
                    _fnFirstPageUrl _fnFirstPageContent _fnPageContent _fnFetchStatus
            return 1
        fi
        [ -n "${_fnPageContent}" ] && printf '%s\n' "${_fnPageContent}" >> "${_fnRawTemp}"

        _fnPageNum=$(( _fnPageNum + 1 ))
    done

    # #
    #   Extract IPv4 addresses from the MIP HTML blocks.
    #   Supports both single and double quote attributes in class='sval' / class="sval".
    # #

    grep -oP "<div class=['\"]sval['\"]>\s*\K(?:\d{1,3}\.){3}\d{1,3}(?=\s*</div>)" "${_fnRawTemp}" \
        | sort -u > "${_fnFileTemp}"
    rm -f "${_fnRawTemp}"

    if [ ! -s "${_fnFileTemp}" ]; then
        warn "    ⚠️  No IP entries were extracted from MIP pages"
    fi

    # #
    #   Perform sed actions on downloaded file.
    # #

    # normalize CRLF
    sed -i 's/\r$//' "${_fnFileTemp}"

    # remove right side from IPv4 ranges when format is "1.2.3.4 - 1.2.3.5"
    sed -E -i 's/^([[:space:]]*[0-9]{1,3}(\.[0-9]{1,3}){3})[[:space:]]*-[[:space:]]*[0-9]{1,3}(\.[0-9]{1,3}){3}/\1/' "${_fnFileTemp}"

    # #
    #   If we specify CFG_INCLUDE_COMMENTS=true
    #       curl -s https://gist.githubusercontent.com/BBcan177/d7105c242f17f4498f81/raw/f69be712a06e998191adfe4c86d74e8cacf08d28/MS-3 | CFG_INCLUDE_COMMENTS=true .github/scripts/bl-format.sh blocklists/3rdparty/BBcan177/ms3.ipset
    # #

    if [ "${argIncludeComments}" = "true" ]; then
        info "    ⚡ Preserving inline comments (CFG_INCLUDE_COMMENTS=true)"

    # #
    #   If we specify CFG_INCLUDE_COMMENTS=false; OR if missing
    # #

    else
        # remove inline comments (strip ' # comment' or ' ; comment' from end of lines ; collapse whitespace, trim)
        sed -i 's/[[:space:]]*[#;].*$//' "${_fnFileTemp}"

        # collapse multiple whitespace into a single space
        sed -i 's/[[:space:]]\+/ /g' "${_fnFileTemp}"
    fi

    # trim leading and trailing whitespace
    sed -i 's/^[[:space:]]*//;s/[[:space:]]*$//' "${_fnFileTemp}"

    # remove empty lines (after trimming/comment removal)
    sed -i '/^$/d' "${_fnFileTemp}"

    # #
    #   Normalize whitespace-delimited values into one IP/CIDR per line.
    # #

    if [ "${argIncludeComments}" != "true" ]; then
        info "    ✴️  Normalize input to one IP/CIDR per line in ${bluel}${_fnFileTemp}${greym}"
        normalize_ip_lines "${_fnFileTemp}"
    fi

    # #
    #   apply optional grep exclude filter
    # #

    info "    ✴️  Apply grep exclude filters on ${bluel}${_fnFileTemp}${greym}"

    if [ -n "${argFilterGrep}" ]; then
        if grep -viE "${argFilterGrep}" "${_fnFileTemp}" > "${_fnFileTemp}.grep" 2>/dev/null; then
            mv "${_fnFileTemp}.grep" "${_fnFileTemp}"
        else
            rm -f "${_fnFileTemp}.grep"
        fi
    fi

    # #
    #   Drop malformed entries before sorting (optional trusted-input fast path)
    # #

    if [ "${argTrustedInput}" = "true" ]; then
        info "    ⚡ Trusted input mode enabled; skipping per-line IP validation"
    else
        info "    ✴️  Verify valid ip entries in ${bluel}${_fnFileTemp}${greym}. This may take some time."
        filter_valid_ip_entries "${_fnFileTemp}"
    fi

    # #
    #   Dedupe, Sort: Move from .tmp to .sort
    # #

    info "    🔃 Sorting and deduplicating results"

    if [ "${argIncludeComments}" = "true" ]; then
        grep -vE '^[[:space:]]*(#|;|$)' "${_fnFileTemp}" | sort_results > "${_fnFileTemp}.sort"
    else
        sort_results < "${_fnFileTemp}" > "${_fnFileTemp}.sort"
    fi

    # #
    #   Move from .sort to .tmp
    # #

    mv "${_fnFileTemp}.sort" "${_fnFileTemp}"

    # #
    #   IPSET › Dedup Contained CIDRs
    #   
    #   Combine CIDRs to save on number of lines:
    #       Remove CIDRs fully contained within a larger CIDR.
    #       Run before count_ip_stats for accurate totals.
    # #

    dedup_cidr "${_fnFileTemp}"

    # #
    #   IPSET › Filter BOGON
    #   
    #   Removes any BOGON addresses that may be within the list.
    #       Optional
    #       Run before count_ip_stats for accurate totals
    # #

    filter_bogon_ips "${_fnFileTemp}"

    # #
    #   Calculate list statistics
    #       local only (global totals are calculated after final dedupe)
    # #

    info "    📊 Fetching statistics for clean file ${bluel}${PWD}/${_fnFileTemp}${greym}"

    count_ip_stats "${_fnFileTemp}"
    _count_total_ips=$total_ips
    _count_total_subnets=$total_subnets

    _count_total_ips=$(printf "%'d" "$_count_total_ips")                        # LOCAL add commas to thousands
    _count_total_subnets=$(printf "%'d" "$_count_total_subnets")                # LOCAL add commas to thousands

    # #
    #   Move to target
    # #

    info "    🚛 Move ${bluel}${_fnFileTemp}${greym} to ${bluel}${_fnArgFile}${greym}"

    # #
    #   Ensure dest file ends with newline before append
    # #

    if [ -s "${_fnArgFile}" ] && [ "$(tail -c1 "${_fnArgFile}")" != "" ]; then
        echo >> "${_fnArgFile}"
    fi

    cat "${_fnFileTemp}" >> "${_fnArgFile}"                                     # Copy .tmp to permanent file
    rm -f "${_fnFileTemp}"                                                      # Delete temp file

    if [ ! -f "${_fnFileTemp}" ]; then
        ok "    📄 Removed temp file ${greenl}${PWD}/${_fnFileTemp}${greym}"
    else
        error "    ⭕  Unable to delete temp file ${redl}${PWD}/${_fnFileTemp}${greym}"
    fi

    ok "    ➕ Added ${greenl}${_count_total_ips}${greym} IP addresses and ${greenl}${_count_total_subnets}${greym} subnets to ${greenl}${PWD}/${_fnArgFile}${greym}"

    # #
    #   Unset
    # #

    unset   _fnArgFile _fnFileTemp _fnListNum _count_total_ips _count_total_subnets \
            _fnPageStart _fnDetectedPageEnd _fnPageEnd _fnPageNum _fnPageUrl _fnRawTemp \
            _fnFirstPageUrl _fnFirstPageContent _fnPageContent _fnFetchStatus
}

# #
#   Create Temp Folder
# #

mkdir -p "${app_dir_github}/${folder_target_temp}"
if [ -d "${app_dir_github}/${folder_target_temp}" ]; then
    ok "    📂 Created TEMPDIR ${greenl}${app_dir_github}/${folder_target_temp}"
else
    error "    ❌ Failed to create ${redl}${app_dir_github}/${folder_target_temp}"
fi

# #
#   Define › Template
# #

templ_now="$(date -u '+%a %b %d %T %Z %Y')"                                     # Get current date in utc format
templ_url="https://raw.githubusercontent.com/${app_repo}/${app_repo_branch}/${file_ipset_target}"
templ_path="${file_ipset_target#blocklists/}"                                   # privacy/twitter_x.ipset
templ_path="${templ_path%.ipset}"                                               # remove extension
templ_id="${templ_path//\//_}"                                                  # privacy_twitter_x
templ_id="${templ_id//[^[:alnum:]]/_}"                                          # sanitize
templ_id="${templ_id}_ipset"                                                    # match your existing format
templ_uuid="$(uuidgen -m -N "${templ_id}" -n @url)"                             # stable release ID
templ_run_uuid="$(uuidgen)"                                                     # UNIQUE per execution
templ_tmp_prefix="${app_dir_github}/${folder_target_temp}/${templ_run_uuid}"
templ_curl_opts=(-sSL -A "$app_agent")                                          # cUrl command

# #
#   Template › External Sources
# #

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
[ -z "$templ_exp"  ] || [[ "$templ_exp"  == *"404: Not Found"* ]] && templ_exp="4 hours"
[ -z "$templ_src"  ] || [[ "$templ_src"  == *"404: Not Found"* ]] && templ_src="https://blocklist.configserver.dev/"

# #
#   Output › Header
# #

echo
prinp "📄[-1] ${file_ipset_target}" \
"${greym}File: 	    ${greyd}.............${yellowl} ${file_ipset_target}${greyd} \
${greyd}\n${greym}Id: 	    ${greyd}...............${yellowl} ${templ_id}${greyd} \
${greyd}\n${greym}UUID:	        ${greyd}.............${yellowl} ${templ_uuid}${greyd} \
${greyd}\n${greym}Category:	        ${greyd}.........${yellowl} ${templ_cat}${greyd} \
${greyd}\n${greym}Script:	       ${greyd}...........${yellowl} ${app_file_this}${greyd} \
${greyd}\n${greym}Source:	         ${greyd}...........${yellowl} ${templ_src}${greyd}"

# #
#   Start
# #

info "    ⭐ Starting script ${bluel}${app_file_this}${greym}"

if [ "${argTrustedInput}" = "true" ]; then
    info "    ⚡ Fast mode: trusted input enabled"
fi

if [ "${argSkipBogonFilter}" = "true" ]; then
    info "    ⚡ Fast mode: bogon filtering disabled"
fi

if [ "${argSkipCidrDedup}" = "true" ]; then
    info "    ⚡ Fast mode: overlapping CIDR dedupe disabled"
fi

if [ "${argIncludeComments}" = "true" ]; then
    info "    ⚡ Fast mode: inline comments preserved"
fi

# #
#   Config Sort Options
# #

configure_sort_options

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
#   Download lists
# #

i=1
list_main_load "${file_ipset_target}" "$i"

# #
#   Fallback List › Load
#   
#   If IPs cannot be obtained from the URL source; use a local static file to
#   populate the blocklist.
#   
#   ./.github/scripts/bl-mip.sh blocklists/privacy/privacy_anthropic.ipset 'https://myip.ms/browse/comp_ip/${i}/ownerID/1603724/ownerID_A' privacy/anthropic
# #

if ! has_valid_ip_entries "${file_ipset_target}"; then
    did_load_fallback="true"
    warn "    ⚠️  Using local IP block fallback ${yellowl}${argFallbackBlock}${greym} for ${yellowl}${file_ipset_target}${greym}"
    list_fallback_load "${file_ipset_target}" "${argFallbackBlock}" "2"
fi

# #
#   Sort
#       Remove downloaded comment/blank lines.
#       Sort/dedupe IPv4 and IPv6 separately.
#       Move sorted text over to permanent file.
#       Delete temp sort file.
# #

if [ -f "${file_ipset_target}" ]; then
    if [ "${did_load_fallback}" = "true" ]; then
        info "    🧹 Sorting and removing duplicate IP entries from ${bluel}${PWD}/${file_ipset_target}${greym}"
        if [ "${argIncludeComments}" = "true" ]; then
            grep -vE '^[[:space:]]*(#|;|$)' "${file_ipset_target}" | sort_results > "${file_ipset_target}.sort"
        else
            sort_results < "${file_ipset_target}" > "${file_ipset_target}.sort"
        fi
        > "${file_ipset_target}"
        cat "${file_ipset_target}.sort" >> "${file_ipset_target}"
        rm "${file_ipset_target}.sort"
        ok "    ✅ Duplicate IPs removed"
    else
        info "    ⚡ Skipping final global sort/dedupe (single source already normalized)"
    fi
fi

# #
#   IPSET › Dedup Contained CIDRs (final pass across all IPs)
# #

if [ -f "${file_ipset_target}" ] && [ -s "${file_ipset_target}" ]; then
    dedup_cidr "${file_ipset_target}"
fi

# #
#   Final Counts (from final cleaned + deduped file)
# #

if [ -f "${file_ipset_target}" ]; then
    count_ip_stats "${file_ipset_target}"
    total_ips=$total_ips
    total_subnets=$total_subnets

    total_lines=$(wc -l < "${file_ipset_target}")                               # Count ip lines
    total_lines=$(printf "%'d" "$total_lines")                                  # GLOBAL add commas to thousands
    total_subnets=$(printf "%'d" "$total_subnets")                              # GLOBAL add commas to thousands
    total_ips=$(printf "%'d" "$total_ips")                                      # GLOBAL add commas to thousands
fi

# #
#   Stdout
# #

if [ "${argStdout}" = "true" ]; then
    cat "${file_ipset_target}"
    rm -f "${file_ipset_target}"
    exit 0
fi

# #
#   Template › Header
#   
#   0a      place at top of file
# #

ed -s "${file_ipset_target}" <<END_ED
0a
# #
#   🧱 Firewall Blocklist - ${file_ipset_target}
#
#   @blocklist      ${templ_url}
#   @source         ${templ_src}
#   @id             ${templ_id}
#   @uuid           ${templ_uuid}
#   @updated        ${templ_now}
#   @entries        ${total_ips} ips
#                   ${total_subnets} subnets
#                   ${total_lines} lines
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
#   Cleanup
# #

gcc

# #
#   Finished
#       Capture end time
#       Calculate elapsed time
#       Calculate days, hours, etc.
#       Output to console
# #

time_elapsed $(( $( date +%s ) - time_start ))

# #
#   Output › Footer
# #

prinp "🎌[41] Finished!   ${fuchsiad}IPs: ${yellowl}${total_ips}${fuchsiad}   Subnets: ${yellowl}${total_subnets}${greyd}${fuchsiad}   Duration: ${yellowl}${D} days ${H} hrs ${M} mins ${S} secs${greyd}" false