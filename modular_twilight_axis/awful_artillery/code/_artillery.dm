#define GRAVITY 9.81
#define BASE_AZIMUTH_ERROR 4
#define OVERHEAT_ERROR 50

/obj/item/artillery_shell
	name = "Дружок, если ты это увидел то админы/маппер дурачки"
	icon = 'modular_twilight_axis/awful_artillery/icons/artillery.dmi'
	icon_state = "cannonball"
	

/obj/item/artillery_shell/proc/shell_action()

/obj/structure/artillery 
	name = "Дружок, если ты это увидел то админы сервера долбаебы"
	desc = "Смайли не воруй"

	icon = 'modular_twilight_axis/awful_artillery/icons/artillery.dmi'
	icon_state = "mortar"

	anchored = 0
	density = 1
	var/azimuth = 0 
	var/elevation = 0 
	var/elevation_min = 1
	var/elevation_max = 90

	var/charge_level = 0
	var/charge_min = 0
	var/charge_max = 5

	var/base_velocity = 5
	var/charge_velocity_step = 15

	var/ammo_type = /obj/item/artillery_shell

	var/obj/item/artillery_shell/ammo

	var/mob/living/carbon/human/user

	var/associated_skill = /datum/skill/combat/twilight_firearms
	var/associated_stat = STAT_INTELLIGENCE

	var/barrel_integrity = 15
	var/last_fired = 0
	var/colddown = 10 SECONDS

/obj/structure/artillery/Initialize()
	. = ..()
	barrel_integrity = rand(8, 20)
	charge_velocity_step = rand(8, 20)

	
/obj/structure/artillery/examine(mob/user)
	. = ..()
	if((world.time - last_fired) < colddown)
		. += span_info("Ствол ощущается горячим, возможно не стоит делать выстрел именно сейчас.")
	else 
		. += span_info("Ствол ощущается холодным, можно произвести выстрел без рисков.")

	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/C = user
		var/perception = C.get_stat(STAT_PERCEPTION) - 10
		if(perception > 0)
			if((barrel_integrity - perception) < 1)
				. += span_info("Моя внимательность позволяет узнать что ствол будет уничтожен через [barrel_integrity] выстрелов")
		else 
			. += span_info("Орудие кажется надежным. Оно выстоит как минимум еще несколько выстрелов")

/obj/structure/artillery/attackby(obj/item/used_item, mob/user)
	if(istype(used_item, ammo_type))
		if(ammo)
			to_chat(usr, span_info("В стволе уже есть заряд"))
		else
			if(do_after(user, 20, target = src))
				used_item.forceMove(src)
				ammo = used_item
				to_chat(usr, span_info("Я зарядил снаряд в [src.name]"))
				playsound(src, 'modular_twilight_axis/awful_artillery/sound/loading.ogg', 100, 0, 1, 1, null, null, FALSE, TRUE)

	if(istype(used_item, /obj/item/twilight_powderflask))
		if(ammo)
			to_chat(usr, span_info("Внутри есть снаряд, нужно его вытащить прежде чем насыпать порох"))
		else
			playsound(src, 'modular_twilight_axis/awful_artillery/sound/powder.ogg', 100, 0, 1, 1, null, null, FALSE, TRUE)
			if(do_after(user, 20, target = src))
				to_chat(usr, span_info("Я заправил [src.name] порохом"))
				charge_level = min(charge_level + 1, charge_max)

	return ..()


/obj/structure/artillery/proc/calculate_coordinates()
	if(charge_level == 0)
		return
	
	var/user_stat = user.get_stat(associated_stat)
	var/user_skill = user.get_skill_level(associated_skill)

	var/velocity = base_velocity + charge_level * charge_velocity_step
	var/range = (velocity * velocity / GRAVITY) * sin(2 * elevation)

	var/overall_artillery_skill = user_skill + (user_stat - 10)

	var/target_azimuth = azimuth

	if(overall_artillery_skill < 3)
		target_azimuth += rand(-BASE_AZIMUTH_ERROR, BASE_AZIMUTH_ERROR)
	else if(overall_artillery_skill < 5)
		target_azimuth += rand(-BASE_AZIMUTH_ERROR/2, BASE_AZIMUTH_ERROR/2)
	else if(overall_artillery_skill < 6)
		target_azimuth += rand(-BASE_AZIMUTH_ERROR/4, BASE_AZIMUTH_ERROR/4)

	if((world.time - last_fired) < colddown)
		range += rand(-OVERHEAT_ERROR, OVERHEAT_ERROR)
		target_azimuth += rand(-OVERHEAT_ERROR, OVERHEAT_ERROR)

	var/dx = range * sin(target_azimuth)
	var/dy = range * cos(target_azimuth)

	var/target_x = round(loc.x + dx)
	var/target_y = round(loc.y + dy)

	var/vector/target = vector(target_x, target_y)

	return target

