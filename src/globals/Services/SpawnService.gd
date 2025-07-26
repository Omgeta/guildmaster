extends Node

const CHARACTER_PCK: PackedScene = preload("res://src/core/entities/character_3d.tscn")


func spawn_roster(
	nav: NavigationRegion3D,
	parent: Node3D,
	cam: Node3D = get_viewport().get_camera_3d().get_parent_node_3d(),
	markers: Node3D = null,
	data: Array[AdventurerData] = AdventurerManager.get_roster(),
) -> Array[Character3D]:
	# very hacky, procedural methods like get_random_point only work ~1-3 frame after NavServer mount
	# just waiting 1 doesn't work unlike in the issue and its inconsistent
	# so we just wait until it works
	# relevant issue: https://github.com/godotengine/godot/pull/75098
	await get_tree().create_timer(0.1).timeout
	var points := _gather_points(nav, data.size(), markers)
	RNG.shuffle(points)
	var out: Array[Character3D] = []

	for i in data.size():
		var c: Character3D = CHARACTER_PCK.instantiate()
		c.data = data[i]
		c.cam = cam
		c.position = points[i]
		parent.add_child(c)
		out.append(c)

	print("SpawnLoader: spawned %d entities" % out.size())
	return out


func _gather_points(nav: NavigationRegion3D, n: int, markers: Node3D) -> Array[Vector3]:
	var pts: Array[Vector3] = []
	if markers:  # explicit markers first if they're available
		for m in markers.get_children():
			pts.append(m.global_transform.origin)
			if pts.size() == n:
				return pts

	# fill remainder randomly from random nav points on the mesh
	for _i in range(pts.size(), n):
		pts.append(NavigationServer3D.map_get_random_point(nav.get_navigation_map(), 1, true))
	return pts
