{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    elixir_1_16
    xdg-utils
    fswatch
    inotify-tools
    watchexec
  ];

  shellHook = ''
    export ELIXIR_ERL_OPTIONS="+fnu"
    export ERL_AFLAGS="-kernel shell_history enabled"
  '';
}
