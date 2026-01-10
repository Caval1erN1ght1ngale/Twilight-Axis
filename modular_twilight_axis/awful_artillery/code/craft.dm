/datum/crafting_recipe/roguetown/artillery
	abstract_type = /datum/crafting_recipe/roguetown/artillery/
	skillcraft = /datum/skill/craft/engineering

/datum/crafting_recipe/roguetown/artillery/mortar_wheel
	name = "Колесо лафета мортиры"
	result = /obj/item/mortar_wheel 
	reqs = list(/obj/item/grown/log/tree/stick = 4, /obj/item/grown/log/tree/small = 1)
	verbage_simple = "engineer"
	verbage = "engineers"
	craftdiff = 1

/datum/crafting_recipe/roguetown/artillery/mortar_base
	name = "Лафет мортиры"
	result = /obj/item/artillery_assembly/mortar
	reqs = list(/obj/item/grown/log/tree/small = 4, /obj/item/grown/log/tree = 2)
	verbage_simple = "engineer"
	verbage = "engineers"
	craftdiff = 1

/datum/crafting_recipe/roguetown/artillery/finish_mortar
	name = "Сборка мортиры"
	result = /obj/structure/artillery/mortar
	reqs = list(/obj/item/mortar_wheel = 4, /obj/item/mortar_barrel  = 1, /obj/item/artillery_assembly/mortar = 1)
	verbage_simple = "engineer"
	verbage = "engineers"
	craftdiff = 1


///////////////////////////////////////////////////////////////////////
/// Говно артифишера
/// Плацебо, проще купить у торговца, но игроки попросили
//////////////////////////////////////////////////////////////////////
/obj/item/artillery_barrel_assembly
	name = "Заготовка ствола для артиллерии"
	desc = "Можно специализировать для конкретной артиллерии"
	sellprice = 50

/obj/item/mortar_barrel_assembly
	name = "Заготовка ствола мортиры"
	desc = "Тщательная полировки и будет готово"
	sellprice = 50

/datum/anvil_recipe/engineering/artillery/mortar_barrel_from_universal
	name = "Заготовка ствола мортиры(переделка ствола) "
	req_bar = /obj/item/ingot/steel
	additional_items = list(/obj/item/artillery_barrel_assembly)
	created_item = /obj/item/mortar_barrel_assembly
	createditem_num = 1
	craftdiff = 6

/datum/anvil_recipe/engineering/artillery
	i_type = "Tools"

/datum/anvil_recipe/engineering/artillery/mortar_barrel
	name = "Заготовка ствола мортиры "
	req_bar = /obj/item/ingot/steel
	additional_items = list(/obj/item/ingot/steel, /obj/item/ingot/steel, /obj/item/ingot/steel, /obj/item/ingot/steel, /obj/item/ingot/blacksteel, /obj/item/ingot/blacksteel)
	created_item = /obj/item/mortar_barrel_assembly
	createditem_num = 1
	craftdiff = 6

/datum/crafting_recipe/roguetown/artillery/polish_mortar_barrel
	name = "Полировка заготовки ствола мортиры"
	result = /obj/item/mortar_barrel
	reqs = list(/obj/item/mortar_barrel_assembly)
	tools = list(/obj/item/natural/cloth)
	verbage_simple = "polish"
	verbage = "polishes"
	craftdiff = 4
	time = 60 SECONDS
