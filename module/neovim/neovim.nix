{ config, pkgs, ... }:
with import <nixpkgs> { };
let
  unstable = import
    <nixpkgs-unstable>
    #(builtins.fetchTarball https://github.com/NixOS/nixpkgs/archive/master.tar.gz)
    # reuse the current configuration
    { config = config.nixpkgs.config; };
  #plugins = pkgs.callPackage ./plugin.nix { };
  #buildVimPlugin = unstable.pkgs.vimUtils.buildVimPlugin;
  #"filetype-nvim" = buildVimPlugin {
  #  name = "filetype-nvim";
  #  src = pkgs.fetchFromGitHub {
  #    owner = "nathom";
  #    repo = "filetype.nvim";
  #    rev = "b522628a45a17d58fc0073ffd64f9dc9530a8027";
  #    sha256 = "0l2cg7r78qbsbc6n5cvwl5m5lrzyfvazs5z3gf54hspw120nzr87";
  #  };
  #};
  myneovim = unstable.neovim.override {
    configure = {
      customRC = ''
        source /home/master-x/.config/nvim/init.lua
      '';
      packages.myVimPackage = with unstable.pkgs.vimPlugins; {
        start = [
          bufferline-nvim
          cmp-buffer
          cmp-cmdline
          cmp-nvim-lsp
          cmp-nvim-lua
          cmp-path
          cmp_luasnip
          friendly-snippets
          fzf-lua
          lualine-nvim
          luasnip
          indent-blankline-nvim
          null-ls-nvim
          nvim-cmp
          #nvim-colorizer-lua
          nvim-lspconfig
          nvim-lsp-ts-utils
          nvim-tree-lua
          nvim-treesitter-refactor
          nvim-treesitter-textobjects
          nvim-web-devicons
          #telescope-fzf-native-nvim
          #telescope-nvim
          tokyonight-nvim
          (nvim-treesitter.withPlugins (
            plugins: unstable.pkgs.tree-sitter.allGrammars
          ))
        ];
        #opt = [
        #  nvim-jdtls
        #];
      };
    };
  };
in
{
  environment.systemPackages = with pkgs; [
    myneovim
  ];
}
