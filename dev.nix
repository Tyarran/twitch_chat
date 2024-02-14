{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    elixir_1_16
    xdg-utils
  ];

  shellHook = ''
    export ELIXIR_ERL_OPTIONS="+fnu"
  '';
}
