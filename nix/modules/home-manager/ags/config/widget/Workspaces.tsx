import { Gtk, Gdk } from "ags/gtk4"
import {
  For,
  With,
  createState,
  createBinding,
  createComputed,
  createMemo,
} from "ags"
import Hyprland from "gi://AstalHyprland"

const hyprland = Hyprland.get_default()

// application icons to use in workspace bar, keyed by app class
const appIcons = {
  "org.qutebrowser.qutebrowser": "",
  kitty: "",
  "org.wezfurlong.wezterm": "",
  vesktop: "",
  spotify: "",
  Code: "󰨞",
} as { [name: string]: string }

const WorkspaceIds = [1, 2, 3, 4, 5, 6, 7, 8, 9]

function ClientList({ workspace }: { workspace: Hyprland.Workspace }) {
  if (!workspace) {
    return <box />
  }

  return (
    <For each={createBinding(workspace, "clients")}>
      {(client) => <label label={client.title} />}
    </For>
  )
}

function WorkspaceButton({ id }: { id: number }) {
  const [clients, setClients] = createState(
    hyprland.get_workspace(id)?.clients ?? [],
  )

  // hyprland.connect("client-added", (_, client: Hyprland.Client) => {
  //   if (client.workspace.id != id) {
  //     return
  //   }
  //   client.connect("removed", (_) =>
  //     setClients((prev) => prev.filter((c) => c.address != client.address)),
  //   )
  //   client.connect("moved-to", (_, ws: Hyprland.Workspace) => )
  //   setClients((prev) => [...prev, client])
  // })

  return (
    <button>
      <box>
        <label label={id.toString()} />
        <box>
          <For each={clients}>{(client) => <label label={client.title} />}</For>
        </box>
      </box>
    </button>
  )
}

export default function Workspaces({
  gdkmonitor,
}: {
  gdkmonitor: Gdk.Monitor
}) {
  const monitorId = hyprland.get_monitor_by_name(gdkmonitor.connector).id
  const wsClients = WorkspaceIds.reduce((o, id) => {
    const clients = hyprland.get_workspace(id)?.clients ?? []
    const [getter, setter] = createState(clients)
    return { ...o, [id]: { get: getter, set: setter } }
  }, {})

  console.log(
    `wiring up events for monitor ${monitorId} -- ${gdkmonitor.connector}`,
  )
  hyprland.connect("client-added", (_, client: Hyprland.Client) => {
    console.log(
      `client "${client.title}" (${client.address}) added (on workspace ${client.workspace.id})`,
    )
    const wsId = client.workspace.id
    wsClients[wsId].set((prev) => [...prev, client])
  })
  hyprland.connect("client-removed", (_, address: string) => {
    console.log(`client ${address} removed`)
    for (const id in wsClients) {
      wsClients[id].set((prev) => prev.filter((c) => c.address != address))
    }
  })
  hyprland.connect(
    "client-moved",
    (_, client: Hyprland.Client, ws: Hyprland.Workspace) => {
      console.log(
        `client "${client.title}" (${client.address}) moved to workspace ${ws.id}`,
      )
      for (const id in wsClients) {
        wsClients[id].set((prev) => {
          const next = prev.filter((c) => c.address != client.address)
          if (id == ws.id) {
            return [...next, client]
          }
          return next
        })
      }
    },
  )

  const focusedWorkspace = createBinding(hyprland, "focusedWorkspace")

  return (
    <box class="grouping">
      {WorkspaceIds.map((id) => (
        <button
          class={createMemo(
            () =>
              `workspace ws${id} ${focusedWorkspace().id == id ? "focused" : ""}`,
          )}
        >
          <box>
            <label class="label" label={id.toString()} />
            <box>
              <For each={wsClients[id].get}>
                {(client) => (
                  <label
                    class={`value ${client.class} ${appIcons[client.class] ? "icon" : "text"}`}
                    label={appIcons[client.class] ?? `[${client.class}]`}
                  />
                )}
              </For>
            </box>
          </box>
        </button>
      ))}
    </box>
  )
}
