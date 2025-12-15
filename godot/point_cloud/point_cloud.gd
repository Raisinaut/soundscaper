extends Node2D

@export var point_scene : PackedScene
@export var point_count : int = 50


func _ready() -> void:
	instantiate_points()

func _process(delta: float) -> void:
	queue_redraw()
	var view_center : Vector2 = get_viewport_rect().size * 0.5
	global_position = view_center
	
	for i : Node2D in get_children():
		var direction_to_center = i.global_position.direction_to(global_position)
		i.direction = lerp(i.direction, direction_to_center, delta * 2)

func instantiate_points() -> void:
	for i in point_count:
		var inst = point_scene.instantiate()
		call_deferred("add_child", inst)

func _draw() -> void:
	var point_positions = get_point_positions()
	if point_positions.size() > 1:
		if point_positions.size() > 2:
			point_positions.append(to_local(get_child(0).global_position))
		draw_polyline(point_positions, Color.WHITE, 3)

func get_point_positions() -> Array:
	var positions = []
	for i : Node2D in get_children():
		positions.append(to_local(i.global_position))
	return positions
