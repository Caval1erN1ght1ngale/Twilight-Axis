
/obj/projectile/bullet/shell_shrapnel
	name = "bullet"
	icon_state = "bullet"
	damage = 25
	damage_type = BRUTE
	flag = "piercing"
	hitsound_wall = "ricochet"
	ricochet_chance = 85
	ricochets_max = 3

/obj/item/artillery_shell/mortar
	name = "Снаряд мортиры"
	sellprice = 50

/obj/item/artillery_shell/shell_action()
	var/turf/T = GET_TURF_ABOVE(get_turf(src))
	while(GET_TURF_ABOVE(T))
		T = GET_TURF_ABOVE(T)

	if(!T)
		T = get_turf(src)

	while(GET_TURF_BELOW(T) && istype(T, /turf/open/transparent))
		T = GET_TURF_BELOW(T)
	
	playsound(src, 'modular_twilight_axis/awful_artillery/sound/fallingonyou.ogg', 100, 0, 10, 1, null, null, FALSE, TRUE)
	sleep(0.5 SECONDS)

	for(var/mob/M in GLOB.player_list)
		M.playsound_local(src, 'modular_twilight_axis/awful_artillery/sound/far_explosion.ogg', 100, FALSE, pressure_affected = FALSE)
	

	if(istype(T, /turf/closed))
		explosion(T, 4, 10, 20)
	else 
		var/turf/turf_below = GET_TURF_BELOW(T)
		if(istype(turf_below, /turf/open))
			explosion(T, 4, 10, 20, flame_range = 3, smoke = TRUE, ignorecap = TRUE)
			T.ChangeTurf(/turf/open/transparent/openspace)

			var/ex_range = 5
			for(var/turf/affected_turf in range(ex_range, T))
				if(affected_turf == T)
					continue

				var/dist = get_dist(T, affected_turf)

				if(dist > ex_range)
					continue

				var/falloff = 1 - (dist / ex_range)
				var/chance = 100 * (falloff * falloff)

				if(prob(chance))
					affected_turf.ChangeTurf(/turf/open/transparent/openspace)

			explosion(turf_below, 4, 10, 20, flame_range = 3, smoke = TRUE, ignorecap = TRUE)
			sleep(0.25 SECONDS)

			for(var/i = 0, i < 20, ++i)
				var/obj/projectile/bullet/shell_shrapnel/shrapnel = new/obj/projectile/bullet/shell_shrapnel(turf_below)
				shrapnel.fire(i/12)
		else 
			explosion(T, 4, 10, 20, flame_range = 3, smoke = TRUE, ignorecap = TRUE)
			explosion(turf_below, 1, 2, 4, flame_range = 0, smoke = TRUE, ignorecap = TRUE)
			sleep(0.25 SECONDS)

			for(var/i = 0, i < 30, ++i)
				var/obj/projectile/bullet/shell_shrapnel/shrapnel = new/obj/projectile/bullet/shell_shrapnel(T)
				shrapnel.fire(i/12)
	
	qdel(src)

/obj/structure/artillery/mortar
	name = "Мортира"
	desc = "Тяжелое оружие навесного боя, предназначенное для забрасывания врага снарядам за стены и укрепления.\
		Стреляет крутым подъемом, полагаясь на силу пороха и руку артиллериста, а не на прямую наводку."

	elevation = 45
	elevation_min = 45
	elevation_max = 90

	ammo_type = /obj/item/artillery_shell/mortar

/obj/structure/artillery/mortar/get_parts()
	return list(/obj/item/mortar_wheel, /obj/item/mortar_wheel, /obj/item/mortar_wheel, /obj/item/mortar_wheel, /obj/item/mortar_used_barrel, /obj/item/artillery_assembly/mortar)


/obj/item/artillery_assembly/mortar
	name = "Лафет мортиры"
	icon = 'modular_twilight_axis/awful_artillery/icons/artillery.dmi'
	icon_state = "mortar_base"
	w_class = WEIGHT_CLASS_HUGE


/obj/item/mortar_wheel 
	name = "Колесо лафета мортиры"
	icon = 'modular_twilight_axis/awful_artillery/icons/artillery.dmi'
	icon_state = "mortar_wheel"
	sellprice = 5
	

/obj/item/mortar_barrel 
	name = "Ствол мортиры"
	icon = 'modular_twilight_axis/awful_artillery/icons/artillery.dmi'
	icon_state = "barrel"
	sellprice = 150
	w_class = WEIGHT_CLASS_HUGE

/obj/item/mortar_used_barrel
	name = "Испорченный ствол мортиры"
	desc = "Если обжечь в печи, можно частично восстановить ствол."
	icon = 'modular_twilight_axis/awful_artillery/icons/artillery.dmi'
	icon_state = "barrel"
	color = "#ecaf86"
	sellprice = 25
	smeltresult = /obj/item/artillery_barrel_assembly


/obj/structure/closet/crate/chest/mortar 
	name = "Ящик с мортирой"
	desc = "Старый ящик с импортным вооружением"

/obj/structure/closet/crate/chest/mortar/PopulateContents()
	new /obj/item/mortar_wheel(src)
	new /obj/item/mortar_wheel(src)
	new /obj/item/mortar_wheel(src)
	new /obj/item/mortar_wheel(src)
	new /obj/item/mortar_barrel(src)
	new /obj/item/artillery_assembly/mortar(src)
	new /obj/item/artillery_assembly/mortar(src)
	new /obj/item/mortar_wheel(src)
	new /obj/item/mortar_wheel(src)
	new /obj/item/mortar_wheel(src)
	new /obj/item/mortar_used_barrel(src)
	new /obj/projectile/bullet/shell_shrapnel(src)
	new /obj/projectile/bullet/shell_shrapnel(src)
	new /obj/projectile/bullet/shell_shrapnel(src)
	new /obj/projectile/bullet/shell_shrapnel(src)
	new /obj/projectile/bullet/shell_shrapnel(src)
	new /obj/projectile/bullet/shell_shrapnel(src)
	new /obj/projectile/bullet/shell_shrapnel(src)
	new /obj/item/twilight_powderflask(src)

GLOBAL_VAR_INIT(mortar_was_not_spawned, FALSE)
/obj/effect/landmark/start/knight/after_round_start()
	if(!GLOB.mortar_was_not_spawned)
		GLOB.mortar_was_not_spawned = TRUE
		var/obj/structure/closet/crate/chest/mortar/chest = new /obj/structure/closet/crate/chest/mortar(loc)

	. = ..()
