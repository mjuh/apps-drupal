{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "drupal";
  version = "9.0.3";
  src = fetchurl {
    url = "https://ftp.drupal.org/files/projects/${pname}-${version}.tar.gz";
    sha256 = "067cnx8gi5a24y3aj54z7wm3zxb295xw0bdpyjhc5ihm27bjdbxb";
  };
  installPhase = ''
    tar czf ${pname}-${version}.tar.gz *
    install -Dm644 ${pname}-${version}.tar.gz $out/tarballs/${pname}-${version}.tar.gz
  '';
}
