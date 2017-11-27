#!/bin/bash
set -e

TARGET_LIST_PATH="./target.list"
HISTORY_INFO_PATH="./history.list"
MAIL_LIST_PATH="./mail.list"

function print_usage() {
    echo "Usage: "
    echo "  ./tracker"
}

function get_target_list() {
    target_list_path=$1
    cat ${target_list_path}
}

function get_target_repo() {
    line=$1
    echo $line | awk -F '[:]' '{print $1}'
}

function get_target_current_release() {
    line=$1
    echo $line | awk -F '[:]' '{print $2}'
}

function renew_target_list_file() {
    repo=$1
    current_release=$2
    latest_release=$3

    re=`echo ${repo} | awk -F '[/]' '{print $1}'`
    po=`echo ${repo} | awk -F '[/]' '{print $2}'`

    sed -ie "s/${re}\/${po}:${current_release}/${re}\/${po}:${latest_release}/g" ${TARGET_LIST_PATH}
}

# osx: `launchctl start org.postfix.master`
function send_email() {
    email_title=$1
    email_content=$2
    echo ${email_title}
    echo ${email_content}
    for to_user in `cat ${MAIL_LIST_PATH}`; do
        echo ${email_content} | mail -s "${email_title}" ${to_user}
    done
}

function main() {
    TARGET_LIST=`get_target_list ${TARGET_LIST_PATH}`
    for line in $TARGET_LIST; do
        repo=`get_target_repo ${line}`
        current_release=`get_target_current_release ${line}`

        release_page_url="https://github.com/${repo}/releases"
        rex="/${repo}/releases/tag/"

        latest_release=`curl -s ${release_page_url} | grep ${rex} | head -n 1 | awk -F '[/"]' '{print $7}'`

        if [ $latest_release != $current_release ]; then
            email_title="githubReleaseTracker: ${repo} release ${current_release} to ${latest_release}"
            email_content="Damn it. ${repo} release ${current_release} to ${latest_release}. release_page_url: ${release_page_url}"

            send_email "${email_title}" "${email_content}" >> ${HISTORY_INFO_PATH}
            renew_target_list_file ${repo} ${current_release} ${latest_release}

            if [[ $? -eq 0 ]]; then
                log="`date`: ${repo} release ${current_release} ${latest_release} !"
            else
                log="`date`: Shit happens."
            fi
            echo ${log} >> ${HISTORY_INFO_PATH}
            echo >> ${HISTORY_INFO_PATH}
        fi
    done
}

main