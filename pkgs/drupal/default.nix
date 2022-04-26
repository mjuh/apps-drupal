{ stdenv, fetchurl, lib, pver }:

stdenv.mkDerivation rec {
  pname = "drupal";
  version = pver;

  src = fetchurl {
    url = "https://ftp.drupal.org/files/projects/${pname}-${version}.tar.gz";
    sha256 = "sha256-/6Mu9u0nWYzCEYFkPFbFG6znhK5+WG34RcMw1eXwCfY=";
  };
  sourceRoot = ".";
  unpackPhase = " ";
  installPhase = ''
    cp -r $src $out
  '';

}
