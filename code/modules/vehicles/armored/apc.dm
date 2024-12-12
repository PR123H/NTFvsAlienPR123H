/obj/vehicle/sealed/armored/multitile/apc
	name = "\improper APC - Athena"
	desc = "An unarmed command APC designed to command and transport troops in the battlefield."
	icon = 'icons/obj/armored/3x3/apc.dmi'
	icon_state = "apc"
	damage_icon_path = 'icons/obj/armored/3x3/apc_damage_overlay.dmi'
	interior = /datum/interior/armored/transport
	armored_flags = ARMORED_HAS_HEADLIGHTS|ARMORED_PURCHASABLE_TRANSPORT
	permitted_weapons = list(/obj/item/armored_weapon/secondary_weapon)
	permitted_mods = list(/obj/item/tank_module/overdrive, /obj/item/tank_module/ability/zoom, /obj/item/tank_module/interior/medical, /obj/item/tank_module/interior/clone_bay)
	minimap_icon_state = "apc"
	turret_icon = null
	pixel_x = -48
	pixel_y = -40
	max_integrity = 900
	soft_armor = list(MELEE = 40, BULLET = 100 , LASER = 90, ENERGY = 60, BOMB = 60, BIO = 60, FIRE = 40, ACID = 40)
	max_occupants = 20 //Clown car? Clown car.
	enter_delay = 0.5 SECONDS
	ram_damage = 50
	move_delay = 0.4 SECONDS
	easy_load_list = list(
		/obj/item/ammo_magazine/tank,
		/obj/structure/largecrate,
		/obj/structure/closet/crate,
	)
