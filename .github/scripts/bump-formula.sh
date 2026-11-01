#!/usr/bin/env bash
# Bumps Formula/sdkman-cli.rb to the latest sdkman-cli and sdkman-cli-native releases.
# Writes cli/native old+new versions to $GITHUB_OUTPUT (if set) and exits 0 with
# changed=false when the formula is already current.
set -euo pipefail

FORMULA="Formula/sdkman-cli.rb"

latest_tag() {
  gh release view --repo "$1" --json tagName --jq .tagName
}

# Look up an asset's sha256 from the release checksums file, falling back to downloading it.
asset_sha() {
  local repo="$1" tag="$2" asset="$3" sha
  sha=$(gh release download "$tag" --repo "$repo" -p checksums_sha256.txt -O - 2>/dev/null \
    | awk -v a="$asset" '$2 == a { print $1 }' || true)
  if [[ -z "$sha" ]]; then
    sha=$(gh release download "$tag" --repo "$repo" -p "$asset" -O - | sha256sum | awk '{ print $1 }')
  fi
  [[ "$sha" =~ ^[0-9a-f]{64}$ ]] || { echo "No sha256 for $repo $tag $asset" >&2; exit 1; }
  echo "$sha"
}

cli_new=$(latest_tag sdkman/sdkman-cli)
native_tag=$(latest_tag sdkman/sdkman-cli-native)
native_new="${native_tag#v}"

cli_old=$(grep -oE 'sdkman-cli/releases/download/[^/]+/' "$FORMULA" | head -1 | cut -d/ -f4)
native_old=$(grep -oE 'sdkman-cli-native/releases/download/v[^/]+/' "$FORMULA" | head -1 | cut -d/ -f4)
native_old="${native_old#v}"

echo "sdkman-cli:        $cli_old -> $cli_new"
echo "sdkman-cli-native: $native_old -> $native_new"

out() { [[ -n "${GITHUB_OUTPUT:-}" ]] && echo "$1" >> "$GITHUB_OUTPUT" || true; }
out "cli_old=$cli_old"; out "cli_new=$cli_new"
out "native_old=$native_old"; out "native_new=$native_new"

if [[ "$cli_old" == "$cli_new" && "$native_old" == "$native_new" ]]; then
  echo "Formula is up to date."
  out "changed=false"
  exit 0
fi

esc() { printf '%s' "$1" | sed 's/[.]/\\./g'; }

# Walk every url/sha256 pair in the formula and rewrite both.
tmp=$(mktemp)
cp "$FORMULA" "$tmp"
while read -r old_url; do
  new_url=$(printf '%s' "$old_url" \
    | sed -e "s|/download/$(esc "$cli_old")/sdkman-cli-$(esc "$cli_old")\.zip|/download/$cli_new/sdkman-cli-$cli_new.zip|" \
          -e "s|/download/v$(esc "$native_old")/|/download/v$native_new/|" \
          -e "s|sdkman-cli-native-$(esc "$native_old")-|sdkman-cli-native-$native_new-|")
  [[ "$new_url" == "$old_url" ]] && continue

  repo=$(printf '%s' "$new_url" | cut -d/ -f4-5)
  tag=$(printf '%s' "$new_url" | cut -d/ -f8)
  asset=$(basename "$new_url")
  new_sha=$(asset_sha "$repo" "$tag" "$asset")
  old_sha=$(grep -A1 -F "\"$old_url\"" "$FORMULA" | grep -oE '[0-9a-f]{64}' | head -1)

  echo "  $asset  $new_sha"
  sed -i -e "s|\"$old_url\"|\"$new_url\"|" -e "s|$old_sha|$new_sha|" "$tmp"
done < <(grep -oE 'url "[^"]+"' "$FORMULA" | cut -d'"' -f2)

cat "$tmp" > "$FORMULA"   # preserve file mode
rm -f "$tmp"
out "changed=true"
