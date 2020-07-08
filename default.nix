{ nixpkgs ? (import <nixpkgs> { }).fetchgit {
  url = "https://github.com/NixOS/nixpkgs.git";
  rev = "ce9f1aaa39ee2a5b76a9c9580c859a74de65ead5";
  sha256 = "1s2b9rvpyamiagvpl5cggdb2nmx4f7lpylipd397wz8f0wngygpi";
}, overlayUrl ? "git@gitlab.intr:_ci/nixpkgs.git", overlayRef ? "master" }:

with import nixpkgs {
  overlays = [
    (import (builtins.fetchGit {
      url = overlayUrl;
      ref = overlayRef;
    }))
  ];
};

with lib;

let
  drupal = callPackage ./pkgs/drupal { };
  composer = callPackage ./pkgs/composer { };

  drushInstallCommand = "${composer}/bin/composer require drush/drush";
  drupalConsoleInstallCommand = "${composer}/bin/composer require drupal/console";

  installCommand = builtins.concatStringsSep " " [
    "${php73}/bin/php"
    "./vendor/bin/drupal site:install"
    "--langcode=ru"
    "--db-type=mysql"
    "--db-host=$DB_HOST"
    "--db-name=$DB_NAME"
    "--db-user=$DB_USER"
    "--db-pass=$DB_PASSWORD"
    "--site-name=$APP_TITLE"
    "--account-name=$ADMIN_USERNAME"
    "--account-pass=$ADMIN_PASSWORD"
    "--account-mail=$ADMIN_EMAIL"
    "--force"
  ];

  entrypoint = (stdenv.mkDerivation rec {
    name = "drupal-install";
    builder = writeScript "builder.sh" (''
      source $stdenv/setup
      mkdir -p $out/bin

      cat > $out/bin/${name}.sh <<'EOF'
      #!${bash}/bin/bash
      set -ex
      export PATH=${gnutar}/bin:${coreutils}/bin:${gnused}/bin:$PATH

      echo "Extract installer archive."
      tar xf ${drupal}/tarballs/drupal-*.tar.gz

      echo "Install."
      ${drupalConsoleInstallCommand}
      echo -e "\$settings['trusted_host_patterns'] = [\n\t'^$DOMAIN_NAME$',\n\t'^www\.$DOMAIN_NAME$'\n];"| sed 's/\./\\./g' >> sites/default/default.settings.php
      ${installCommand}
      EOF

      chmod 555 $out/bin/${name}.sh
    '');
  });

in pkgs.dockerTools.buildLayeredImage rec {
  name = "docker-registry.intr/apps/drupal";
  tag = "latest";
  contents =
    [ bashInteractive coreutils gnutar gnused gzip entrypoint nss-certs ];
  config = {
    Entrypoint = "${entrypoint}/bin/drupal-install.sh";
    Env = [
      "TZ=Europe/Moscow"
      "TZDIR=${tzdata}/share/zoneinfo"
      "LOCALE_ARCHIVE_2_27=${glibcLocales}/lib/locale/locale-archive"
      "LOCALE_ARCHIVE=${glibcLocales}/lib/locale/locale-archive"
      "LC_ALL=en_US.UTF-8"
      "SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
    ];
    WorkingDir = "/workdir";
  };
  extraCommands = ''
    set -x -e

    mkdir -p {etc,home/alice,root,tmp}
    chmod 755 etc
    chmod 777 home/alice
    chmod 777 tmp

    cat > etc/passwd << 'EOF'
    root:!:0:0:System administrator:/root:/bin/sh
    alice:!:1000:997:Alice:/home/alice:/bin/sh
    EOF

    cat > etc/group << 'EOF'
    root:!:0:
    users:!:997:
    EOF

    cat > etc/nsswitch.conf << 'EOF'
    hosts: files dns
    EOF
  '';
}

