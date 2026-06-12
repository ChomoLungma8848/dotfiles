{ pkgs, ... }:
{
  extraPlugins = [(pkgs.vimUtils.buildVimPlugin {
    name = "pantran";
    src = pkgs.fetchFromGitHub {
      owner = "potamides";
      repo = "pantran.nvim";
      rev = "b87c3ae";
      hash = "sha256-b4odpXwh+BmFsK5v3HmSWG43FA+ygOAPU+qFNy6vWDU=";
    };
  })];
  extraConfigLua = ''
    require("pantran").setup({
      default_engine = "google",
      engines = {
        google = {
          fallback = {
            default_source = "en",
            default_target = "ja",
          },
        },
      },
    })
  '';
}
