_: {
  options = {
    package.defaultFunc = {inputs}: inputs.nixpkgs.pkgs.micro-with-wl-clipboard;

    bindings.default = {
      "Alt-s" = "Save";
      "Alt-q" = "Quit";
    };
  };
}
