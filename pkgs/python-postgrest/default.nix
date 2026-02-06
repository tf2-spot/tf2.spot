{ buildPythonPackage
, fetchPypi
  # build
, uv-build
  # deps
, deprecation
, h2
, httpx
, pydantic
, yarl
}:

let
  pname = "postgrest";
  version = "2.27.3";
in

buildPythonPackage {
  inherit pname version;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-wuJnmt38jqqyMZe6192u5su0y+jEg+vS0uUhlUMDfMM=";
  };

  pyproject = true;
  build-system = [
    uv-build
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.8.3,<0.9.0" "uv_build"
  '';

  dependencies = [
    deprecation
    h2
    httpx
    pydantic
    yarl
  ];
}

