extends Control

@onready var anim = $AnimationPlayer
@onready var result_container = $ResultContainer


func show_results(results: Array):
	visible = true
	for child in result_container.get_children():
		child.queue_free()

	#anim.play("pull_intro")
	#await anim.animation_finished

	for result in results:
		var card = preload("res://core/gacha/ui/pull_card.tscn").instantiate()
		card.populate(result)
		result_container.add_child(card)
		await get_tree().create_timer(0.5).timeout
