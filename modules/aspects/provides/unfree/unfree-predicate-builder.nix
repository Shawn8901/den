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

  moduleImports = [
    unfreeComposableModule
    (
      { config, ... }:
      {
        nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.unfree.packages;
      }
    )
  ];

  aspect = den.lib.parametric.exactly {
    includes = [
      (
        { OS, host }:
        let
          unused = den.lib.take.unused OS;
        in
        {
          ${host.class}.imports = moduleImports;
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
          ${user.class}.imports = moduleImports;
        }
      )
      (
        { HM, home }:
        let
          unused = den.lib.take.unused HM;
        in
        {
          ${home.class}.imports = moduleImports;
        }
      )
    ];
  };
in
{
  den.default.includes = [ aspect ];
}
