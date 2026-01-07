"pushd \"$(mktemp -dt prefetch-missing.XXXXX)\"",
"echo \(@json | @sh) > chunks.json",

path(.. | select(try has("hash") and .hash == null)) as $path
| getpath($path)
| ($path | @tsv | gsub("\t"; "-")) as $dir
| (
  "",
  "mkdir \($dir)",

  if .fileList != null then "echo \(.fileList | @sh) > \($dir)-filelist" else empty end,

  ([ "DepotDownloader",
    "-app", .app,
    "-depot", .depot,
    "-manifest", .manifest,
    if .fileList != null then ("-filelist", "\($dir)-filelist") else empty end,
    "-dir", $dir
  ] | @sh),

  "rm -rf \($dir)/.DepotDownloader",

  "hash=$(nix hash path \($dir))",
  "nix store add-path --name 'depot-\(.depot).\(.manifest)' \($dir)",

  "jq --argjson path \($path | @json | @sh) --arg hash \"$hash\" 'setpath($path + [\"hash\"]; $hash)' chunks.json > chunks.json.tmp",

  "mv chunks.json.tmp chunks.json"
)
