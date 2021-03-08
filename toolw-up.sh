#!/usr/bin/env bash

# generated by "./build.sh"

set -ueo pipefail

main() {
  if [[ -f "toolw" ]]; then
    echo "toolw : already exists"
  else
    echo "toolw : creating"
    generate_wrapper > "toolw"
    chmod +x "toolw"
  fi
  if [[ -f ".tool/wrapper/tool-wrapper.properties" ]]; then
    echo ".tool/wrapper/tool-wrapper.properties : already exists"
  else
    echo ".tool/wrapper/tool-wrapper.properties : creating"
    mkdir -p ".tool/wrapper"
    generate_wrapper_config > ".tool/wrapper/tool-wrapper.properties"
  fi
}

generate_wrapper() {
  cat <<'__WRAPPER__'
#!/usr/bin/env bash

set -ueo pipefail

[[ -n "${TOOL_DEBUG:-}" ]] && set -x

tool_user_home=${TOOL_USER_HOME:-$HOME/.tool}
tool_wrapper_dir="$(dirname "$0")"
tool_wrapper_config="$tool_wrapper_dir/.tool/wrapper/tool-wrapper.properties"

# shellcheck source=.tool/wrapper/tool-wrapper.properties
source "$tool_wrapper_config"

get_version() {
  if [[ -z "$distributionUrl" ]]; then
    1>&2 echo "distributionUrl not found in $tool_wrapper_config"
    exit 1
  fi
  [[ ${distributionUrl} =~ ^.*/(.*)/.*$ ]]
  printf "%s" "${BASH_REMATCH[1]}"
}

main() {
  version="$(get_version)"
  tool_local_version_dir="$tool_user_home/wrapper/dists/tool-$version"
  if [[ ! -d "$tool_local_version_dir" ]]; then
    tool_local_install_temp_dir="$tool_user_home/wrapper/dists/tmp-""$$""$(date +"%s")"
    mkdir -p "$tool_local_install_temp_dir"
    (
      cd "$tool_local_install_temp_dir"
      if ! curl --show-error --silent "$distributionUrl" -o download.zip; then
        1>&2 echo "could not download $distributionUrl"
        exit 1
      fi
      unzip -q download.zip
      rm download.zip
    )
    mv "$tool_local_install_temp_dir/$(ls "$tool_local_install_temp_dir")" "$tool_local_version_dir"
    rmdir "$tool_local_install_temp_dir"
    chmod a+x "$tool_local_version_dir/bin"/*
  fi
  exec "$tool_local_version_dir/bin/tool" "$@"
}

main "$@"
__WRAPPER__
}

generate_wrapper_config() {
  cat <<'__WRAPPER_CONFIG__'
# wrapper configuration
distributionUrl=https://example.repo/location/0.0.1/tool.zip
__WRAPPER_CONFIG__
}

main
