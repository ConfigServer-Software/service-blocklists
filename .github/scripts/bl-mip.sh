#!/bin/bash

# #
#   @script             Blocklist › Mip
#   @for                https://github.com/ConfigServer-Software/service-blocklists
#   @workflow           blocklist-generate.yml
#   @type               Bash script
#   
#   @summary            Fetches a list of IP addresses from the MIP service online.
#                       If a refreshed list of IPs cannot be grabbed, fallback to 
#                       an existing list within the 'blocks' folder.
#   
#   @execute            Run with the following commands:
#                           .github/scripts/bl-mip.sh blocklists/privacy/privacy_anthropic.ipset '${{ vars.BL_PRIVACY_MIP_ANTHROPIC_SRC }}' privacy/anthropic
#   
#   @workflow           # Privacy › Anthropic
#                       chmod +x ".github/scripts/bl-mip.sh"
#                       run_mip_anthropic=".github/scripts/bl-mip.sh blocklists/privacy/privacy_anthropic.ipset '${{ vars.BL_PRIVACY_MIP_ANTHROPIC_SRC }}' privacy/anthropic"
#                       eval "./$run_mip_anthropic"
#   
#   @usage              .github/scripts/bl-mip.sh
#                           <argFileSaveto>     str         required            Ipset save path
#                           <argSourceUrl>      str         required            MIP Source URL
#                           <argFallbackBlock>  str         required            Fallback category
#   
#   @structure          📁 .github
#                           📁 scripts
#                               📄 bl-mip.sh
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
#   @param  argFileSaveto       str         File to save IP addresses into
#           argSourceUrl        str         Online ip source
#           argFallbackBlock    str         Fallback block folder
# #

argFileSaveto=$1
argSourceUrl=$2
argFallbackBlock=$3

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
app_repo="configserver-software/service-blocklists"                             # repository
app_repo_branch="main"                                                          # repository branch
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
#   Verify › Arguments
# #

if [ -z "${argFileSaveto}" ]; then
    error "    ⭕  No target file specified ${yellowd}${app_file_this}${greym}; aborting${end}"
    exit 0
fi

if [ -z "${argSourceUrl}" ]; then
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
fi

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

    mv "${_fnBogonTemp}" "${_fnBogonFile}"

    _fnBogonAfter=$(wc -l < "${_fnBogonFile}")

    ok "    🚫 Removed ${greenl}${_fnBogonRemoved}${greym} bogon entries from ${bluel}${PWD}/${_fnBogonFile}${greym}"

    # #
    #   Unset
    # #

    unset   _fnBogonFile _fnBogonTemp _fnBogonLine _fnBogonBase _fnBogonBefore _fnBogonAfter _fnBogonRemoved _fnBogonIp
}

# #
#   Func › Download List
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
#   Download mip blocklist
# #

