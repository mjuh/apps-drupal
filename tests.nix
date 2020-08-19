{ nixpkgs ? (import <nixpkgs> { }).fetchgit {
  url = "https://github.com/NixOS/nixpkgs.git";
  rev = "ce9f1aaa39ee2a5b76a9c9580c859a74de65ead5";
  sha256 = "1s2b9rvpyamiagvpl5cggdb2nmx4f7lpylipd397wz8f0wngygpi";
}, overlayUrl ? "git@gitlab.intr:_ci/nixpkgs.git", overlayRef ? "master"
, phpRef ? "master" }:

with import nixpkgs {
  overlays = [
    (import (builtins.fetchGit {
      url = overlayUrl;
      ref = overlayRef;
    }))
    (self: super: {
      containerImageApache = import (builtins.fetchGit {
        url = "git@gitlab.intr:webservices/apache2-php72.git";
        ref = phpRef;
      }) { };
    })
  ];
};

maketestCms {
  inherit nixpkgs containerImageApache;
  testName = "drupal";
  containerImageCMS = import ./default.nix { };
  image = "docker-registry.intr/apps/drupal:latest";
}

