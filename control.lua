require "data"

-- Each signaller updates once every 60 ticks (once per second). This could be
-- turned into a setting, but I'm not sure it's necessary.
local tick_rate = 60

script.on_init(function()
  global.signalers = {}
end)

function on_tick(event)
  for _id, signaller in pairs(global.signalers) do
    if event.tick % tick_rate == signaller.tick_offset then
      update_signaller(signaller.entity)
    end
  end
end

function find_ghosts(network)
  if not network then
    return {}
  end

  found = {}
  for _,cell in pairs(network.cells) do
    local pos = cell.owner.position
    local r = cell.construction_radius
    if r > 0 then
      -- I had a report of a crash because the bounds were zero-sized,
      -- presumably because of a zero radius. I tried a few things but I
      -- couldn't reproduce the problem, so for now I'm just guarding against it
      -- here. I'd like to know how it happens, though, since I may need to do
      -- something different in those cases.
      local bounds = { { pos.x - r, pos.y - r, }, { pos.x + r, pos.y + r } }
      local ghosts = cell.owner.surface.find_entities_filtered{area=bounds, type="entity-ghost", force=network.force}
      for _, ghost in pairs(ghosts) do
        -- bounds can overlap, so we need to dedup here to avoid requesting too much
        local is_dup = false
        for _, f in pairs(found) do
          if f == ghost then is_dup = true end
        end
        if not is_dup then
          table.insert(found, ghost)
        end
      end
    end
  end

  return found
end

function item_from_ghost(ghost)
  -- There can technically be multiple items that when placed create this ghost,
  -- so we just go with the first. I'm curious where this might be the wrong
  -- thing to do, and how I could fix it.
  items = ghost.ghost_prototype.items_to_place_this
  for name, _ in pairs(items) do
    return name
  end
end

function build_signals(ghosts)
  signals = {}
  for _, ghost in pairs(ghosts) do
    local existing = nil
    local name = item_from_ghost(ghost)
    for _, s in pairs(signals) do
      if s.signal.name == name then existing = s end
    end
    if not existing then
      existing = { signal = { type = "item", name = name }, count = 0, index = (#signals+1) }
      table.insert(signals, existing)
    end
    existing.count = existing.count + 1
  end
  return signals
end

function update_signaller(entity)
  local control = entity.get_or_create_control_behavior()
  if not control then return end
  local network = entity.surface.find_logistic_network_by_position(entity.position, entity.force)
  local ghosts = find_ghosts(network)
  local signals = build_signals(ghosts)
  control.parameters = { parameters=signals }
end

function on_entity_added(event)
  local entity = event.created_entity
  if entity.name == entity_name then
    global.signalers[entity.unit_number] = {
      entity = entity,
      tick_offset = event.tick % tick_rate,
    }
  end
end

function on_entity_removed(event)
  local entity = event.entity
  if entity.name == entity_name then
    global.signalers[entity.unit_number] = nil
  end
end

script.on_event(defines.events.on_tick, on_tick)

script.on_event(defines.events.on_entity_died, on_entity_removed)
script.on_event(defines.events.on_pre_player_mined_item, on_entity_removed)
script.on_event(defines.events.on_robot_pre_mined, on_entity_removed)
script.on_event(defines.events.on_built_entity, on_entity_added)
script.on_event(defines.events.on_robot_built_entity, on_entity_added)