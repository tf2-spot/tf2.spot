def parse_date:
  split("\n")[2]
  | split(" ")[11]
  | strptime("%m/%d/%Y")
  | strftime("%Y.%m.%d")
  ;

def add_meta($contents):
  ($contents | split("\n")) as $lines
  | ($lines[0] | split(" ")[4]) as $depot
  | ($lines[2] | split(" ")[9]) as $manifest
  | { $manifest
    , fileList: null
    , hash: null
    , singleFile: false
    }
    + .
  ;

def mult_by_filter($contents; filter):
  $contents
  | split("\n")[10:-1][]
  | split(" +"; null)
  | [.[3, 5]] as [$hash, $fileList]
  | select($fileList | filter)
  | { $fileList
    , $hash
    , singleFile: true
    }
  ;

def add_and_mult:
  $ARGS.named[.depot] as $contents
  | add_meta($contents)
  | if has("startsWith") then
      .startsWith as $startsWith | . + mult_by_filter($contents; startswith($startsWith))
    elif has("endsWith") then
      .endsWith as $endsWith | . + mult_by_filter($contents; endswith($endsWith))
    end
  | pick(.app, .depot, .manifest, .fileList, .hash, .singleFile)
  ;

.[] |= [.[] | add_and_mult]
| .dates = ($ARGS.named | .[] |= parse_date)
