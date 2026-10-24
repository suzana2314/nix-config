local applied = {}

local function refresh(opts)
  opts = opts or {}
  local tiled, candidates, seen = {}, {}, {}

  local function is_pseudo(class)
    for _, c in ipairs(PSEUDO_CLASSES) do
      if c == class then return true end
    end
    return false
  end

  local function add(w)
    local addr = w.address
    if seen[addr] or addr == opts.exclude then return end
    seen[addr] = true

    local ws_id = w.workspace and w.workspace.id
    if opts.move and opts.move.address == addr then ws_id = opts.move.ws_id end
    if ws_id == nil then return end

    local special = is_pseudo(w.class)
    if w.floating then
      applied[addr] = nil
      return
    end

    tiled[ws_id] = (tiled[ws_id] or 0) + 1
    if special then table.insert(candidates, { w = w, ws_id = ws_id }) end
  end

  for _, w in ipairs(hl.get_windows()) do add(w) end
  if opts.include then add(opts.include) end

  for _, c in ipairs(candidates) do
    local want = (tiled[c.ws_id] == 1)
    if applied[c.w.address] ~= want then
      applied[c.w.address] = want
      hl.dispatch(hl.dsp.window.pseudo({ action = want and "enable" or "disable", window = c.w }))
    end
  end
end

hl.on("window.open", function(w) refresh({ include = w }) end)
hl.on("window.close", function(w) applied[w.address] = nil; refresh({ exclude = w.address }) end)
hl.on("window.move_to_workspace", function(w, ws) refresh({ move = { address = w.address, ws_id = ws.id } }) end)
hl.on("config.reloaded", function() refresh() end)
