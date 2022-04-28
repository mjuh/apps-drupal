{ nixpkgs, system, php, version }:

with import nixpkgs { inherit system; };

let

  drupal = callPackage ./pkgs/drupal { pver = version; };
  drupal-po = callPackage ./pkgs/drupal-ru-po { pver = version; };

  installCommand = builtins.concatStringsSep " " [
    "${php}/bin/php" # на момент написания php из комплекта drush не работает, и выдает малоинформативные ошибки о проблемах fork
    "${drush}/libexec/drush/drush.phar site:install -y"
    "--locale=ru"
    "--db-url=mysql://$DB_USER:$DB_PASSWORD@$DB_HOST/$DB_NAME"
    "--site-name=$APP_TITLE"
    "--account-name=$ADMIN_USERNAME"
    "--account-pass=$ADMIN_PASSWORD"
    "--account-mail=$ADMIN_EMAIL"
  ];

  entrypoint = (stdenv.mkDerivation rec {
    name = "drupal-install";
    builder = writeScript "builder.sh" (
      ''
        source $stdenv/setup
        mkdir -p $out/bin

        cat > $out/bin/${name}.sh <<'EOF'
        #!${bash}/bin/bash
        set -ex
        export PATH=${gnutar}/bin:${coreutils}/bin:${gnused}/bin:${mariadb.client}/bin:$PATH

        echo "Extract installer archive."
        tar xf ${drupal} --strip-components=1

        echo "Prepare translation"
        mkdir -p sites/default/files/translations
        cp ${drupal-po} sites/default/files/translations/${drupal-po.name}

        # rm -rf vendor composer.json composer.lock ???
        echo "Patch config"
        echo -e "\$settings['trusted_host_patterns'] = [\n\t'^$DOMAIN_NAME$',\n\t'^www.$DOMAIN_NAME$'\n];"| sed 's/\./\\./g' >> sites/default/default.settings.php
        echo "Install."
        ${installCommand}
        EOF

        chmod 555 $out/bin/${name}.sh
      ''
    );
  });

in
pkgs.dockerTools.buildLayeredImage rec {
  name = "docker-registry.intr/apps/drupal";

  contents =
    [ bashInteractive coreutils gnutar gnused gzip entrypoint drush mariadb.client ];
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

