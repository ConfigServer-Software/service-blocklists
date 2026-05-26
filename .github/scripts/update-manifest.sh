#!/bin/bash

# #
#   @script             Blocklist › Helper › Manifest Updater
#   @repo               https://github.com/ConfigServerApps/service-blocklists
#   @workflow           blocklist-generate.yml
#   @type               bash script
#   @summary            Updates the blocklist service manifest.json
#   @path               .github/scripts/update-manifest.sh
#   @params             .github/scripts/update-manifest.sh
#                           <argFileManifest>   str     req     Target manifest.json to modify
#   @commands           1.  ./.github/scripts/update-manifest.sh manifest.json
#   @structure          📁 .github
#                           📁 scripts
#                               📄 update-manifest.sh
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

app_file_this=$(basename "$0")                                                  # update-manifest.sh    (with ext)
app_file_bin="${app_file_this%.*}"                                              # update-manifest       (without ext)

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
#   @param  argFileManifest     str         Manifest file to update.
# #

argFileManifest=$1

# #
#   Define › App
# #

file_manifest_temp="${argFileManifest}.tmp"                                     # Temp file when building manifest
file_manifest_target="${argFileManifest}"                                       # Perm file when building manifest
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

app_name="Blocklist › Update › Manifest"                                        # name of app
app_desc="Updates the repository manifest.json file"                            # desc
app_ver="1.4.0.0"                                                               # current script version
app_type="Bash Helper"                                                          # type of script
app_repo="ConfigServerApps/service-blocklists"                                  # repository
app_repo_branch="main"                                                          # repository branch
app_repo_curl_storage="https://raw.githubusercontent.com/${app_repo}/${app_repo_branch}/.github"
app_agent="Mozilla/5.0 (Windows NT 10.0; WOW64) "\
"AppleWebKit/537.36 (KHTML, like Gecko) "\
"Chrome/51.0.2704.103 Safari/537.36 "\
"ConfigServer Security (hello@configserver.dev)"                                # user agent used with curl

# #
#   Define › Time
# #

time_start=$( date +%s )                                                        # record start time of script
SECONDS=0                                                                       # set seconds count for beginning of script

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

if [ -z "${argFileManifest}" ]; then
    error "    ⭕  No target manifest file specified ${yellowd}${app_file_this}${greym}; aborting${end}"
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
#   Define › DateTime
# #

export DATE=$(date -u '+%m%d%y')
export DATE_TS=$(date -u +%s)
export YEAR=$(date -u +'%Y')
export TIME=$(date -u '+%H:%M:%S')
export NOW=$(date -u '+%m.%d.%Y %H:%M:%S')

# #
#   Define › Template
# #

templ_now="$(date -u '+%a %b %d %T %Z %Y')"                                     # Get current date in utc format
templ_url="https://raw.githubusercontent.com/${app_repo}/${app_repo_branch}/${file_manifest_target}"
templ_path="${file_manifest_target#blocklists/}"                                # privacy/twitter_x.ipset
templ_path="${templ_path%.ipset}"                                               # remove extension
templ_id="${templ_path//\//_}"                                                  # privacy_twitter_x
templ_id="${templ_id//[^[:alnum:]@]/_}"                                         # sanitize; special characters to underscore.
templ_id="${templ_id}_ipset"                                                    # match your existing format
templ_uuid="$(uuidgen -m -N "${templ_id}" -n @url)"                             # stable release ID
templ_curl_opts=(-sSL -A "$app_agent")                                          # cUrl command

# #
#   Output › Header
# #

echo
prinp "📄[-1] Manifest Updater" \
"${greym}Script:	        ${greyd}...........${yellowl} ${app_file_this}${greyd} \
${greyd}\n${greym}Category:	        ${greyd}.........${yellowl} ${app_type}${greyd} \
${greyd}\n${greym}UUID:	        ${greyd}.............${yellowl} ${templ_uuid}${greyd} \
${greyd}\n${greym}Output:	       ${greyd}...........${yellowl} ${file_manifest_target}${greyd} \
${greyd}\n${greym}Source:	         ${greyd}...........${yellowl} ${templ_url}${greyd}"

# #
#   Manifest › Validate Target File Exists
# #

if [ ! -f "${file_manifest_target}" ] || [ ! -r "${file_manifest_target}" ]; then
    error "    ⭕ Manifest file missing or not readable ${redd}${file_manifest_target}${end}"
    exit 1
fi

# #
#   Manifest › Make Changes
#   
#   This script opens the specified manifest.json file and modifies json values
#   such as the time that the blocklists were updated. 
# #

info "    📄 Updating manifest file ${bluel}${PWD}/${file_manifest_target}${greym}"

if jq \
    --arg now "${NOW}" \
    --arg ts "${DATE_TS}" \
    '
        .last_update = $now |
        .last_update_ts = $ts
    ' \
    "${file_manifest_target}" > "${file_manifest_temp}"
then

    mv "${file_manifest_temp}" "${file_manifest_target}"

    # #
    #   Validate Changes
    # #

    manifest_now=$( jq -r '.last_update' "${file_manifest_target}" )
    manifest_ts=$( jq -r '.last_update_ts' "${file_manifest_target}" )

    # #
    #   manifest.json successfully modified
    # #

    if [[ "${manifest_now}" == "${NOW}" && "${manifest_ts}" == "${DATE_TS}" ]]; then

        ok "    📄 Successfully updated manifest file ${greenl}${PWD}/${file_manifest_target}${greym}"

        label "        ${bluel}\"last_update\": \"${manifest_now}\"${greym}"
        label "        ${bluel}\"last_update_ts\": \"${manifest_ts}\"${greym}"
    else
        error "    ⭕ Could not verify manifest update ${redd}${file_manifest_target}${end}"
    fi
else
    # #
    #   Could not update manifest.json
    # #

    rm -f "${file_manifest_temp}"

    error "    ⭕ Could not update manifest file ${redd}${file_manifest_target}${end}"
fi

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

prinp "🎌[41] Finished!   ${fuchsiad}Duration: ${yellowl}${D} days ${H} hrs ${M} mins ${S} secs${greyd}" false