download_list()
{
    _fnArgFile=$1
    _fnListNum=$2
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
    _fnFirstPageUrl="$(expand_mip_url "${argSourceUrl}" "${_fnPageStart}")"
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

    info "    🌎 Fetching MIP pages ${yellowl}${_fnPageStart}${greym}-${yellowl}${_fnPageEnd}${greym} using ${bluel}${argSourceUrl}${greym}"

    _fnPageNum=$(( _fnPageStart + 1 ))
    while [ "${_fnPageNum}" -le "${_fnPageEnd}" ]; do
        _fnPageUrl="$(expand_mip_url "${argSourceUrl}" "${_fnPageNum}")"

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
    #   De-dupe, Sort: Move from .tmp to .sort
    # #

    info "    🔃 Sorting and deduplicating results"
    grep -vE '^[[:space:]]*(#|;|$)' "${_fnFileTemp}" | sort_results > "${_fnFileTemp}.sort"

    # #
    #   Move from .sort to .tmp
    # #

    mv "${_fnFileTemp}.sort" "${_fnFileTemp}"

    # #
    #   IPSET › Filter BOGON
    #       - Optional
    #       - Run before count_ip_stats for accurate totals
    # #

    filter_bogon_ips "${_fnFileTemp}"

    # #
    #   Calculate list statistics
    #       - local only (global totals are calculated after final dedupe)
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
#   Download Static Fallback List
#   
#   If we cannot download from the source website, revert to a fallback list to 
#   ensure our blocklist is not pushed empty.
# #

download_list_fallback()
{
    _fnArgLocalFile=$1
    _fnArgFile=$2
    _fnListNum=$3
    _fnFileTemp="${_fnArgFile}.tmp"
    _count_total_ips=0
    _count_total_subnets=0

    prinp "📄[-1] Using fallback list"

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
    cat "${_fnArgLocalFile}" > "${_fnFileTemp}"

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

    info "    🔃 Sorting and deduplicating fallback results"
    grep -vE '^[[:space:]]*(#|;|$)' "${_fnFileTemp}" | sort_results > "${_fnFileTemp}.sort"

    # #
    #   Move from .sort to .tmp
    # #

    mv "${_fnFileTemp}.sort" "${_fnFileTemp}"

    # #
    #   IPSET › Filter BOGON
    #       - Optional
    #       - Run before count_ip_stats for accurate totals
    # #

    filter_bogon_ips "${_fnFileTemp}"

    # #
    #   Calculate list statistics
    #       - local only (global totals are calculated after final dedupe)
    # #

    info "    📊 Fetching statistics for clean file ${bluel}${PWD}/${_fnFileTemp}${greym}"

    count_ip_stats "${_fnFileTemp}"
    _count_total_ips=$total_ips
    _count_total_subnets=$total_subnets

    _count_total_ips=$(printf "%'d" "$_count_total_ips")
    _count_total_subnets=$(printf "%'d" "$_count_total_subnets")

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

    unset   _fnArgLocalFile _fnArgFile _fnListNum _fnFileTemp _count_total_ips _count_total_subnets
}

# #
#   Check if file contains valid IP entries
# #

has_valid_ip_entries()
{
    _fnArgFile=$1

    if [ ! -f "${_fnArgFile}" ]; then
        return 1
    fi

    if grep -Eq "^(${regex_ipv4}|${regex_ipv4_cidr}|${regex_ipv6}|${regex_ipv6_cidr})$" "${_fnArgFile}"; then
        return 0
    fi

    return 1
}

# #
#   Load fallback static blocks from .github/blocks/<category>
# #

load_list_fallback()
{
    _fnArgFile=$1
    _fnCategory=$2
    _fnListNum=$3

    if [ -z "${_fnCategory}" ]; then
        warn "    ⚠️  Stdin did not return any valid IP entries, and no fallback category was provided"
        return 1
    fi

    if [ ! -d ".github/blocks/" ]; then
        warn "    ❌ No static blocklist folder found at ${orangel}.github/blocks/${greym}"
        return 1
    fi

    APP_BLOCK_TARGET=".github/blocks/${_fnCategory}/*.ipset"
    if [[ "${_fnCategory}" == *ipset ]]; then
        APP_BLOCK_TARGET=".github/blocks/${_fnCategory}"
    fi

    info "    📁 Fallback lookup target ${yellowl}${APP_BLOCK_TARGET}${greym}"

    shopt -s nullglob
    _fnBlockFiles=( ${APP_BLOCK_TARGET} )
    shopt -u nullglob

    if [ ${#_fnBlockFiles[@]} -eq 0 ]; then
        warn "    ❌ No fallback static blocklist found at ${yellowl}${APP_BLOCK_TARGET}${greym}"
        unset _fnArgFile _fnCategory _fnListNum APP_BLOCK_TARGET _fnBlockFiles
        return 1
    fi

    info "    📦 MIP list is empty, using fallback category ${bluel}${_fnCategory}${greym}"
    for APP_FILE_TEMP in "${_fnBlockFiles[@]}"; do
        download_list_fallback "${APP_FILE_TEMP}" "${_fnArgFile}" "${_fnListNum}"
        _fnListNum=$(( _fnListNum + 1 ))
    done

    # #
    #   Unset
    # #

    unset   _fnArgFile _fnCategory _fnListNum APP_BLOCK_TARGET APP_FILE_TEMP _fnBlockFiles
}

# #
#   Define › App
# #

file_ipset_temp="${argFileSaveto}.tmp"                                          # Temp file when building ipset list
file_ipset_target="${argFileSaveto}"                                            # Perm file when building ipset list

# #
#   Define › Template
# #

templ_now="$(date -u)"                                                          # Get current date in utc format
templ_id=$(basename -- "${file_ipset_target}")                                  # Ipset id, get base filename
templ_id="${templ_id//[^[:alnum:]]/_}"                                          # Ipset id, only allow alphanum and underscore, /description/* and /category/* files must match this value
templ_uuid="$(uuidgen -m -N "${templ_id}" -n @url)"                             # UUID associated to each release
templ_curl_opts=(-sSL -A "$app_agent")                                          # cUrl command

# #
#   Define › Template › External Sources
# #

curl "${templ_curl_opts[@]}" "https://raw.githubusercontent.com/${app_repo}/${app_repo_branch}/.github/descriptions/${templ_id}.txt" > desc.txt &
curl "${templ_curl_opts[@]}" "https://raw.githubusercontent.com/${app_repo}/${app_repo_branch}/.github/categories/${templ_id}.txt" > cat.txt &
curl "${templ_curl_opts[@]}" "https://raw.githubusercontent.com/${app_repo}/${app_repo_branch}/.github/expires/${templ_id}.txt" > exp.txt &
curl "${templ_curl_opts[@]}" "https://raw.githubusercontent.com/${app_repo}/${app_repo_branch}/.github/url-source/${templ_id}.txt" > src.txt &
wait
templ_desc=$(<desc.txt)
templ_cat=$(<cat.txt)
templ_exp=$(<exp.txt)
templ_url_service=$(<src.txt)
rm -f desc.txt cat.txt exp.txt src.txt

# #
#   Define › Template › Default Values
# #

case "$templ_desc" in *"404: Not Found"*) templ_desc="#   No description provided";; esac
case "$templ_cat" in *"404: Not Found"*) templ_cat="Uncategorized";; esac
case "$templ_exp" in *"404: Not Found"*) templ_exp="6 hours";; esac
case "$templ_url_service" in *"404: Not Found"*) templ_url_service="None";; esac

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
${greyd}\n${greym}Service:	        ${greyd}..........${yellowl} ${templ_url_service}${greyd}"

