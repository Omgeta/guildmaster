extends Node
## Static class used to setup `AnimatedSprite2D` with Character sprites

## Animation map organized into two sprite sheet sections.
## The first dictionary (index 0) maps to rows 0–3 (1st section),
## the second dictionary (index 1) maps to rows 4–7 (2nd section).
## Each entry defines the number of frames per animation.
const ANIM_MAP = [{"idle": 1, "push": 2, "pull": 2, "jump": 3}, {"walk": 6, "run": 2}]

## Size of each animation frame in pixels
const FRAME_SIZE := Vector2(64, 64)

## Ordered directions per row (0: down, 1: up, 2: right, 3: left)
const DIRECTIONS := ["down", "up", "right", "left"]


## Applies a texture as an animated layer to an AnimatedSprite2D node,
## constructing frame-based directional animations from a spritesheet.
static func setup_animated_layer(sprite: AnimatedSprite2D, texture: Texture):
	var sprite_frames := SpriteFrames.new()

	# Loop over each animation group (corresponding to sprite sheet section)
	for map_index in ANIM_MAP.size():
		var anims = ANIM_MAP[map_index]

		# For each animation (e.g., idle, walk)
		for anim in anims:
			var frame_count = anims[anim]

			# Each direction (e.g., down, up) maps to one row per section
			for dir_index in range(DIRECTIONS.size()):
				var full_anim = "%s_%s" % [anim, DIRECTIONS[dir_index]]
				sprite_frames.add_animation(full_anim)
				sprite_frames.set_animation_speed(full_anim, 6)

				var row = map_index * 4 + dir_index

				# Add each animation frame from the row
				for i in range(frame_count):
					var region = Rect2(
						i * FRAME_SIZE.x, row * FRAME_SIZE.y, FRAME_SIZE.x, FRAME_SIZE.y
					)
					var atlas = AtlasTexture.new()
					atlas.atlas = texture
					atlas.region = region
					sprite_frames.add_frame(full_anim, atlas)

	# Assign the constructed frames and set a default animation
	sprite.frames = sprite_frames
	sprite.play("idle_down")
