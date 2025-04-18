{ pkgs, ... }:
{
  enable = true;

  userSettings = {
    # Start at AeroSpace login
    start-at-login = true;

    # Set padding values
    accordion-padding = 30;
    gaps = {
      inner = {
        horizontal = 10;
        vertical = 10;
      };
      outer = {
        left = 10;
        bottom = 10;
        top = [
          # Ultrawides
          { monitor."^dell .*" = 54; }
          { monitor."^acer .*" = 46; }
          # Portrait secondary
          { monitor."lg ultra hd" = 54; }
          { monitor."samsung" = 46; }
          16
        ];
        right = 10;
      };
    };

    after-startup-command = [
      "workspace 4"
      "layout h_accordion"
      "exec-and-forget open -n /Applications/qutebrowser.app"
      "exec-and-forget open -n /Applications/kitty.app"
      "exec-and-forget kitty --title 'Scratch Terminal'"
      "exec-and-forget open -n /Applications/Slack.app"
      "exec-and-forget open -n /Applications/Diskord.app"
    ];

    # Notify Sketchybar about workspace change
    exec-on-workspace-change = [
      "/bin/bash"
      "-c"
      "${pkgs.sketchybar}/bin/sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE"
    ];

    mode.main.binding = {
      # change window focus within workspace
      alt-h = "focus left";
      alt-j = "focus down";
      alt-k = "focus up";
      alt-l = "focus right";

      # change focus between monitors (left and right)
      # TODO: aerospace does not have monitor specific focus commands
      # alt-s = left
      # alt-g = right

      # toggle layouts
      alt-slash = "layout tiles horizontal vertical";
      alt-comma = "layout accordion horizontal vertical";

      # mirror space along x or y axis
      # TODO: not supported by aerospace
      # alt-shift-x = mirror x
      # alt-shift-y = mirror y

      # toggle window float
      alt-shift-t = "layout floating tiling";

      # maximize a window
      alt-shift-m = "fullscreen";

      # switch to workspace #
      alt-1 = "workspace 1";
      alt-2 = "workspace 2";
      alt-3 = "workspace 3";
      alt-4 = "workspace 4";
      alt-5 = "workspace 5";
      alt-6 = "workspace 6";
      alt-7 = "workspace 7";
      alt-8 = "workspace 8";
      alt-9 = "workspace 9";
      alt-0 = "workspace 0";
      alt-a = "workspace a";
      alt-b = "workspace b";
      alt-c = "workspace c";
      alt-d = "workspace d";
      alt-t = "workspace t";

      # switch to previous workspace
      alt-tab = "workspace-back-and-forth";

      # move through workspaces
      ctrl-left = "workspace prev";
      ctrl-right = "workspace next";

      # balance out tree of windows (resize to occupy same area)
      alt-shift-e = "flatten-workspace-tree";

      # move window around in tree
      alt-shift-h = "move left";
      alt-shift-j = "move down";
      alt-shift-k = "move up";
      alt-shift-l = "move right";

      # move window to prev and next monitor
      alt-shift-s = "move-workspace-to-monitor --wrap-around next";
      alt-shift-g = "move-workspace-to-monitor --wrap-around prev";

      # move window to prev and next workspace
      alt-shift-p = "move-node-to-workspace --wrap-around prev";
      alt-shift-n = "move-node-to-workspace --wrap-around next";

      # move window to workspace #
      alt-shift-1 = "move-node-to-workspace 1";
      alt-shift-2 = "move-node-to-workspace 2";
      alt-shift-3 = "move-node-to-workspace 3";
      alt-shift-4 = "move-node-to-workspace 4";
      alt-shift-5 = "move-node-to-workspace 5";
      alt-shift-6 = "move-node-to-workspace 6";
      alt-shift-7 = "move-node-to-workspace 7";
      alt-shift-8 = "move-node-to-workspace 8";
      alt-shift-9 = "move-node-to-workspace 9";
      alt-shift-0 = "move-node-to-workspace 0";
      alt-shift-a = "move-node-to-workspace a";
      alt-shift-b = "move-node-to-workspace b";
      alt-shift-c = "move-node-to-workspace c";
      alt-shift-d = "move-node-to-workspace d";

      # modes
      ctrl-alt-shift-r = "mode resize";
      alt-shift-semicolon = "mode service";

      # password picker
      ctrl-shift-p = ''exec-and-forget find "$HOME/OneDrive - SAP SE/.password-store" -type f -name "*.gpg" | sed "s|.*/\.password-store/||; s|\.gpg$||" | choose | xargs -r -I{} env PASSWORD_STORE_DIR=$HOME/OneDrive\ -\ SAP\ SE/.password-store pass show -c {}'';
    };

    workspace-to-monitor-force-assignment = {
      "4" = ["secondary" "main"];
    };

    # modes
    mode.resize.binding = {
      h = "resize width -50";
      j = "resize height +50";
      k = "resize height -50";
      l = "resize width +50";
      q = "mode main";
    };

    mode.service.binding = {
      r = ["reload-config" "mode main"];
      backspace = ["close-all-windows-but-current" "mode main"];
      esc = "mode main";
    };

    # app to workspace assignments
    on-window-detected = [
      { "if" = { app-id = "org.qutebrowser.qutebrowser"; }; run = ["move-node-to-workspace 1"]; }
      {
        "if" = { 
          app-id = "net.kovidgoyal.kitty";
          during-aerospace-startup = true;
        };
        run = ["move-node-to-workspace 2"];
      }
      {
        "if" = { 
          app-id = "net.kovidgoyal.kitty";
          window-title-regex-substring = "Scratch Terminal";
        };
        run = ["move-node-to-workspace t"];
      }
      { "if" = { app-id = "com.microsoft.Outlook"; }; run = ["move-node-to-workspace 3"]; }
      { "if" = { app-id = "com.tinyspeck.slackmacgap"; }; run = ["move-node-to-workspace 4"]; }
      { "if" = { app-id = "com.hnc.Discord"; }; run = ["move-node-to-workspace 4"]; }
      # TODO: always send meeting windows to workspace 5
      { "if" = { app-id = "com.microsoft.teams2"; /*window-title-regex-substring = "";*/ }; run = ["move-node-to-workspace 5"]; }
      { "if" = { app-id = "org.qutebrowser.qutebrowser"; /*window-title-regex-substring = "^$";*/ }; run = ["layout tiling"]; }
    ];
  };
}
