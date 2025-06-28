extends Node

const banners = {
	"beginner":
	{
		"name": "Standard Summon",
		"image": "res://core/gacha/assets/banners/standard.png",
		"logic": preload("res://core/gacha/pull_logic/standard.gd")
	},
	"premium":
	{
		"name": "Premium Summon",
		"image": "res://core/gacha/assets/banners/premium.png",
		"logic": preload("res://core/gacha/pull_logic/standard.gd")
	},
}
