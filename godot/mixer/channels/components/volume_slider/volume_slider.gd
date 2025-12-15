extends PanelContainer

signal value_changed(value)

@onready var v_slider = $VSlider


func _ready() -> void:
	v_slider.value_changed.connect(value_changed.emit)

func set_value(value : float) -> void:
	v_slider.value = value

func get_value() -> float:
	return v_slider.value
