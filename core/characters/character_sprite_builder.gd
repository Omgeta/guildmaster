extends Node

const ANIM_MAP = [{"idle": 1, "push": 2, "pull": 2, "jump": 3}, {"walk": 6, "run": 2}]
const FRAME_SIZE := Vector2(64, 64)
const DIRECTIONS := ["down", "up", "right", "left"]


static func setup_animated_layer(sprite: AnimatedSprite2D, texture: Texture):
	var sprite_frames := SpriteFrames.new()

	for map_index in ANIM_MAP.size():
		var anims = ANIM_MAP[map_index]
		for anim in anims:
			var frame_count = anims[anim]
			for dir_index in range(DIRECTIONS.size()):
				var full_anim = "%s_%s" % [anim, DIRECTIONS[dir_index]]
				sprite_frames.add_animation(full_anim)
				sprite_frames.set_animation_speed(full_anim, 6)

				var row = map_index * 4 + dir_index
				for i in range(frame_count):
					var region = Rect2(
						i * FRAME_SIZE.x, row * FRAME_SIZE.y, FRAME_SIZE.x, FRAME_SIZE.y
					)
					var atlas = AtlasTexture.new()
					atlas.atlas = texture
					atlas.region = region
					sprite_frames.add_frame(full_anim, atlas)

	sprite.frames = sprite_frames
	sprite.play("idle_down")
