@tool
class_name Knob
extends PanelContainer

signal turned(turn_position : float)

const max_rotation = PI * 3/4

@onready var proxy = $Proxy
@onready var knob_center = $KnobCenter
@onready var notch = $KnobCenter/Notch

var selected : bool = false
var select_position = Vector2.ZERO
var last_mouse_position = Vector2.ZERO
var turn_tween : Tween

var default_position = 0.0 : set = set_default_position
var sensitivity = 1.0


func _ready() -> void:
	default_position = get_turn_position()
	set_notify_transform(true)
	proxy.button_down.connect(_on_proxy_down)
	proxy.button_up.connect(_on_proxy_up)
	update_notch_transform()

func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		update_notch_transform()


# ACTIONS ----------------------------------------------------------------------
## Turn relative to the current rotation.
func turn_by(amount : float):
	var new_rotation = knob_center.rotation + amount
	set_knob_center_rotation(clamp(new_rotation, -max_rotation, max_rotation))

## Snap to specific rotation amount from -1.0 to 1.0.
func turn_to(amount : float) -> void:
	amount = restrict_value_range(amount)
	set_knob_center_rotation(remap(amount, -1, 1, -max_rotation, max_rotation))

func set_knob_center_rotation(value : float) -> void:
	knob_center.rotation = value
	turned.emit(get_turn_position())

func get_turn_position() -> float:
	var turn_amount = knob_center.rotation / max_rotation
	return clamp(turn_amount, -1.0, 1.0)


# MOUSE INTERACTION ------------------------------------------------------------
func _on_proxy_down() -> void:
	select_position = get_local_mouse_position()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	selected = true

func _on_proxy_up() -> void:
	warp_mouse(select_position)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	selected = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.double_click and proxy.is_hovered():
			reset_position()

func _process(_delta: float) -> void:
	if selected:
		# stop any reset
		if turn_tween:
			turn_tween.kill()
		# measure and move by mouse displacement
		var movement = get_local_mouse_position() - last_mouse_position
		turn_by(-movement.y * sensitivity * 0.01)
		# reset mouse position
		warp_mouse(select_position)
	last_mouse_position = get_local_mouse_position()

func reset_position() -> void:
	var start_pos = get_turn_position()
	turn_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	turn_tween.tween_method(turn_to, start_pos, default_position, 0.1)


# SETUP ------------------------------------------------------------------------
func update_notch_transform() -> void:
	var pos = size / 2
	notch.size = size
	notch.position = -pos
	knob_center.position = pos

func set_default_position(value : float) -> void:
	value = restrict_value_range(value)
	default_position = value

func restrict_value_range(value : float) -> float:
	value = clamp(value, -1.0, 1.0)
	return value
