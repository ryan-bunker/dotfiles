const f = "_bar_otxuu_7", v = "_workspace_otxuu_24", k = "_grouping_otxuu_34", h = "_notification_otxuu_43", y = "_ws1_otxuu_55", W = "_focused_otxuu_59", I = "_ws2_otxuu_63", $ = "_ws3_otxuu_71", B = "_ws4_otxuu_79", S = "_ws5_otxuu_87", C = "_ws6_otxuu_95", L = "_ws7_otxuu_103", V = "_ws8_otxuu_111", z = "_ws9_otxuu_119", A = "_label_otxuu_132", M = "_value_otxuu_137", j = "_icon_otxuu_151", q = "_clock_otxuu_158", N = "_date_otxuu_162", D = "_time_otxuu_167", i = {
  bar: f,
  workspace: v,
  grouping: k,
  notification: h,
  ws1: y,
  focused: W,
  ws2: I,
  ws3: $,
  ws4: B,
  ws5: S,
  ws6: C,
  ws7: L,
  ws8: V,
  ws9: z,
  label: A,
  value: M,
  "system-tray": "_system-tray_otxuu_144",
  icon: j,
  clock: q,
  date: N,
  time: D
}, _ = await Service.import("hyprland"), E = {
  "org.qutebrowser.qutebrowser": "",
  kitty: "",
  discord: ""
}, b = [1, 2, 3, 4, 5, 6, 7, 9];
function O() {
  const t = b.reduce(
    (e, s) => {
      const o = _.clients.filter((a) => a.workspace.id == s);
      return { ...e, [s]: Variable(o) };
    },
    {}
  ), c = (e) => `${e == null ? void 0 : e.address} class=${e == null ? void 0 : e.class} title=${e == null ? void 0 : e.title}`;
  _.connect("client-added", (e, s) => {
    print("client added:", s);
    const o = e.getClient(s);
    print("client:", c(o)), o && (t[o == null ? void 0 : o.workspace.id].value = [
      ...t[o == null ? void 0 : o.workspace.id].value,
      o
    ]);
  }), _.connect("client-removed", (e, s) => {
    print("client removed:", s);
    for (const o of Object.keys(t)) {
      const a = t[o].value.findIndex(
        (p) => p.address == s
      );
      if (a < 0) continue;
      const r = [...t[o].value];
      r.splice(a, 1), t[o].value = r;
      break;
    }
  }), _.connect("event", (e, s, o) => {
    if (s != "movewindowv2") return;
    const [a, r, p] = o.split(",");
    print("window moved:", a, r, p);
    const n = e.getClient("0x" + a);
    if (print(
      "client:",
      c(n),
      `from=${n == null ? void 0 : n.workspace.id}`,
      `to=${r}`
    ), !n)
      return;
    const m = n.workspace.id;
    t[m].value = t[m].value.filter(
      (x) => x.address != (n == null ? void 0 : n.address)
    ), t[r].value = [...t[r].value, n];
  });
  const w = _.active.workspace.bind("id"), d = b.map(
    (e) => Widget.Button({
      child: Widget.Box({
        children: [
          Widget.Label({
            label: `${e}`,
            class_name: i.label
          }),
          Widget.Label({
            label: t[e].bind().as(
              (s) => s.map((o) => E[o.class] ?? `[${o.title}]`).join("")
            ),
            class_name: i.value
          })
        ]
      }),
      class_names: w.as((s) => [
        i.workspace,
        i[`ws${e}`],
        `${s === e ? i.focused : ""}`
      ])
    })
  );
  return Widget.Box({
    class_names: [i.grouping],
    spacing: 4,
    children: d
  });
}
const g = await Service.import("audio"), u = await Service.import("battery"), R = await Service.import("systemtray"), l = await Service.import("network"), T = Variable("", {
  poll: [1e3, "date '+%a, %b %d'"]
}), F = Variable("", {
  poll: [1e3, "date '+%l:%M %p'"]
}), G = () => Widget.Box({
  class_name: i["system-tray"],
  spacing: 8,
  children: R.bind("items").as(
    (t) => t.map(
      (c) => Widget.Button({
        child: Widget.Icon({ size: 20 }).bind("icon", c, "icon"),
        tooltipMarkup: c.bind("tooltip_markup"),
        // onPrimaryClick: item.is_menu
        //   ? undefined
        //   : (_, event) => item.activate(event),
        onSecondaryClick: (w, d) => c.openMenu(d)
      })
    )
  )
}), H = () => Widget.EventBox({
  child: Widget.Icon({ size: 20, class_name: i.icon }).hook(g.speaker, (t) => {
    var d;
    const c = g.speaker.volume * 100, w = (d = [
      { t: 101, i: "oversimplified" },
      { t: 67, i: "high" },
      { t: 32, i: "medium" },
      { t: 1, i: "low" },
      { t: 0, i: "muted" }
    ].find(({ t: e }) => e <= c)) == null ? void 0 : d.i;
    g.speaker.is_muted ? t.icon = "audio-volume-muted-symbolic" : t.icon = `audio-volume-${w}-symbolic`;
  })
}), J = () => Widget.Icon({
  class_name: i.icon,
  icon: u.bind("icon_name"),
  size: 20,
  visible: u.bind("available")
}).hook(u, (t) => {
  t.tooltip_text = `${u.percent}%`, u.charging ? t.tooltip_text += " (charging)" : u.charged && (t.tooltip_text += " (charged)");
}), K = () => Widget.Icon({
  class_name: i.icon,
  icon: l.wifi.bind("icon_name"),
  size: 20
}).hook(
  l.wifi,
  (t) => {
    t.tooltip_text = `${l.wifi.ssid} (${l.wifi.strength} dB)`;
  },
  "changed"
), P = () => Widget.Icon({
  class_name: i.icon,
  icon: l.wired.bind("icon_name")
}), Q = () => Widget.Stack({
  children: {
    wifi: K(),
    wired: P()
  },
  shown: l.bind("primary").as((t) => t || "wifi")
});
function U() {
  return Widget.Box({
    class_name: i.clock,
    vertical: !0,
    children: [
      Widget.Label({
        class_name: i.date,
        label: T.bind(),
        xalign: 1
      }),
      Widget.Label({
        class_name: i.time,
        label: F.bind(),
        xalign: 1
      })
    ]
  });
}
function X() {
  return Widget.Box({
    class_name: i.grouping,
    spacing: 0,
    children: [
      G(),
      Widget.Box({
        spacing: 8,
        children: [H(), J(), Q()]
      }),
      U()
    ]
  });
}
function Y() {
  return Widget.Box({
    spacing: 8,
    children: [O()]
  });
}
function Z() {
  return Widget.Box({
    hpack: "end",
    spacing: 8,
    children: [X()]
  });
}
function tt(t = 0) {
  return Widget.Window({
    name: `ags-status-bar-${t}`,
    // name has to be unique
    class_name: i.bar,
    monitor: t,
    anchor: ["top", "left", "right"],
    exclusivity: "exclusive",
    child: Widget.CenterBox({
      start_widget: Y(),
      end_widget: Z()
    })
  });
}
const et = App.configDir + "/style.css";
App.config({
  style: et,
  windows: [tt()]
});
