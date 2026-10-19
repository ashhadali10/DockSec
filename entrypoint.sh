#!/bin/bash
set -e

if [ "$(id -u)" = "0" ] && [ -z "${GITHUB_WORKSPACE:-}" ]; then
    echo "Standalone run detected: dropping privileges to 'docksec' user."
    exec gosu docksec "$0" "$@"
fi

for var in OPENAI_API_KEY ANTHROPIC_API_KEY GOOGLE_API_KEY LLM_PROVIDER LLM_MODEL; do
  input_var="INPUT_${var}"
  if [ -n "${!input_var}" ]; then
    export "${var}=${!input_var}"
  fi
done

ARGS=()

if [ -n "${INPUT_DOCKERFILE}" ]; then
  ARGS+=("${INPUT_DOCKERFILE}")
fi

if [ -n "${INPUT_IMAGE}" ]; then
  ARGS+=("-i" "${INPUT_IMAGE}")
fi

if [ -n "${INPUT_COMPOSE}" ]; then
  ARGS+=("-c" "${INPUT_COMPOSE}")
fi

if [ -n "${INPUT_OUTPUT_DIR}" ]; then
  ARGS+=("--output-dir" "${INPUT_OUTPUT_DIR}")
elif [ -n "${INPUT_OUTPUT}" ]; then
  ARGS+=("--output-dir" "${INPUT_OUTPUT}")
fi

if [ -n "${INPUT_SEVERITY}" ]; then
  ARGS+=("--severity" "${INPUT_SEVERITY}")
fi

if [ -n "${INPUT_FAIL_ON}" ]; then
  ARGS+=("--fail-on" "${INPUT_FAIL_ON}")
fi

if [ -n "${INPUT_FORMAT}" ]; then
  ARGS+=("--format" "${INPUT_FORMAT}")
fi

if [ "${INPUT_SARIF}" = "true" ]; then
  ARGS+=("--sarif")
fi

if [ "${INPUT_AI_ONLY}" = "true" ]; then
  ARGS+=("--ai-only")
fi

if [ "${INPUT_SCAN_ONLY}" = "true" ]; then
  ARGS+=("--scan-only")
fi

if [ "${INPUT_IMAGE_ONLY}" = "true" ]; then
  ARGS+=("--image-only")
fi

ARGS+=("$@")

if [ ${#ARGS[@]} -eq 0 ]; then
  printf 'Running: docksec\n'
else
  printf 'Running: docksec'; printf ' %q' "${ARGS[@]}"; printf '\n'
fi
docksec "${ARGS[@]}"
