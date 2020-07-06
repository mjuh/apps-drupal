{ stdenv, fetchurl, php73, pkgs }:

stdenv.mkDerivation rec {
  version = "1.9.0";
  pname = "composer";

  src = fetchurl {
    url = "https://getcomposer.org/download/${version}/composer.phar";
    sha256 = "0x88bin1c749ajymz2cqjx8660a3wxvndpv4xr6w3pib16fzdpy9";
  };

  dontUnpack = true;

  nativeBuildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    install -D $src $out/libexec/composer/composer.phar
    makeWrapper ${php73}/bin/php $out/bin/composer \
      --add-flags "$out/libexec/composer/composer.phar" \
      --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.unzip ]}
  '';
}

