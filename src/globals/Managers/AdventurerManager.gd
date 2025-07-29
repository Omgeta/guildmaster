extends Node

signal roster_changed
signal level_up(adventurer: AdventurerData)
signal equipment_changed(adventurer: AdventurerData)

const Class := AdventurerData.Class

const MAX_LEVEL := 99
const BASE_EXP := 100  # base EXP for 1->2
const EXP_GROWTH := 1.50  # curve multiplier


## Getters
func get_roster(sorted: bool = false) -> Array[AdventurerData]:
	var arr := SaveManager._get_roster(true)  # copy, unsorted
	if sorted:
		arr.sort_custom(
			func(a, b): return a.level > b.level if a.level != b.level else a.rarity > b.rarity
		)
	return arr


func find(id: String) -> AdventurerData:
	return SaveManager._find_adventurer(id, true)


func find_name(id: String) -> String:
	return SaveManager._find_adventurer(id, false).display_name


## Setters
func add(adventurer: AdventurerData) -> void:
	SaveManager._set_adventurer(adventurer)
	SaveManager.set_dirty()
	roster_changed.emit()


func remove(id: String) -> void:
	SaveManager._remove_adventurer(id)
	SaveManager.set_dirty()
	roster_changed.emit()


## Status
func mark_seen(id: String) -> void:
	var adv := SaveManager._find_adventurer(id, false)
	if adv:
		adv.seen = true
		SaveManager.set_dirty()


func start_mission(id: String) -> void:
	var adv := SaveManager._find_adventurer(id, false)
	if adv:
		adv.in_mission = true
		SaveManager.set_dirty()


func release_mission(id: String) -> void:
	var adv := SaveManager._find_adventurer(id, false)
	if adv:
		adv.in_mission = false
		SaveManager.set_dirty()


## Experience
func reward_exp(id: String, amount: int) -> void:
	var adv := SaveManager._find_adventurer(id, false)
	if not adv:
		return

	adv.experience += amount
	var lev_up := false
	while adv.level < MAX_LEVEL and adv.experience >= _exp_needed(adv.level):
		adv.experience -= _exp_needed(adv.level)
		adv.level += 1
		_grow_stats(adv)
		lev_up = true

	if lev_up:
		level_up.emit(adv)
		NotificationService.toast(
			"Level Up", "%s leveled up to level %d" % [adv.display_name, adv.level], Color.BLUE
		)
	SaveManager.set_dirty()


## Equipment
func equip_item(adv_id: String, item: EquipmentData) -> bool:
	var adv := SaveManager._find_adventurer(adv_id, false)
	if adv == null or item == null:
		return false

	if adv.in_mission:
		NotificationService.toast(
			"Cannot Equip", "Cannot equip items onto an Adventurer already on a mission!", Color.RED
		)
		return false

	var slot := item.slot

	# move equipped weapon back out
	if adv.equipment[slot] != "":
		SaveManager.add_item(adv.equipment[slot])

	# take out one item if its available
	if not SaveManager.remove_item(item.id):
		return false

	# equip item
	adv.equipment[slot] = item.id
	SaveManager.set_dirty()
	equipment_changed.emit(adv)
	NotificationService.toast(
		"Equipped", "%s equipped with %s" % [adv.display_name, item.name], Color.BLUE
	)
	return true


func unequip(adv_id: String, slot: EquipmentData.Slot):
	var adv := SaveManager._find_adventurer(adv_id, false)
	if adv and adv.equipment[slot] != "":
		var item_id := adv.equipment[slot]
		var item := SaveManager.add_item(item_id)
		adv.equipment[slot] = ""
		SaveManager.set_dirty()
		equipment_changed.emit(adv)
		NotificationService.toast(
			"Unequipped", "%s unequipped from %s" % [item.name, adv.display_name], Color.BLUE
		)


## Private
func _exp_needed(level: int) -> int:
	return int(BASE_EXP * pow(EXP_GROWTH, level - 1))


func _grow_stats(adv: AdventurerData) -> void:
	var growths := adv.stat_growths
	adv.base_stats.hp += growths.hp
	adv.base_stats.atk += growths.atk
	adv.base_stats.dex += growths.dex
	adv.base_stats.mag += growths.mag
