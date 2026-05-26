import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { For, createBinding, onCleanup } from "ags"
import { execAsync } from "ags/process"
import { createPoll } from "ags/time"
import AstalTray from "gi://AstalTray"
import GLib from "gi://GLib"
import AstalWp from "gi://AstalWp"
import AstalMpris from "gi://AstalMpris"
import AstalApps from "gi://AstalApps"
import Workspaces from "./Workspaces.tsx"

function Mpris() {
  const mpris = AstalMpris.get_default()
  const apps = new AstalApps.Apps()
  const players = createBinding(mpris, "players")

  return (
    <box>
      <For each={players}>
        {(player) => {
          const [app] = apps.exact_query(player.entry)
          return (
            <box>
              <image
                class="music-icon"
                visible={!!app.iconName}
                iconName={app?.iconName}
              />
              <label
                class="music-paused-icon"
                label=""
                visible={createBinding(
                  player,
                  "playbackStatus",
                )((s) => s !== AstalMpris.PlaybackStatus.PLAYING)}
              />
              <label
                class="music-title"
                label={createBinding(player, "title")}
              />
              <label
                class="music-artist"
                label={createBinding(player, "artist")}
              />
            </box>
          )
        }}
      </For>
    </box>
  )
}

function SystemTray() {
  const tray = AstalTray.get_default()
  const items = createBinding(tray, "items")

  const init = (btn: Gtk.MenuButton, item: AstalTray.TrayItem) => {
    btn.menuModel = item.menuModel
    btn.insert_action_group("dbusmenu", item.actionGroup)
    item.connect("notify::action-group", () => {
      btn.insert_action_group("dbusmenu", item.actionGroup)
    })
  }

  return (
    <box class="system-tray" spacing={8}>
      <For each={items}>
        {(item) => (
          <menubutton $={(self) => init(self, item)}>
            <image gicon={createBinding(item, "gicon")} />
          </menubutton>
        )}
      </For>
    </box>
  )
}

function VolumeInfo() {
  const wp = AstalWp.get_default()
  const { default_speaker: speaker, default_microphone: microphone } = wp!

  return (
    <menubutton>
      <image class="icon" iconName={createBinding(speaker, "volumeIcon")} />
      <popover>
        <box orientation={Gtk.Orientation.VERTICAL}>
          <slider
            widthRequest={260}
            onChangeValue={({ value }) => speaker.set_volume(value)}
            value={createBinding(speaker, "volume")}
          />
          <box>
            <label class="icon speaker" label="󰓃" />
            <menubutton class="button speaker">
              <label
                label={createBinding(
                  speaker,
                  "description",
                )((d) => d ?? "<null>")}
              />
              <popover>
                <box orientation={Gtk.Orientation.VERTICAL}>
                  <For
                    each={createBinding(
                      wp,
                      "nodes",
                    )((nodes) =>
                      nodes.filter(
                        (node) =>
                          node.media_class == AstalWp.MediaClass.AUDIO_SINK,
                      ),
                    )}
                  >
                    {(node) => (
                      <button
                        onClicked={(self) =>
                          execAsync([
                            "wpctl",
                            "set-default",
                            node.id.toString(),
                          ]).catch((err) => console.error(err))
                        }
                      >
                        <box>
                          <image iconName={createBinding(node, "icon")} />
                          <label
                            label={createBinding(
                              node,
                              "description",
                            )((d) => d ?? "")}
                          />
                        </box>
                      </button>
                    )}
                  </For>
                </box>
              </popover>
            </menubutton>
          </box>
          <box>
            <label class="icon mic" label="" />
            <label
              label={createBinding(
                microphone,
                "description",
              )((d) => d ?? "<null>")}
            />
          </box>
        </box>
      </popover>
    </menubutton>
  )
}

function Clock() {
  const time = createPoll(
    "",
    1000,
    () => GLib.DateTime.new_now_local().format("%l:%M %p")!,
  )
  const date = createPoll(
    "",
    1000,
    () => GLib.DateTime.new_now_local().format("%a, %b %d")!,
  )

  return (
    <box class="clock" orientation={Gtk.Orientation.VERTICAL}>
      <label class="date" label={date} xalign={1} />
      <label class="time" label={time} xalign={1} />
    </box>
  )
}

export default function Bar({ gdkmonitor }: { gdkmonitor: Gdk.Monitor }) {
  let win: Astal.Window
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

  onCleanup(() => {
    // Root components (windows) are not automatically destroyed.
    // When the monitor is disconnected from the system, this callback
    // is run from the parent <For> which allows us to destroy the window.
    win.destroy()
  })

  return (
    <window
      $={(self) => (win = self)}
      visible
      namespace="ags-status-bar"
      name={`bar-${gdkmonitor.connector}`}
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | RIGHT}
      application={app}
    >
      <centerbox>
        <box $type="start">
          <Workspaces gdkmonitor={gdkmonitor} />
        </box>
        <box $type="center">
          <box class="grouping">
            <Mpris />
          </box>
        </box>
        <box $type="end">
          <box class="grouping">
            <SystemTray />
            <box class="system-info">
              <VolumeInfo />
            </box>
            <Clock />
          </box>
        </box>
      </centerbox>
    </window>
  )
}
