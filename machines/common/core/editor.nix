{ pkgs, ... }:
{
  programs.vim = {
    enable = true;
    defaultEditor = true;
    package = (pkgs.vim-full.override { }).customize {
      name = "vim";
      vimrcConfig.packages.myplugins = with pkgs.vimPlugins; {
        start = [
          vim-nix
        ];
        opt = [ ];
      };
      vimrcConfig.customRC = ''
        set viminfo=%,'1000,<500,s100,h,n~/.config/vim/viminfo
        syntax on

        " Leader
        let mapleader = ";"

        " General
        set noshowmode
        set number
        set signcolumn=number
        set showmatch
        set nowrap
        set noswapfile
        set linebreak
        set hidden
        set foldenable
        set history=2000
        set nrformats=bin,hex
        set cmdheight=1

        " Search
        set incsearch
        set hlsearch
        set path+=**

        " Indentation
        set autoindent
        set cindent
        set smartindent
        set tabstop=2
        set softtabstop=2
        set shiftwidth=2
        set expandtab
        set smarttab

        " Scrolling
        set scrolloff=4
        set sidescrolloff=15
        set sidescroll=1

        " Splits
        set splitright
        set splitbelow

        " UI
        set termguicolors
        set background=dark
      '';
    };
  };
}
