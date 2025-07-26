extends ItemData
class_name EquipmentData

enum Slot { Armor, Weapon, Accessory }

@export var slot: Slot = Slot.Armor
@export var hp_bonus: int = 0
@export var atk_bonus: int = 0
@export var dex_bonus: int = 0
@export var mag_bonus: int = 0