/obj/structure/artillery/proc/fire_artillery(mob/user)

	if(charge_level == 0)
		to_chat(user, span_warning("В стволе нету заряда"))
		return

	if(!ammo)
		to_chat(user, span_warning("В стволе нету снаряда"))
		return

	var/vector/hit_coordinates = calculate_coordinates()
	if(!hit_coordinates)
		to_chat(user, span_warning("Что-то не дает мне выстрелить туда"))
		return
	var/turf/target = locate(hit_coordinates.x, hit_coordinates.y, src.z)
	if(!target)
		to_chat(user, span_warning("Что-то не дает мне выстрелить туда"))
		return

	for(var/turf/AT in get_adjacent_turfs(src.loc))
		new/obj/effect/particle_effect/smoke/arquebus(AT)
		if(rand(1,10) > 7)
			for(var/turf/BT in get_adjacent_turfs(AT))
				new/obj/effect/particle_effect/smoke/arquebus(BT)

	var/x_mid = src.x + ((target.x - src.x) * 0.5)
	var/y_mid = src.y + ((target.y - src.y) * 0.5)
	var/z_mid = src.z + ((target.z - src.z) * 0.5)
	var/turf/turf_mid = locate(floor(x_mid), floor(y_mid), floor(z_mid))

	playsound(turf_mid, 'modular_twilight_axis/awful_artillery/sound/flyby.ogg', 100, 0, 50, 1, null, null, FALSE, TRUE)

	playsound(src, 'modular_twilight_axis/awful_artillery/sound/launch.ogg', 100, 0, 20, 1, null, null, FALSE, TRUE)

	ammo.forceMove(target)

	ammo.shell_action()
	
	ammo = null

	charge_level = 0

	last_fired = world.time
	barrel_integrity -= 1

	if((world.time - last_fired) < colddown)
		barrel_integrity -= 1

	if(barrel_integrity == 0)
		explosion(src, 1, 8, 10, flame_range = 3)

/obj/structure/artillery/proc/get_parts()
	return list()
	
/obj/structure/artillery/ui_interact(mob/user, datum/tgui/ui)
	if(!istype(user, /mob/living/carbon/human))
		return 

	src.user = user
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Artillery", "Artillery")
		ui.open()

/obj/structure/artillery/ui_data()
	var/list/data = list()
	data["elevation"] = elevation
	data["elevation_min"] = elevation_min
	data["elevation_max"] = elevation_max
	data["azimuth"] = azimuth
	data["charge_level"] = charge_level
	data["charge_max"] = charge_max

	var/vector/target = calculate_coordinates()
	if(target)
		var/turf/target_turf = locate(target.x, target.y, src.z)
		if(target_turf)
			var/velocity = base_velocity + charge_level * charge_velocity_step

			data["range"] = floor((velocity * velocity / GRAVITY) * sin(2 * elevation))

			data["area_name"] = target_turf.loc.name
		else 
			data["range"] = "НЕИЗВЕСТНО"
			data["area_name"] = "НЕИЗВЕСТНО"
	else
		data["range"] = "НЕИЗВЕСТНО"
		data["area_name"] = "НЕИЗВЕСТНО"


	return data



/obj/structure/artillery/ui_close()
	user = null

/obj/structure/artillery/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("fire")
			if(charge_level == 0)
				to_chat(ui.user, span_warning("В стволе нету заряда"))
				return
			if(!ammo)
				to_chat(ui.user, span_warning("В стволе нету снаряда"))
				return
			if(do_after(user, 15, target = src))
				fire_artillery(ui.user)
				ui.user.visible_message(span_danger("[ui.user] производит выстрел из [src]!"))
		if("decrease_charge")
			if(do_after(user, 10, target = src))
				charge_level = max(charge_level - 1, charge_min)
				playsound(src, 'modular_twilight_axis/awful_artillery/sound/removepowder.ogg', 100, 1, 1, 1, null, null, FALSE, FALSE)
				ui.user.visible_message(span_info("[ui.user] извлекает лишний порох из [src]"))
		if("set_elevation")
			elevation = params["value"]
			playsound(src, 'modular_twilight_axis/awful_artillery/sound/anglecorrection.ogg', 100, 1, 1, 1, null, null, FALSE, FALSE)
			ui.user.visible_message(span_info("[ui.user] правит возвышение"))
		if("set_azimuth")
			azimuth = params["value"]
			playsound(src, 'modular_twilight_axis/awful_artillery/sound/anglecorrection.ogg', 100, 1, 1, 1, null, null, FALSE, FALSE)
			ui.user.visible_message(span_info("[ui.user] правит азимут"))
		if("eject_ammo")
			if(do_after(user, 20, target = src))
				playsound(src, 'modular_twilight_axis/awful_artillery/sound/anglecorrection.ogg', 100, 1, 1, 1, null, null, FALSE, FALSE)
				ammo.forceMove(loc)
				ammo = null
				ui.user.visible_message(span_info("[ui.user] извлекает боеприпас из [src]"))
		if("disasseble")
			if(do_after(user, 20, target = src))
				playsound(src, 'modular_twilight_axis/awful_artillery/sound/anglecorrection.ogg', 100, 1, 1, 1, null, null, FALSE, FALSE)
				var/list/parts =  get_parts()
				for(var/path in parts)
					new path(loc)
				ui.close()
				qdel(src)
				ui.user.visible_message(span_info("[ui.user] разобрал [src]"))

	SStgui.try_update_ui(user, src)

/obj/item/artillery_assembly
	name = "Лафет"
	w_class = WEIGHT_CLASS_HUGE


