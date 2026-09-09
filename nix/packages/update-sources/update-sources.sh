set -euo pipefail

sources=nix/sources.json
report=

while [ $# -gt 0 ]; do
  case "$1" in
  --sources)
    sources=$2
    shift 2
    ;;
  --report)
    report=$2
    shift 2
    ;;
  *)
    echo "update-sources: unknown argument: $1" >&2
    exit 2
    ;;
  esac
done

if [ ! -f "$sources" ]; then
  echo "update-sources: no such file: $sources" >&2
  exit 2
fi

api() {
  if [ -n "${GITHUB_TOKEN:-}" ]; then
    curl -fsSL -H "Authorization: Bearer $GITHUB_TOKEN" "https://api.github.com/$1"
  else
    curl -fsSL "https://api.github.com/$1"
  fi
}

updated='{}'
drift='{}'

mapfile -t names < <(jq -r 'keys[]' "$sources")

for name in "${names[@]}"; do
  entry=$(jq -c --arg n "$name" '.[$n]' "$sources")
  upstream=$(jq -r '.upstream' <<<"$entry")
  owner=$(jq -r '.owner' <<<"$entry")
  repo=$(jq -r '.repo' <<<"$entry")
  rev=$(jq -r '.rev' <<<"$entry")

  branch=$(jq -r '.branch // empty' <<<"$entry")
  if [ -z "$branch" ]; then
    echo "update-sources: $name has no \"branch\"; upstream default branches are not" >&2
    echo "  a safe default (brownplt/pyret-lang defaults to a divergent line)" >&2
    exit 1
  fi
  head=$(api "repos/$upstream/commits/$branch" | jq -r '.sha')

  if [ "$owner/$repo" != "$upstream" ]; then
    # Pinned to a fork. Bumping to upstream's head would silently drop the
    # fork's own commits, so report the gap and leave the pin alone.
    behind=$(api "repos/$owner/$repo/compare/$rev...${upstream%%/*}:$branch" | jq '.ahead_by')
    drift=$(jq --arg n "$name" --arg u "$upstream" --arg h "$head" --argjson b "$behind" \
      '.[$n] = { upstream: $u, head: $h, behind: $b }' <<<"$drift")
    continue
  fi

  if [ "$rev" = "$head" ]; then
    continue
  fi

  prefetched=$(nix store prefetch-file --unpack --json --name source \
    "https://github.com/$owner/$repo/archive/$head.tar.gz")
  hash=$(jq -r '.hash' <<<"$prefetched")
  store=$(jq -r '.storePath' <<<"$prefetched")

  entry=$(jq --arg r "$head" --arg h "$hash" '.rev = $r | .hash = $h' <<<"$entry")

  if jq -e 'has("npmDepsHash")' <<<"$entry" >/dev/null; then
    lock="$store/package-lock.json"
    if [ ! -f "$lock" ]; then
      echo "update-sources: $name declares npmDepsHash but $lock is missing" >&2
      exit 1
    fi
    npm_hash=$(prefetch-npm-deps "$lock")
    entry=$(jq --arg h "$npm_hash" '.npmDepsHash = $h' <<<"$entry")
  fi

  jq --arg n "$name" --argjson e "$entry" '.[$n] = $e' "$sources" | sponge "$sources"

  updated=$(jq --arg n "$name" --arg f "$rev" --arg t "$head" \
    '.[$n] = { from: $f, to: $t }' <<<"$updated")
done

result=$(jq -n --argjson u "$updated" --argjson d "$drift" '{ updated: $u, drift: $d }')
if [ -n "$report" ]; then
  printf '%s\n' "$result" >"$report"
fi
printf '%s\n' "$result"
