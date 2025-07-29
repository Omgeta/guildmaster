extends ItemData
class_name EquipmentData

enum Slot { Armor, Weapon, Accessory }

@export var slot: Slot = Slot.Armor
@export var hp: int = 0
@export var atk: int = 0
@export var dex: int = 0
@export var mag: int = 0
