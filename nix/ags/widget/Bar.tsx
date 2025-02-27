import { App, Astal, Gtk, Gdk } from "astal/gtk3";
import { Variable, GLib, bind } from "astal";
import Battery from "gi://AstalBattery";
import Network from "gi://AstalNetwork";
import Tray from "gi://AstalTray";
import Wp from "gi://AstalWp";
import Workspaces from "./Workspaces";

function SystemTray() {
  const tray = Tray.get_default();

  return (
    <box className="system-tray" spacing={8}>
      {bind(tray, "items").as((items) =>
        items.map((item) => (
          <menubutton
            tooltipMarkup={bind(item, "tooltipMarkup")}
            usePopover={false}
            actionGroup={bind(item, "actionGroup").as((ag) => ["dbusmenu", ag])}
            menuModel={bind(item, "menuModel")}
          >
            <icon gicon={bind(item, "gicon")} />
          </menubutton>
        )),
      )}
    </box>
  );
}

function VolumeInfo() {
  const speaker = Wp.get_default()?.audio.defaultSpeaker!;

  return (
    <eventbox>
      <icon iconSize={20} className="icon" icon={bind(speaker, "volumeIcon")} />
    </eventbox>
  );
}

function BatteryInfo() {
  const bat = Battery.get_default();

  return (
    <icon
      className="icon"
      icon={bind(bat, "iconName")}
      iconSize={20}
      visible={bind(bat, "isPresent")}
      tooltipText={bind(bat, "percentage").as((p) => `${p}%`)}
    />
  );
}

function WifiIndicator() {
  const network = Network.get_default();
  const wifi = bind(network, "wifi");

  // return <icon className="icon" visible={wifi.as(Boolean)} icon={bind(wifi, "iconName")} />
  return (
    <box>
      {wifi.as(
        (wifi) =>
          wifi && (
            <icon
              className="icon"
              iconSize={20}
              icon={bind(wifi, "iconName")}
              tooltipText={bind(wifi, "ssid").as(String)}
            />
          ),
      )}
    </box>
  );
}

function WiredIndicator() {
  const network = Network.get_default();
  const wired = bind(network, "wired");

  return (
    <box>
      {wired.as(
        (wired) =>
          wired && <icon className="icon" icon={bind(wired, "iconName")} />,
      )}
    </box>
  );
}

function NetworkIndicator() {
  const network = Network.get_default();
  return (
    <stack
      visibleChildName={bind(network, "primary").as(
        (p) => p.toString() || "wifi",
      )}
    >
      <WifiIndicator name="wifi" />
      <WiredIndicator name="wired" />
    </stack>
  );
}

function Clock() {
  const time = Variable("").poll(
    1000,
    () => GLib.DateTime.new_now_local().format("%l:%M %p")!,
  );
  const date = Variable("").poll(
    1000,
    () => GLib.DateTime.new_now_local().format("%a, %b %d")!,
  );

  return (
    <box className="clock" vertical={true}>
      <label
        className="data"
        label={date()}
        xalign={1}
        onDestroy={() => time.drop()}
      />
      <label
        className="time"
        label={time()}
        xalign={1}
        onDestroy={() => date.drop()}
      />
    </box>
  );
}

export default function Bar(gdkmonitor: Gdk.Monitor) {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor;

  return (
    <window
      className="Bar"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | RIGHT}
      application={App}
    >
      <centerbox>
        <box spacing={8}>
          <Workspaces />
        </box>
        <box />
        <box spacing={8} halign={Gtk.Align.END}>
          <box className="grouping" spacing={0}>
            <SystemTray />
            <box spacing={8}>
              <VolumeInfo />
              <BatteryInfo />
              <NetworkIndicator />
            </box>
            <Clock />
          </box>
        </box>
      </centerbox>
    </window>
  );
}
