pkgs: {
  lenopow = pkgs.callPackage ./lenopow { };
  glance-agent = pkgs.callPackage ./glance-agent { };
  subtui = pkgs.callPackage ./subtui { };
  electronwmd = pkgs.callPackage ./electronwmd { };
}
