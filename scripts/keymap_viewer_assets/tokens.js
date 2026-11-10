/* Canonical physical strokes; unsupported notation retains its own identity. */
const KeyTokens = (() => {
  const shifted = '~!@#$%^&*()_+{}|:"<>?';
  const bases = "`1234567890-=[]\\;',./";
  const aliases = {
    cr: "Enter",
    return: "Enter",
    enter: "Enter",
    space: " ",
    tab: "Tab",
    esc: "Esc",
    escape: "Esc",
    bs: "Backspace",
    backspace: "Backspace",
    del: "Delete",
    delete: "Delete",
    ins: "Insert",
    insert: "Insert",
    home: "Home",
    end: "End",
    pageup: "PgUp",
    pagedown: "PgDn",
    pgup: "PgUp",
    pgdn: "PgDn",
    left: "Left",
    right: "Right",
    up: "Up",
    down: "Down",
    lt: "<",
    bslash: "\\",
    bar: "|",
  };
  const modifierNames = {
    c: "C",
    ctrl: "C",
    a: "A",
    m: "A",
    alt: "A",
    s: "S",
    shift: "S",
    d: "D",
    super: "D",
    cmd: "D",
  };
  const order = ["C", "A", "S", "D"];
  function stroke(key, modifiers = [], label = key, literal = true) {
    const mods = new Set(modifiers);
    if (/^[A-Z]$/.test(key)) {
      if (literal) mods.add("S");
      key = key.toLowerCase();
    }
    const index = shifted.indexOf(key);
    if (key.length === 1 && index >= 0) {
      key = bases[index];
      mods.add("S");
    }
    const sorted = order.filter((mod) => mods.has(mod));
    if (sorted.length === 1 && sorted[0] === "C") {
      const controlAlias = { i: "Tab", m: "Enter", "[": "Esc", h: "Backspace" }[key];
      if (controlAlias) return stroke(controlAlias, [], label);
    }
    return { key, mods: sorted, label, id: JSON.stringify([key, sorted]) };
  }
  function notation(raw) {
    let body = raw.slice(1, -1);
    const mods = [];
    while (/^[^-]+-/.test(body)) {
      const separator = body.indexOf("-");
      const mod = modifierNames[body.slice(0, separator).toLowerCase()];
      if (!mod) break;
      mods.push(mod);
      body = body.slice(separator + 1);
    }
    const lower = body.toLowerCase();
    if (lower === "nl" && mods.length === 0) return stroke("j", ["C"], raw);
    let key = aliases[lower] ||
      (/^f(?:[1-9]|[12][0-9]|3[0-7])$/.test(lower) ? lower.toUpperCase() : body);
    if (key.length !== 1 && !aliases[lower] && !/^F\d+$/.test(key)) {
      return { key: raw, mods: [], label: raw, id: `opaque:${raw}` };
    }
    // Neovim serializes control letters in upper case (<C-X> means Ctrl+x).
    return stroke(key, mods, raw, mods.length === 0);
  }
  function parse(sequence) {
    const tokens = [];
    for (let index = 0; index < sequence.length;) {
      const match = sequence.slice(index).match(/^<[^<>]+>/);
      const raw = match ? match[0] : String.fromCodePoint(sequence.codePointAt(index));
      tokens.push(match ? notation(raw) : stroke(raw, [], raw === " " ? "<Space>" : raw));
      index += raw.length;
    }
    return tokens;
  }
  return { parse, stroke };
})();
