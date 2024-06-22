import { Variable as Var } from "types/variable";
import { Client } from "types/service/hyprland";

const hyprland = await Service.import("hyprland");
const notifications = await Service.import("notifications");
const mpris = await Service.import("mpris");
const audio = await Service.import("audio");
const battery = await Service.import("battery");
const systemtray = await Service.import("systemtray");

const date = Variable("", {
  poll: [1000, 'date "+%H:%M:%S %b %e."'],
});

const appIcons = {
  "org.qutebrowser.qutebrowser": "",
  kitty: "",
  discord: "",
};

// widgets can be only assigned as a child in one container
// so to make a reuseable widget, make it a function
// then you can simply instantiate one by calling it

const WorkspaceIds = [1, 2, 3, 4, 5, 6, 7, 9];

function Workspaces() {
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
    // wsClientVars[client.workspace.id].value = wsClientVars[
    //   client.workspace.id
    // ].value.filter((c) => c.address != address);
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

  // const clients = hyprland.clients.filter((c) => c.workspace.id > 0);
  // const wsLabels = {};
  // for (const c of clients) {
  //   wsLabels[c.workspace.id] =
  //     (wsLabels[c.workspace.id] ?? "") + (appIcons[c.class] ?? `[${c.title}]`);
  // }

  const activeId = hyprland.active.workspace.bind("id");
  // const workspaces = hyprland.bind("workspaces").as((ws) =>
  //   ws.map(({ id }) =>
  //     Widget.Button({
  //       on_clicked: () => hyprland.messageAsync(`dispatch workspace ${id}`),
  //       child: Widget.Label(`${id} 󰖟`),
  //       class_name: activeId.as((i) => `${i === id ? "focused" : ""}`),
  //     }),
  //   ),
  // );

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
    class_name: "workspaces",
    children: workspaces,
  });
}

function ClientTitle() {
  return Widget.Label({
    class_name: "client-title",
    label: hyprland.active.client.bind("title"),
  });
}

function Clock() {
  return Widget.Label({
    class_name: "clock",
    label: date.bind(),
  });
}

// layout of the bar

function Left() {
  return Widget.Box({
    spacing: 8,
    children: [Workspaces(), ClientTitle()],
  });
}

function Right() {
  return Widget.Box({
    hpack: "end",
    spacing: 8,
    children: [Clock()],
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
