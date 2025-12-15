extends Node2D

const MIN_SPEED : float = 600
const MAX_SPEED : float = 800

var velocity : Vector2
var direction : Vector2
var speed = MAX_SPEED
var friction = 1000
var rng = RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	global_position = Vector2.ONE * 500
	randomize_direction()

func _process(delta: float) -> void:
	var displacement = velocity * delta
	var next_position = global_position + displacement
	var view_rect = get_viewport_rect()
	speed = lerp(speed, MIN_SPEED, delta)
	if not view_rect.has_point(next_position):
		speed = MAX_SPEED
		direction = direction.bounce(get_nearest_rect_normal(view_rect))
	velocity = direction * speed
	global_position += velocity * delta
	queue_redraw()

func randomize_direction() -> void:
	var angle = rng.randf() * 2 * PI
	direction = Vector2.from_angle(angle)

func _draw() -> void:
	draw_circle(Vector2.ZERO, 4, Color.WHITE)

func get_nearest_rect_normal(rect : Rect2) -> Vector2:
	var normal := Vector2.ZERO
	var pos = global_position
	var x_distance = min(abs(pos.x - rect.size.x), abs(pos.x - rect.position.x))
	var y_distance = min(abs(pos.y - rect.size.y), abs(pos.y - rect.position.y))
	if x_distance < y_distance:
		normal.x = 1
	else:
		normal.y = 1
	return normal
