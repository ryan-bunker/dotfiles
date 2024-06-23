import Workspaces from "workspaces";

const notifications = await Service.import("notifications");
const mpris = await Service.import("mpris");
const audio = await Service.import("audio");
const battery = await Service.import("battery");
const systemtray = await Service.import("systemtray");
const network = await Service.import("network");

const date = Variable("", {
  poll: [1000, "date '+%a, %b %d'"],
});
const time = Variable("", {
  poll: [1000, "date '+%l:%M %p'"],
});

const SystemTray = () =>
  Widget.Box({
    spacing: 8,
    children: systemtray.bind("items").as((items) =>
      items.map((item) =>
        Widget.Button({
          child: Widget.Icon({ size: 20 }).bind("icon", item, "icon"),
          tooltipMarkup: item.bind("tooltip_markup"),
          // onPrimaryClick: item.is_menu
          //   ? undefined
          //   : (_, event) => item.activate(event),
          onSecondaryClick: (_, event) => item.openMenu(event),
        }),
      ),
    ),
  });

const VolumeInfo = () =>
  Widget.EventBox({
    child: Widget.Icon({ size: 20 }).hook(audio.speaker, (self) => {
      const vol = audio.speaker.volume * 100;
      const icon = [
        { t: 101, i: "oversimplified" },
        { t: 67, i: "high" },
        { t: 32, i: "medium" },
        { t: 1, i: "low" },
        { t: 0, i: "muted" },
      ].find(({ t }) => t <= vol)?.i;

      if (audio.speaker.is_muted) {
        self.icon = "audio-volume-muted-symbolic";
      } else {
        self.icon = `audio-volume-${icon}-symbolic`;
      }
    }),
  });

const BatteryInfo = () =>
  Widget.Icon({
    icon: battery.bind("icon_name"),
    size: 20,
    visible: battery.bind("available"),
  }).hook(battery, (self) => {
    self.tooltip_text = `${battery.percent}%`;
    if (battery.charging) {
      self.tooltip_text += " (charging)";
    } else if (battery.charged) {
      self.tooltip_text += " (charged)";
    }
  });

const WifiIndicator = () =>
  Widget.Icon({
    icon: network.wifi.bind("icon_name"),
    size: 20,
  }).hook(
    network.wifi,
    (self) => {
      self.tooltip_text = `${network.wifi.ssid} (${network.wifi.strength} dB)`;
    },
    "changed",
  );

const WiredIndicator = () =>
  Widget.Icon({
    icon: network.wired.bind("icon_name"),
  });

const NetworkIndicator = () =>
  Widget.Stack({
    children: {
      wifi: WifiIndicator(),
      wired: WiredIndicator(),
    },
    shown: network.bind("primary").as((p) => p || "wifi"),
  });

function Clock() {
  return Widget.Box({
    vertical: true,
    children: [
      Widget.Label({ class_name: "clock date", label: date.bind() }),
      Widget.Label({ class_name: "clock time", label: time.bind() }),
    ],
  });
}

function StatusArea() {
  return Widget.Box({
    class_name: "grouping",
    spacing: 8,
    children: [
      SystemTray(),
      VolumeInfo(),
      BatteryInfo(),
      NetworkIndicator(),
      Clock(),
    ],
  });
}

// layout of the bar

function Left() {
  return Widget.Box({
    spacing: 8,
    children: [Workspaces()],
  });
}

function Right() {
  return Widget.Box({
    hpack: "end",
    spacing: 8,
    children: [StatusArea()],
  });
}

function Bar(monitor: number = 0) {
  return Widget.Window({
    name: `ags-status-bar-${monitor}`, // name has to be unique
    class_name: "bar",
    monitor,
    anchor: ["top", "left", "right"],
    exclusivity: "exclusive",
    child: Widget.CenterBox({
      start_widget: Left(),
      end_widget: Right(),
    }),
  });
}

const scss = `${App.configDir}/style.scss`;
const css = `/tmp/my-style.css`;
Utils.exec(`sassc ${scss} ${css}`);

Utils.monitorFile(scss, function () {
  Utils.exec(`sassc ${scss} ${css}`);

  App.resetCss();
  App.applyCss(css);
});

App.config({
  style: css,
  windows: [Bar()],
});

export {};
