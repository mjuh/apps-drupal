{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "drupal";
  version = "8.9.3";
  src = fetchurl {
    url = "https://ftp.drupal.org/files/projects/${pname}-${version}.tar.gz";
    sha256 = "12b61v56fvpb10f0byd3i9zi9ary1i0kxv9rbi8zb9j4lg015sav";
  };
  installPhase = ''
    tar czf ${pname}-${version}.tar.gz *
    install -Dm644 ${pname}-${version}.tar.gz $out/tarballs/${pname}-${version}.tar.gz
  '';
}
