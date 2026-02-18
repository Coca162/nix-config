{
  pkgs,
  lib,
  ...
}: {
  hm.programs.alacritty = {
    enable = true;
    settings = {
      font = {
        size = 11;
        normal.family = "monocraft";
      };
      env = {
        ZELLIJ_AUTO_ATTACH = "true";
        ENABLE_ZELLIJ = "true";
      };
      terminal.shell.program = lib.getExe pkgs.fish;
      window.opacity = 0.85;
      window.decorations = "None";
      # Insane that the default opens links just by clicking on them??
      hints.enabled = [
        {
          command = "xdg-open";
          hyperlinks = true;
          post_processing = true;
          persist = false;
          mouse.enabled = true;
          mouse.mods = "Control";
          binding.key = "O";
          binding.mods = "Shift";
          regex = "(ipfs:|ipns:|magnet:|mailto:|gemini:|gopher:|https:|http:|news:|file:|git:|ssh:|ftp:)[^\\u0000-\\u001F\\u007F-\\u009F<>\"\\\\s{-}\\\\^⟨⟩`]+";
        }
      ];
    };
  };
}
