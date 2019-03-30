projectiles.register_shooter("long_rifle", {
   description = "Long Rifle",
   texture = "projectiles_long_rifle.png",
   damage = 5,
   range = 100,
   --ammo = "projectiles:rifle_ammo",
   rounds = 1,
   reload_speed = 2
})

projectiles.register_shooter("pistol", {
   description = "Pistol",
   texture = "projectiles_pistol.png",
   damage = 4,
   range = 40,
   --ammo = "projectiles:pistol_ammo",
   rounds = 6,
   reload_speed = 4
})
