const v = "_bar_1bt7o_7", k = "_workspace_1bt7o_24", h = "_grouping_1bt7o_34", y = "_notification_1bt7o_43", W = "_ws1_1bt7o_55", x = "_focused_1bt7o_59", I = "_ws2_1bt7o_63", $ = "_ws3_1bt7o_71", B = "_ws4_1bt7o_79", S = "_ws5_1bt7o_87", C = "_ws6_1bt7o_95", L = "_ws7_1bt7o_103", V = "_ws8_1bt7o_111", z = "_ws9_1bt7o_119", A = "_label_1bt7o_132", M = "_value_1bt7o_137", j = "_clock_1bt7o_154", q = "_date_1bt7o_158", N = "_time_1bt7o_165", i = {
  bar: v,
  workspace: k,
  grouping: h,
  notification: y,
  ws1: W,
  focused: x,
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
  "system-tray": "_system-tray_1bt7o_144",
  clock: j,
  date: q,
  time: N
}, w = await Service.import("hyprland"), D = {
  "org.qutebrowser.qutebrowser": "",
  kitty: "",
  vesktop: "",
  Spotify: ""
}, m = [1, 2, 3, 4, 5, 6, 7, 9];
function E() {
  const t = m.reduce(
    (e, s) => {
      const o = w.clients.filter((c) => c.workspace.id == s);
      return { ...e, [s]: Variable(o) };
    },
    {}
  ), a = (e) => `${e == null ? void 0 : e.address} class=${e == null ? void 0 : e.class} title=${e == null ? void 0 : e.title}`;
  w.connect("client-added", (e, s) => {
    print("client added:", s);
    const o = e.getClient(s);
    print("client:", a(o)), o && (t[o == null ? void 0 : o.workspace.id].value = [
      ...t[o == null ? void 0 : o.workspace.id].value,
      o
    ]);
  }), w.connect("client-removed", (e, s) => {
    print("client removed:", s);
    for (const o of Object.keys(t)) {
      const c = t[o].value.findIndex(
        (u) => u.address == s
      );
      if (c < 0) continue;
      const r = [...t[o].value];
      r.splice(c, 1), t[o].value = r;
      break;
    }
  }), w.connect("event", (e, s, o) => {
    if (s != "movewindowv2") return;
    const [c, r, u] = o.split(",");
    print("window moved:", c, r, u);
    const n = e.getClient("0x" + c);
    if (print(
      "client:",
      a(n),
      `from=${n == null ? void 0 : n.workspace.id}`,
      `to=${r}`
    ), !n)
      return;
    const g = n.workspace.id;
    t[g].value = t[g].value.filter(
      (f) => f.address != (n == null ? void 0 : n.address)
    ), t[r].value = [...t[r].value, n];
  });
  const p = w.active.workspace.bind("id"), d = m.map(
    (e) => Widget.Button({
      child: Widget.Box({
        children: [
          Widget.Label({
            label: `${e}`,
            class_name: i.label
          }),
          Widget.Label({
            label: t[e].bind().as(
              (s) => s.map((o) => D[o.class] ?? `[${o.title}]`).join("")
            ),
            class_name: i.value
          })
        ]
      }),
      class_names: p.as((s) => [
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
const b = await Service.import("audio"), l = await Service.import("battery"), O = await Service.import("systemtray"), _ = await Service.import("network"), R = Variable("", {
  poll: [1e3, "date '+%a, %b %d'"]
}), T = Variable("", {
  poll: [1e3, "date '+%l:%M %p'"]
}), F = () => Widget.Box({
  class_name: i["system-tray"],
  spacing: 8,
  children: O.bind("items").as(
    (t) => t.map(
      (a) => Widget.Button({
        child: Widget.Icon({ size: 20 }).bind("icon", a, "icon"),
        tooltipMarkup: a.bind("tooltip_markup"),
        // onPrimaryClick: item.is_menu
        //   ? undefined
        //   : (_, event) => item.activate(event),
        onSecondaryClick: (p, d) => a.openMenu(d)
      })
    )
  )
}), G = () => Widget.EventBox({
  child: Widget.Icon({ size: 20, class_name: i.icon ?? "" }).hook(
    b.speaker,
    (t) => {
      var d;
      const a = b.speaker.volume * 100, p = (d = [
        { t: 101, i: "oversimplified" },
        { t: 67, i: "high" },
        { t: 32, i: "medium" },
        { t: 1, i: "low" },
        { t: 0, i: "muted" }
      ].find(({ t: e }) => e <= a)) == null ? void 0 : d.i;
      b.speaker.is_muted ? t.icon = "audio-volume-muted-symbolic" : t.icon = `audio-volume-${p}-symbolic`;
    }
  )
}), H = () => Widget.Icon({
  class_name: i.icon ?? "",
  icon: l.bind("icon_name"),
  size: 20,
  visible: l.bind("available")
}).hook(l, (t) => {
  t.tooltip_text = `${l.percent}%`, l.charging ? t.tooltip_text += " (charging)" : l.charged && (t.tooltip_text += " (charged)");
}), J = () => Widget.Icon({
  class_name: i.icon ?? "",
  icon: _.wifi.bind("icon_name"),
  size: 20
}).hook(
  _.wifi,
  (t) => {
    t.tooltip_text = `${_.wifi.ssid} (${_.wifi.strength} dB)`;
  },
  "changed"
), K = () => Widget.Icon({
  class_name: i.icon ?? "",
  icon: _.wired.bind("icon_name")
}), P = () => Widget.Stack({
  children: {
    wifi: J(),
    wired: K()
  },
  shown: _.bind("primary").as((t) => t || "wifi")
});
function Q() {
  return Widget.Box({
    class_name: i.clock,
    vertical: !0,
    children: [
      Widget.Label({
        class_name: i.date,
        label: R.bind(),
        xalign: 1
      }),
      Widget.Label({
        class_name: i.time,
        label: T.bind(),
        xalign: 1
      })
    ]
  });
}
function U() {
  return Widget.Box({
    class_name: i.grouping,
    spacing: 0,
    children: [
      F(),
      Widget.Box({
        spacing: 8,
        children: [G(), H(), P()]
      }),
      Q()
    ]
  });
}
function X() {
  return Widget.Box({
    spacing: 8,
    children: [E()]
  });
}
function Y() {
  return Widget.Box({
    hpack: "end",
    spacing: 8,
    children: [U()]
  });
}
function Z(t = 0) {
  return Widget.Window({
    name: `ags-status-bar-${t}`,
    // name has to be unique
    class_name: i.bar,
    monitor: t,
    anchor: ["top", "left", "right"],
    exclusivity: "exclusive",
    child: Widget.CenterBox({
      start_widget: X(),
      end_widget: Y()
    })
  });
}
const tt = App.configDir + "/style.css";
App.config({
  style: tt,
  windows: [Z()]
});
