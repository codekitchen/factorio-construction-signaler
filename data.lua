local entity_name = "combinator-construction"

local entity = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
entity.name = entity_name
entity.minable.result = entity_name
entity.icon = "__ConstructionSignaler__/graphics/icons/construction-signaler.png"
entity.icon_size = 32
entity.sprites = make_4way_animation_from_spritesheet(
  { layers =
    {
      {
        filename = "__ConstructionSignaler__/graphics/entity/construction-signaler.png",
        width = 58,
        height = 52,
        frame_count = 1,
        shift = util.by_pixel(0, 5),
        hr_version =
        {
          scale = 0.5,
          filename = "__ConstructionSignaler__/graphics/entity/hr-construction-signaler.png",
          width = 114,
          height = 102,
          frame_count = 1,
          shift = util.by_pixel(0, 5),
        },
      },
      {
        filename = "__base__/graphics/entity/combinator/constant-combinator-shadow.png",
        width = 50,
        height = 34,
        frame_count = 1,
        shift = util.by_pixel(9, 6),
        draw_as_shadow = true,
        hr_version =
        {
          scale = 0.5,
          filename = "__base__/graphics/entity/combinator/hr-constant-combinator-shadow.png",
          width = 98,
          height = 66,
          frame_count = 1,
          shift = util.by_pixel(8.5, 5.5),
          draw_as_shadow = true,
        },
      },
    },
  })
entity.item_slot_count = 1000 -- default constant-combinator 50 slots can easily overflow and crash

local item = table.deepcopy(data.raw.item["constant-combinator"])
item.name = entity_name
item.place_result = entity_name
item.localised_name = entity.localised_name
item.icon = "__ConstructionSignaler__/graphics/icons/construction-signaler.png"
item.icon_size = 32

local recipe = table.deepcopy(data.raw.recipe["constant-combinator"])
recipe.name = entity_name
recipe.result = entity_name
table.insert(recipe.ingredients, {"advanced-circuit", 5})
recipe.icon = "__ConstructionSignaler__/graphics/icons/construction-signaler.png"
recipe.icon_size = 32

local tech = table.deepcopy(data.raw.technology["circuit-network"])
tech.name = entity_name
tech.prerequisites = {"circuit-network", "construction-robotics"}
tech.effects = { {type="unlock-recipe", recipe=recipe.name } }
tech.unit.count = math.floor(tech.unit.count*2.0)
tech.icon = "__ConstructionSignaler__/graphics/tech/construction-signaler.png"
tech.icon_size = 64

data:extend{entity, item, recipe, tech}