RunTests() {
    PARAM_API_KEY=$(eval echo "\$$PARAM_API_KEY")
    PARAM_APP_KEY=$(eval echo "\$$PARAM_APP_KEY")

    if [[ -n "${DD_SITE}" ]]; then
        PARAM_SITE=${DD_SITE}
    fi

    echo "https://github.com/DataDog/datadog-ci/releases/${PARAM_VERSION}/download/datadog-ci_linux-x64"
    curl -L --fail "https://github.com/DataDog/datadog-ci/releases/${PARAM_VERSION}/download/datadog-ci_linux-x64" --output "./datadog-ci"
    
    chmod +x ./datadog-ci

    if [[ -z "${DATADOG_CI_COMMAND}" ]]; then
        DATADOG_CI_COMMAND="./datadog-ci"
    fi

    FLAGS=""
    if [[ $PARAM_FAIL_ON_CRITICAL_ERRORS == "1" ]]; then
        FLAGS+=" --failOnCriticalErrors"
    fi
    if [[ $PARAM_FAIL_ON_TIMEOUT == "1" ]]; then
        FLAGS+=" --failOnTimeout"
    else
        FLAGS+=" --no-failOnTimeout"
    fi
    if [[ $PARAM_TUNNEL == "1" ]]; then
        FLAGS+=" --tunnel"
    fi
    if [[ -n $PARAM_CONFIG_PATH ]]; then
        FLAGS+=" --config ${PARAM_CONFIG_PATH}"
    fi
    if [[ -n $PARAM_FILES ]]; then
        FLAGS+=" --files ${PARAM_FILES}"
    fi
    if [[ -n $PARAM_PUBLIC_IDS ]]; then
        FLAGS+=" --public-id ${PARAM_PUBLIC_IDS}"
    fi
    if [[ -n $PARAM_TEST_SEARCH_QUERY ]]; then
        FLAGS+=" --search ${PARAM_TEST_SEARCH_QUERY}"
    fi

    read -ra flag_args < <(echo "${FLAGS}")

    set +e

    DATADOG_API_KEY="${PARAM_API_KEY}" \
    DATADOG_APP_KEY="${PARAM_APP_KEY}" \
    DATADOG_SUBDOMAIN="${PARAM_SUBDOMAIN}" \
    DATADOG_SYNTHETICS_LOCATIONS="${PARAM_LOCATIONS}" \
    DATADOG_SITE="${PARAM_SITE}" \
        $DATADOG_CI_COMMAND synthetics run-tests \
        "${flag_args[@]}"
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    RunTests
fi