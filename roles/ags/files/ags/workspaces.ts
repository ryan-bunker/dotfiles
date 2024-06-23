import { Variable as Var } from "types/variable";
import { Client } from "types/service/hyprland";

const hyprland = await Service.import("hyprland");

const appIcons = {
  "org.qutebrowser.qutebrowser": "",
  kitty: "",
  discord: "",
};

const WorkspaceIds = [1, 2, 3, 4, 5, 6, 7, 9];

export default function Workspaces() {
  const wsClientVars = WorkspaceIds.reduce(
    (o: { [id: number]: Var<Client[]> }, id: number) => {
      const clients = hyprland.clients.filter((c) => c.workspace.id == id);
      return { ...o, [id]: Variable(clients) };
    },
    {},
  );

  const clientStr = (client?: Client) =>
    `${client?.address} class=${client?.class} title=${client?.title}`;

  hyprland.connect("client-added", (self, address: string) => {
    print("client added:", address);
    const client = self.getClient(address);
    print("client:", clientStr(client));
    if (!client) {
      return;
    }
    wsClientVars[client?.workspace.id].value = [
      ...wsClientVars[client?.workspace.id].value,
      client,
    ];
  });
  hyprland.connect("client-removed", (_, address: string) => {
    print("client removed:", address);
    for (const id of Object.keys(wsClientVars)) {
      const idx = wsClientVars[id].value.findIndex(
        (c: Client) => c.address == address,
      );
      if (idx < 0) continue;
      const copy: Client[] = [...wsClientVars[id].value];
      copy.splice(idx, 1);
      wsClientVars[id].value = copy;
      break;
    }
  });
  hyprland.connect("event", (self, name: string, data: string) => {
    if (name != "movewindowv2") return;
    const [address, wsId, wsName] = data.split(",");
    print("window moved:", address, wsId, wsName);
    const client = self.getClient("0x" + address);
    print(
      "client:",
      clientStr(client),
      `from=${client?.workspace.id}`,
      `to=${wsId}`,
    );
    if (!client) {
      return;
    }
    const fromId = client.workspace.id;
    wsClientVars[fromId].value = wsClientVars[fromId].value.filter(
      (c) => c.address != client?.address,
    );
    wsClientVars[wsId].value = [...wsClientVars[wsId].value, client];
  });

  const activeId = hyprland.active.workspace.bind("id");

  const workspaces = WorkspaceIds.map((id: number) =>
    Widget.Button({
      child: Widget.Box({
        children: [
          Widget.Label({
            label: `${id}`,
            class_name: "label",
          }),
          Widget.Label({
            label: wsClientVars[id]
              .bind()
              .as((clients) =>
                clients
                  .map((c) => appIcons[c.class] ?? `[${c.title}]`)
                  .join(""),
              ),
            class_name: "value",
          }),
        ],
      }),
      class_name: activeId.as((i) =>
        ["workspace", `ws${id}`, `${i === id ? "focused" : ""}`].join(" "),
      ),
    }),
  );

  return Widget.Box({
    class_name: "workspaces grouping",
    children: workspaces,
  });
}
