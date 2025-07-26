extends Node

signal roster_changed
signal level_up(adventurer: AdventurerData)

const Class := AdventurerData.Class

const MAX_LEVEL := 99
const BASE_EXP := 100  # base EXP for 1->2
const EXP_GROWTH := 1.20  # curve multiplier
const STAT_GROWTHS := {
	Class.Warrior: {"hp": 1, "atk": 3, "dex": 1, "mag": 1},
	Class.Rogue: {"hp": 1, "atk": 1, "dex": 3, "mag": 1},
	Class.Mage: {"hp": 1, "atk": 1, "dex": 1, "mag": 3}
}


## Getters
func get_roster(sorted: bool = false) -> Array[AdventurerData]:
	var arr := SaveManager._get_roster(true)  # copy, unsorted
	if sorted:
		arr.sort_custom(
			func(a, b): return a.level > b.level if a.level != b.level else a.rarity > b.rarity
		)
	return arr


func find(id: String) -> AdventurerData:
	return SaveManager._get_adventurer(id, true)


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
	SaveManager.set_dirty()


## Private
func _exp_needed(level: int) -> int:
	return int(BASE_EXP * pow(EXP_GROWTH, level - 1))


func _grow_stats(adv: AdventurerData) -> void:
	var growths = STAT_GROWTHS[adv.class_]
	for stat in growths:
		adv.base_stats[stat] += growths[stat]
