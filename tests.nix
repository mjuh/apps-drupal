{ nixpkgs, maketestCms, containerImageCMS, containerImageApache }:

with nixpkgs;

maketestCms {
  inherit nixpkgs containerImageCMS containerImageApache;
  testName = "drupal";
}
