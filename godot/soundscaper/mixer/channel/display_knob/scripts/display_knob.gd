@tool
extends PanelContainer

signal turned(turn_amount : float)

@export var text : String : set = set_text
@export_range(1, 10, 1.0, "or_greater") var font_size : int : set = set_font_size
@export var knob_size : float = 60 : set = set_knob_size

@onready var knob = %Knob
@onready var text_label = %TextLabel


func _ready() -> void:
	# Propogate signals
	knob.turned.connect(func(amt): turned.emit(amt))

func set_text(t : String):
	text = t
	%TextLabel.text = text
	%TextLabel.visible = (text != "")

func set_font_size(value : int) -> void:
	if not is_node_ready():
		return
	font_size = value
	text_label.label_settings.font_size = font_size

func set_knob_size(value : float) -> void:
	if not is_node_ready():
		return
	knob_size = value
	knob.custom_minimum_size = Vector2.ONE * knob_size

func turn_to(amount : float) -> void:
	knob.turn_to(amount)

func set_default_position(value : float) -> void:
	value = clamp(value, -1.0, 1.0)
	knob.default_position = value
