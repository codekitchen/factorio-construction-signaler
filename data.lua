local entity_name = "combinator-construction"

local entity = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
entity.name = entity_name
entity.minable.result = entity_name

local item = table.deepcopy(data.raw.item["constant-combinator"])
item.name = entity_name
item.place_result = entity_name
item.localised_name = entity.localised_name

local recipe = table.deepcopy(data.raw.recipe["constant-combinator"])
recipe.name = entity_name
recipe.result = entity_name
table.insert(recipe.ingredients, {"advanced-circuit", 5})

local tech = table.deepcopy(data.raw.technology["circuit-network"])
tech.name = entity_name
tech.prerequisites = {"circuit-network", "construction-robotics"}
tech.effects = { {type="unlock-recipe", recipe=recipe.name } }
tech.unit.count = math.floor(tech.unit.count*2.0)

data:extend{entity, item, recipe, tech}