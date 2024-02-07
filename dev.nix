{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    elixir_1_16
    xdg-utils
  ];

  shellHook = ''
    export MIX_ENV=dev
  '';
}
