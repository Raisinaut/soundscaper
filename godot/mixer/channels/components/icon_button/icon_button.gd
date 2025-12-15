@tool
extends PanelContainer

signal pressed

@export var icon : Texture = null : set = set_icon
@export var button_tooltip : String = ""
@export var toggle_mode : bool = false

@onready var button = $Button

var button_group : ButtonGroup : set = set_button_group


func _ready() -> void:
	button.pressed.connect(_on_button_pressed)
	button.tooltip_text = button_tooltip
	button.toggle_mode = toggle_mode

func set_icon(value : Texture) -> void:
	icon = value
	%IconRect.texture = icon

func set_button_group(value : ButtonGroup) -> void:
	button_group = value
	button.button_group = value

func set_button_pressed(state : bool) -> void:
	button.button_pressed = state


# SIGNALS ----------------------------------------------------------------------
func _on_button_pressed() -> void:
	pressed.emit()
