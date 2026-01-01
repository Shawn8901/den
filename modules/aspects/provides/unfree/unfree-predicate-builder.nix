{ den, lib, ... }:
let
  description = ''
    This is a private aspect always included in den.default.

    It adds a module option that gathers all packages defined
    in den._.unfree usages and declares a 
    nixpkgs.config.allowUnfreePredicate for each class.

  '';

  unfreeComposableModule.options.unfree = {
    packages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  aspect = den.lib.parametric.exactly {
    includes = [
      (
        { OS, host }:
        let
          unused = den.lib.take.unused OS;
        in
        {
          ${host.class}.imports = [
            unfreeComposableModule
            (
              { config, ... }:
              {
                nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.unfree.packages;
              }
            )
          ];
        }
      )
      (
        {
          OS,
          HM,
          user,
          host,
        }:
        let
          unused = den.lib.take.unused [
            OS
            HM
          ];
        in
        {
          ${user.class}.imports = [
            unfreeComposableModule
            (
              { config, ... }:
              {
                nixpkgs.config.allowUnfreePredicate = lib.mkIf (!config.home-manager.useGlobalPkgs) (
                  pkg: builtins.elem (lib.getName pkg) config.unfree.packages
                );
              }
            )
          ];
        }
      )
      (
        { HM, home }:
        let
          unused = den.lib.take.unused HM;
        in
        {
          ${home.class}.imports = [
            unfreeComposableModule
            (
              { config, ... }:
              {
                nixpkgs.config.allowUnfreePredicate = lib.mkIf (!config.home-manager.useGlobalPkgs) (
                  pkg: builtins.elem (lib.getName pkg) config.unfree.packages
                );
              }
            )
          ];
        }
      )
    ];
  };
in
{
  den.default.includes = [ aspect ];
}
