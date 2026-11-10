"use strict";
const mappings = JSON.parse(document.getElementById("mapping-data").textContent).map((
  row,
  index,
) => ({
  ...row,
  index,
  tokens: KeyTokens.parse(row.lhs),
  search: Object.values(row).join("\n").toLowerCase(),
}));
const $ = (id) => document.getElementById(id);
const PAGE_SIZE = 100;
const state = { prefix: [], modifiers: new Set(), selected: null, page: 0, filtered: mappings };
const modeNames = {
  n: "Normal",
  x: "Visual",
  s: "Select",
  o: "Operator-pending",
  i: "Insert",
  l: "Language",
  c: "Command-line",
  t: "Terminal",
};
const modifierLabels = { C: "Ctrl", A: "Alt", S: "Shift", D: "Super" };
const keyButtons = [];
const modifierButtons = [];
function element(tag, text, className) {
  const node = document.createElement(tag);
  if (text !== undefined) node.textContent = text;
  if (className) node.className = className;
  return node;
}
function button(text, action, className) {
  const node = element("button", text, className);
  node.type = "button";
  node.addEventListener("click", action);
  return node;
}
function option(select, value, text) {
  const node = element("option", text);
  node.value = value;
  select.append(node);
}
function toggleModifier(mod) {
  if (state.modifiers.has(mod)) state.modifiers.delete(mod);
  else state.modifiers.add(mod);
  renderBreadcrumbs();
  renderKeyboard();
}
function modifierButton(mod, className) {
  const node = button(modifierLabels[mod], () => toggleModifier(mod), className);
  node.setAttribute("aria-label", `Toggle ${modifierLabels[mod]} modifier`);
  modifierButtons.push({ node, mod });
  return node;
}
function buildKeyboard() {
  const rows = [
    ["Esc", ...Array.from({ length: 12 }, (_, i) => `F${i + 1}`), "Insert", "Home", "PgUp"],
    [..."`1234567890-=", ["Backspace", 2], "Delete", "End", "PgDn"],
    [["Tab", 1.5], ..."qwertyuiop[]\\"],
    [["CapsLock", 1.8], ..."asdfghjkl;'", ["Enter", 2.2]],
    [{ mod: "S", width: 2.2 }, ..."zxcvbnm,./", { mod: "S", width: 2.2 }, "Up"],
    [
      { mod: "C" },
      { mod: "D" },
      { mod: "A" },
      [" ", 6],
      { mod: "A" },
      { mod: "C" },
      "Left",
      "Down",
      "Right",
    ],
  ];
  for (const row of rows) {
    const container = element("div", undefined, "key-row");
    for (const spec of row) {
      const [key, width] = Array.isArray(spec) ? spec : [spec, 1];
      if (typeof key === "object") {
        const node = modifierButton(key.mod, "key");
        node.style.setProperty("--width", key.width || 1);
        container.append(node);
        continue;
      }
      const node = button(
        "",
        () => appendToken(KeyTokens.stroke(key, [...state.modifiers])),
        "key",
      );
      node.style.setProperty("--width", width);
      keyButtons.push({ node, key });
      container.append(node);
    }
    $("keyboard").append(container);
  }
  for (const mod of Object.keys(modifierLabels)) $("modifiers").append(modifierButton(mod));
}
function matchesPrefix(row) {
  return state.prefix.every((token, index) => row.tokens[index]?.id === token.id);
}
function appendToken(token) {
  state.prefix.push(token);
  state.modifiers.clear();
  applyFilters();
}
function setPrefix(tokens) {
  state.prefix = tokens.slice();
  state.modifiers.clear();
  applyFilters();
}
function continuationCounts() {
  const next = new Map();
  let complete = 0;
  for (const row of state.filtered) {
    if (!matchesPrefix(row)) continue;
    const token = row.tokens[state.prefix.length];
    if (!token) {
      complete++;
      continue;
    }
    const entry = next.get(token.id) || { token, count: 0 };
    entry.count++;
    next.set(token.id, entry);
  }
  return { next, complete };
}
function keyLabel(token) {
  const display = token.key === " " ? "Space" : token.key;
  return [...token.mods.map((mod) => modifierLabels[mod]), display].join("+");
}
function renderKeyboard() {
  const { next, complete } = continuationCounts();
  const selected = state.selected === null ? [] : mappings[state.selected].tokens;
  for (const { node, mod } of modifierButtons) {
    node.setAttribute("aria-pressed", String(state.modifiers.has(mod)));
  }
  for (const { node, key } of keyButtons) {
    const token = KeyTokens.stroke(key, [...state.modifiers]);
    const count = next.get(token.id)?.count || 0;
    const label = keyLabel(token);
    node.replaceChildren(element("span", label));
    if (count) node.append(element("span", String(count), "key-count"));
    node.classList.toggle("has-next", count > 0);
    node.classList.toggle("traced", selected.some((item) => item.key === key));
    node.setAttribute("aria-label", `${label}: ${count} next mappings`);
    node.title = `${label} · ${count} continuations`;
  }
  $("continuations").replaceChildren();
  for (const { token, count } of next.values()) {
    $("continuations").append(button(`${token.label} · ${count}`, () => appendToken(token)));
  }
  $("prefix-status").textContent =
    `${complete} mappings end here · ${next.size} distinct next tokens (all modifiers, including nonphysical keys)`;
}
function renderBreadcrumbs() {
  const nav = $("breadcrumbs");
  nav.replaceChildren(button("Root", () => setPrefix([])));
  state.prefix.forEach((token, index) => {
    nav.append(
      element("span", "›"),
      button(token.label, () => setPrefix(state.prefix.slice(0, index + 1))),
    );
  });
  $("back").disabled = state.prefix.length === 0;
  $("reset").disabled = state.prefix.length === 0 && state.modifiers.size === 0;
}
function selectMapping(row) {
  state.selected = row.index;
  $("detail").hidden = false;
  $("detail-title").textContent = `${modeNames[row.mode]} · ${row.lhs}`;
  $("fields").replaceChildren();
  for (
    const name of Object.keys(row).filter((name) => !["index", "tokens", "search"].includes(name))
  ) {
    $("fields").append(
      element("dt", name),
      element("dd", row[name] === "" ? "(empty)" : row[name]),
    );
  }
  renderKeyboard();
  renderRows();
}
function renderRows() {
  const total = state.filtered.length;
  const pages = Math.max(1, Math.ceil(total / PAGE_SIZE));
  state.page = Math.min(state.page, pages - 1);
  const start = state.page * PAGE_SIZE;
  const fragment = document.createDocumentFragment();
  for (const row of state.filtered.slice(start, start + PAGE_SIZE)) {
    const tr = element("tr");
    tr.classList.toggle("selected", row.index === state.selected);
    tr.classList.toggle("prefix-match", matchesPrefix(row));
    tr.setAttribute("aria-selected", String(row.index === state.selected));
    const mode = element("td", `${matchesPrefix(row) ? "● " : ""}${row.mode}`);
    mode.title = modeNames[row.mode];
    const lhs = element("td");
    const select = button(row.lhs, () => selectMapping(row));
    select.setAttribute("aria-label", `Inspect ${modeNames[row.mode]} mapping ${row.lhs}`);
    lhs.append(select);
    tr.append(mode, lhs);
    for (
      const text of [
        row.description || row.rhs || row.callback || "(empty action)",
        row.scope === "global" ? "global" : `buffer ${row.buffer}`,
        row.source || "(unknown)",
      ]
    ) {
      const td = element("td");
      td.append(element("span", text, "cell-text"));
      tr.append(td);
    }
    fragment.append(tr);
  }
  $("rows").replaceChildren(fragment);
  $("empty").hidden = total !== 0;
  $("count").textContent = `${total} / ${mappings.length} mappings`;
  $("page").textContent = `${total ? start + 1 : 0}–${
    Math.min(start + PAGE_SIZE, total)
  } of ${total} · Page ${state.page + 1}/${pages}`;
  $("previous").disabled = state.page === 0;
  $("next").disabled = state.page + 1 >= pages;
}
function render() {
  renderBreadcrumbs();
  renderKeyboard();
  renderRows();
}
function applyFilters() {
  const query = $("search").value.toLowerCase();
  state.filtered = mappings.filter((row) =>
    row.search.includes(query) &&
    (!$("mode").value || row.mode === $("mode").value) &&
    (!$("scope").value || row.scope === $("scope").value) &&
    (!$("buffer").value || row.buffer === $("buffer").value) &&
    matchesPrefix(row)
  );
  if (state.selected !== null && !state.filtered.some((row) => row.index === state.selected)) {
    state.selected = null;
    $("detail").hidden = true;
    $("fields").replaceChildren();
  }
  state.page = 0;
  render();
}
$("total").textContent = String(mappings.length);
for (const [mode, name] of Object.entries(modeNames)) option($("mode"), mode, `${mode} · ${name}`);
const buffers = new Map(mappings.map((row) => [row.buffer, row.buffer_name]));
for (const [id, name] of [...buffers].sort((a, b) => Number(a[0]) - Number(b[0]))) {
  option($("buffer"), id, id === "0" ? "0 · global" : `${id} · ${name || "(unnamed)"}`);
}
let searchTimer;
$("search").addEventListener("input", () => {
  clearTimeout(searchTimer);
  searchTimer = setTimeout(applyFilters, 100);
});
for (const id of ["mode", "scope", "buffer"]) $(id).addEventListener("change", applyFilters);
$("back").addEventListener("click", () => setPrefix(state.prefix.slice(0, -1)));
$("reset").addEventListener("click", () => setPrefix([]));
$("previous").addEventListener("click", () => {
  state.page--;
  renderRows();
});
$("next").addEventListener("click", () => {
  state.page++;
  renderRows();
});
buildKeyboard();
render();
