minetest.register_craftitem("seed_packets:seedpacket_wheat", {
	description = "Wheat Seed Packet",
	inventory_image = "seedpacket_wheat.png",
	groups = {flammable = 3},
})

minetest.register_craft({
	output = 'seed_packets:seedpacket_wheat',
	recipe = {
		{"farming:seed_wheat", "farming:seed_wheat", "farming:seed_wheat"},
		{"farming:seed_wheat", "farming:seed_wheat", "farming:seed_wheat"},
		{"farming:seed_wheat", "farming:seed_wheat", "farming:seed_wheat"},
	}
})

minetest.register_craft({
	output = "farming:seed_wheat 9",
	recipe = {
		{"seed_packets:seedpacket_wheat"}
	}
})
