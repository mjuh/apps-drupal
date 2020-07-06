{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "drupal";
  version = "9.0.1";
  src = fetchurl {
    url = "https://ftp.drupal.org/files/projects/${pname}-${version}.tar.gz";
    sha256 = "83aec8ffad7358b340818759418ce4500b45871fc1311ca9d11f8ce4cd9871c4";
  };
  installPhase = ''
    tar czf ${pname}-${version}.tar.gz *
    install -Dm644 ${pname}-${version}.tar.gz $out/tarballs/${pname}-${version}.tar.gz
  '';
}
