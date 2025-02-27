import { Variable, bind } from "astal";
import { Gtk } from "astal/gtk3";
import Hyprland from "gi://AstalHyprland";

const hyprland = Hyprland.get_default();

const appIcons = {
  "org.qutebrowser.qutebrowser": "",
  kitty: "",
  vesktop: "",
  Spotify: "",
  Code: "󰨞",
} as { [name: string]: string };

const WorkspaceIds = [1, 2, 3, 4, 5, 6, 7, 8, 9];

export default function Workspaces() {
  const wsClientVars = WorkspaceIds.reduce<{
    [id: number]: Variable<Hyprland.Client[]>;
  }>((o, id) => {
    const clients = hyprland.clients.filter((c) => c.workspace.id == id);
    return { ...o, [id]: Variable(clients) };
  }, {});

  // const clientStr = (client) =>
  //   `${client?.address} class=${client?.class} title=${client?.title}`;

  hyprland.connect("client-added", (_, client: Hyprland.Client) => {
    wsClientVars[client?.workspace.id].set([
      ...wsClientVars[client?.workspace.id].get(),
      client,
    ]);
  });
  hyprland.connect("client-removed", (_, address: string) => {
    for (const id in wsClientVars) {
      const idx = wsClientVars[id].get().findIndex((c) => c.address == address);
      if (idx < 0) continue;
      const copy = [...wsClientVars[id].get()];
      copy.splice(idx, 1);
      wsClientVars[id].set(copy);
      break;
    }
  });
  hyprland.connect("event", (self, name, data) => {
    if (name !== "movewindow2") return;
    const [address, wsIdStr] = data.split(",");
    const client = self.get_client("0x" + address);
    if (!client) {
      return;
    }
    const fromId = client.workspace.id;
    const toId = parseInt(wsIdStr);
    wsClientVars[fromId].set(
      wsClientVars[fromId].get().filter((c) => c.address != client.address),
    );
    wsClientVars[toId].set([...wsClientVars[toId].get(), client]);
  });

  const activeId = bind(hyprland.focused_workspace, "id");

  return (
    <box className="grouping" spacing={4}>
      {WorkspaceIds.map((id) => (
        <button
          className={bind(hyprland, "focusedWorkspace").as(
            (fw) => `workspace ws${id} ${fw.id === id ? "focused" : ""}`,
          )}
        >
          <box>
            <label className="label" label={id.toString()} />
            <box>
              {bind(wsClientVars[id]).as((clients) =>
                clients.map((c) => (
                  <label
                    className={`value${c.class}`}
                    label={appIcons[c.class] ?? `[${c.title}]`}
                  />
                )),
              )}
            </box>
          </box>
        </button>
      ))}
    </box>
  );
}
