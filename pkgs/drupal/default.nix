{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "drupal";
  version = "8.9.1";
  src = fetchurl {
    url = "https://ftp.drupal.org/files/projects/${pname}-${version}.tar.gz";
    sha256 = "2c4460b04faade7440103c683340525a450f9b080ff75af7af4ddc670b73eefb";
  };
  installPhase = ''
    tar czf ${pname}-${version}.tar.gz *
    install -Dm644 ${pname}-${version}.tar.gz $out/tarballs/${pname}-${version}.tar.gz
  '';
}
