# shellcheck shell=bash
  #
  # Shared functions and globals for ES BR agent command hook scripts.
  #
  
  set -o nounset -o pipefail
  
  ##
  # External configuration from environment variables
  #
  # Connection config
  HOST="${HOST:-localhost}"
  PORT="${PORT:-9200}"
  CHECK_CONN_FLAG=0
  
  PROTOCOL="http"
  TLS_CURL_OPTIONS=()
  if [[ ${TLS_AGENT_ENABLED} == "true" ]]; then
    PROTOCOL="https"
    TLS_CURL_OPTIONS=(--cert "${TLS_CLIENT_CERT_SEARCHENGINE}" --key "${TLS_CLIENT_KEY_SEARCHENGINE}" --cacert "${TLS_ROOT_CA_CERT}")
  fi
  
  # Repo config
  SNAP_MAX_THROUGHPUT="${SNAP_MAX_THROUGHPUT:-200mb}"
  # Clean up snapshot config
  SNAP_PRESERVE="${SNAP_PRESERVE:-false}"
  # Restore config
  RECOVERY_MAX_THROUGHPUT="${RECOVERY_MAX_THROUGHPUT:-200mb}"
  RECOVERY_MAX_CHUNKS="${RECOVERY_MAX_CHUNKS:-4}"
  CLEAN_INDEX="${CLEAN_INDEX:-false}"
  CLOSE_INDEX="${CLOSE_INDEX:-true}"
  DISABLE_AUTO_CREATE_INDEX="${DISABLE_AUTO_CREATE_INDEX:-true}"
  
  
  ##
  # Globals
  #
  REPO_NAME="backup_repo"
  SNAP_NAME="backup_snapshot"
  REPO_PATH="/opt/${SEARCH_ENGINE_TYPE}/repository/$REPO_NAME"
  LAST_STATUS=
  
  
  ## Log
  #######################################
  # Log message to stdout.
  # Arguments:
  #   Message to log
  #######################################
  function log() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*"
  }
  
  ## Error log
  #######################################
  # Log error message to stderr.
  # Arguments:
  #   Message to log
  #######################################
  function err() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
  }
  
  ## ES REST
  #######################################
  # Call Elasticsearch REST API.
  # Globals:
  #   PROTOCOL: http or https (TODO)
  #   HOST: Elasticsearch host
  #   PORT: Elasticsearch port
  #   LAST_STATUS: Updated with HTTP status code. Cannot call esrest in a
  #     subshell if this is needed
  # Arguments:
  #   method: HTTP method - GET, DELETE, PUT, POST
  #   path: URL path for REST API
  #   data: Optional JSON data for request
  #######################################
  function esrest() {
    local method="$1"
    local path="$2"
    if [[ $# -ge 3 ]]; then
      local data="$3"
    else
      local data=""
    fi
  
    local params=(-sS --output /dev/stderr --write-out '%{http_code}')
  
    if [[ -n $data ]]; then
      params+=(-H 'Content-Type: application/json' -d "${data}")
    fi
    { LAST_STATUS=$(curl "${TLS_CURL_OPTIONS[@]}" -X "$method" "${PROTOCOL}://${HOST}:${PORT}${path}" "${params[@]}"); } 2>&1
    exitcode=$?
    if [[ ${exitcode} -ne 0 ]]; then
           if [ $CHECK_CONN_FLAG -eq 0 ]; then
                  err "Curl $method request to ${path} failed with exit code ${exitcode}"
                  return ${exitcode}
           fi
    fi
    if [[ $LAST_STATUS -ne 200 ]]; then
            if [ $CHECK_CONN_FLAG -eq 0 ]; then
                  err "$method request to ${path} received invalid HTTP response code ${LAST_STATUS}"
                  return 22
            fi
    fi
  }
  
  function GET() {
    esrest GET "$1"
  }
  
  function DELETE() {
    esrest DELETE "$1"
  }
  
  function POST() {
    esrest POST "$@"
  }
  
  function PUT() {
    esrest PUT "$@"
  }
  