# #
#   Start
# #

info "    ⭐ Starting script ${bluel}${app_file_this}${greym}"

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
download_list "${file_ipset_target}" "$i"

if ! has_valid_ip_entries "${file_ipset_target}"; then
     warn "    ⚠️  Using local IP block fallback ${yellowl}${argFallbackBlock}${greym} for ${yellowl}${file_ipset_target}${greym}"
    load_list_fallback "${file_ipset_target}" "${argFallbackBlock}" "2"
fi

# #
#   Sort
#       - Remove downloaded comment/blank lines
#       - Sort/dedupe IPv4 and IPv6 separately
#       - Move sorted text over to permanent file
#       - Delete temp sort file
# #

if [ -f "${file_ipset_target}" ]; then
    info "    🧹 Sorting and removing duplicate IP entries from ${bluel}${PWD}/${file_ipset_target}${greym}"
    grep -vE '^[[:space:]]*(#|;|$)' "${file_ipset_target}" | sort_results > "${file_ipset_target}.sort"
    > "${file_ipset_target}"
    cat "${file_ipset_target}.sort" >> "${file_ipset_target}"
    rm "${file_ipset_target}.sort"
    ok "    ✅ Duplicate IPs removed"
fi

# #
#   Final Counts (from final cleaned + deduped file)
# #

if [ -f "${file_ipset_target}" ]; then
    count_ip_stats "${file_ipset_target}"
    total_ips=$total_ips
    total_subnets=$total_subnets

    total_lines=$(wc -l < "${file_ipset_target}")                               # count ip lines
    total_lines=$(printf "%'d" "$total_lines")                                  # GLOBAL add commas to thousands
    total_subnets=$(printf "%'d" "$total_subnets")                              # GLOBAL add commas to thousands
    total_ips=$(printf "%'d" "$total_ips")                                      # GLOBAL add commas to thousands
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
#   @repo           https://raw.githubusercontent.com/${app_repo}/${app_repo_branch}/${file_ipset_target}
#   @service        ${templ_url_service}
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

# #
#   Output › Footer
# #

prinp "🎌[41] Finished!   ${fuchsiad}IPs: ${yellowl}${total_ips}${fuchsiad}   Subnets: ${yellowl}${total_subnets}${greyd}${fuchsiad}   Duration: ${yellowl}${D} days ${H} hrs ${M} mins ${S} secs${greyd}" false
