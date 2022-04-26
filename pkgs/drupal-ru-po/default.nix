{ stdenv, fetchurl, lib, pver }:

stdenv.mkDerivation rec {
  name = "drupal-${pver}.ru.po";

  src = fetchurl {
    url = "https://ftp.drupal.org/files/translations/all/drupal/${name}";
    sha256 = "sha256-pxQvAB+XVY31fbKULVV+d/oNWI7WmXvBJ+n+ZjPAYKs=";
  };
  sourceRoot = ".";
  unpackPhase = " ";
  installPhase = ''
    cp -r $src $out
  '';
}