extends Control

@onready var character_display_container = $CharacterDisplay
@onready var name_label = $NameLabel


func _ready():
	generate_and_show_character()


func generate_and_show_character():
	# Step 1: Choose a random origin
	var origin = GameState.player_data._origins.pick_random()

	# Step 2: Generate a character using the factory method
	const CharacterFactory = preload("res://core/characters/character_factory.gd")
	var character_resource = CharacterFactory.from_origin(origin)

	# Step 3: Instance the character scene
	var character_scene = preload("res://core/characters/character.tscn").instantiate()
	character_scene.set_character_data(character_resource)

	# Step 4: Add to display and center
	character_display_container.add_child(character_scene)
	character_scene.position = character_display_container.size / 2
	character_scene.scale = Vector2.ONE * 5

	# Display name and origin
	var name_text = "%s\n%s" % [character_resource._name, character_resource._origin._name]
	name_label.text = name_text

	# Animate: start label above screen
	name_label.position = Vector2(character_display_container.position.x - 40, -name_label.size.y)

	# Tween it into place
	var target_y = character_display_container.size.y * 0.1
	var tween = create_tween()
	(
		tween
		. tween_property(name_label, "position:y", target_y, 1.0)
		. set_trans(Tween.TRANS_BOUNCE)
		. set_ease(Tween.EASE_OUT)
	)
