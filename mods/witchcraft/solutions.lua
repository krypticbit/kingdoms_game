--
-- Define callbacks
--

local function register_solution(shortname, desc, tex)
   -- Register solution
   local bname = "witchcraft:beaker_" .. shortname
   witchcraft.solutions[bname] = shortname
   -- Register beaker
   witchcraft.register_beaker(shortname, desc, tex)
   -- Register cauldrons
   witchcraft.register_cauldron(shortname .. "1", {
      texture = tex,
      mesh = "cauldron_one_third.x",
   })
   witchcraft.register_cauldron(shortname .. "2", {
      texture = tex,
      mesh = "cauldron_two_thirds.x",
   })
   witchcraft.register_cauldron(shortname .. "3", {
      texture = tex,
      mesh = "cauldron_three_thirds.x",
   })
   -- Register put-take reactions
   witchcraft.register_put_take_reactions(shortname)
end

witchcraft.register_solution = register_solution

-- Base solution
register_solution("base", "Base Solution", "base_solution.png")
-- Slime
register_solution("slime", "Slime", "slime_solution.png")
-- Energized base
register_solution("energized_base", "Energized Base", "energized_base_solution.png")
-- Glycon brew
register_solution("glycon_brew", "Glycon Brew", "glycon_brew_solution.png")
-- Celros brew
register_solution("celros_brew", "Celros Brew", "celros_brew_solution.png")
-- Iceweed brew
register_solution("iceweed_brew", "Iceweed Brew", "iceweed_brew_solution.png")
-- Shal stalk brew
register_solution("shal_stalk_brew", "Shal Stalk Brew", "shal_stalk_brew_solution.png")
-- Boost solution
register_solution("boost", "Boost Solution", "boost_solution.png")

--
-- Potions
--

register_solution("healing_brew", "Healing Brew", "healing_brew_solution.png")
register_solution("fire_resistance", "Fire Resistance", "fire_resistance_solution.png")
register_solution("jump_boost", "Jump Boost", "jump_boost_solution.png")
register_solution("speed_boost", "Speed Boost", "speed_boost_solution.png")
