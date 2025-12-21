def parse_meta:
  split("\n") as $lines |
  ($lines[0] | split(" ")[4]) as $depot |
  ($lines[2] | split(" ") | [.[9, 11]]) as [$manifest, $date] |
  ($date | strptime("%m/%d/%Y") | strftime("%Y.%m.%d")) as $date |
  {
    app: "232250",
    $depot,
    $manifest,
    $date,
    fileList: null,
    hash: null,
    singleFile: false
  };

def select_vpks($assets):
  . + (
     $assets | split("\n")[10:-1][] | split(" +"; null)  | [.[3, 5]]  as [$hash, $fileList] |
    select($fileList | startswith("hl2/hl2_misc_", "tf/tf2_misc_")) |
    { $fileList, $hash, singleFile: true }
  );

{
  windows: $windows | parse_meta,
  linux: $linux | parse_meta,
  assets: $assets | parse_meta | [
    . + { fileList: $assets_filelist },
    (. | select_vpks($assets))
  ]
}
