#!/usr/bin/env bash
# Extract the host where the server is running, and add the URL to the APIs
[[ $HOST =~ ^https?://[^/]+ ]] && HOST="${BASH_REMATCH[0]}/api/v4/projects/"

# Look which is the default branch
#TARGET_BRANCH=`curl --silent "${HOST}${CI_PROJECT_ID}" --header "PRIVATE-TOKEN:${PRIVATE_TOKEN}" | python3 -c "import sys, json; print(json.load(sys.stdin)['default_branch'])"`;
TARGET_BRANCH="build-package"

# The description of our new MR, we want to remove the branch after the MR has
# been closed
BODY_MkMR="{
    \"id\": ${CI_PROJECT_ID},
    \"source_branch\": \"master\",
    \"target_branch\": \"${TARGET_BRANCH}\",
    \"remove_source_branch\": false,
    \"title\": \"autocreated merge from branch master to build-package\",
    \"assignee_id\":\"${GITLAB_USER_ID}\"
}";

# Require a list of all the merge request and take a look if there is already
# one with the same source branch
LISTMR="$(curl --silent "${HOST}${CI_PROJECT_ID}/merge_requests?state=opened" --header "PRIVATE-TOKEN:${PRIVATE_TOKEN}")"
COUNTBRANCHES="$(echo "${LISTMR}" | grep -o "\"source_branch\":\"master\"" | wc -l)";

# No MR found, let's create a new one
if [ "${COUNTBRANCHES}" -eq "0" ]; then
    MR="$(curl -X POST "${HOST}${CI_PROJECT_ID}/merge_requests" \
        --header "PRIVATE-TOKEN:${PRIVATE_TOKEN}" \
        --header "Content-Type: application/json" \
        --data "${BODY_MkMR}" | jq .iid)"

    BODY_AcMR="{ \"merge_when_pipeline_succeeds\": false  }";

    curl -X POST "${HOST}${CI_PROJECT_ID}/merge_requests/${MR}" \
            --header "PRIVATE-TOKEN:${PRIVATE_TOKEN}" \
            --header "Content-Type: application/json" \
            --data "${BODY_AcMR}" | jq .iid && echo "Merged!"
    exit;
fi

echo "No new merge request opened";