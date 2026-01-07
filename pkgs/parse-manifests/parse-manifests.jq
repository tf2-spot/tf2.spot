def parse_date:
  split("\n")[2]
  | split(" ")[11]
  | strptime("%m/%d/%Y")
  | strftime("%Y.%m.%d");

def parse_meta:
  split("\n") as $lines
  | ($lines[0] | split(" ")[4]) as $depot
  | ($lines[2] | split(" ")[9]) as $manifest
  | {
    app: "232250",
    $depot,
    $manifest,
    fileList: null,
    hash: null,
    singleFile: false
  };

def select_vpks($assets):
  . + (
    $assets
    | split("\n")[10:-1][]
    | split(" +"; null)
    | [.[3, 5]] as [$hash, $fileList]
    | select($fileList | startswith("hl2/hl2_misc_", "tf/tf2_misc_"))
    | { $fileList, $hash, singleFile: true }
  );

{
  date: $windows | parse_date,
  windows: $windows | parse_meta,
  linux: $linux | parse_meta,
  assets: $assets | parse_meta | [
    . + { fileList: $assets_filelist },
    (. | select_vpks($assets))
  ]
}
