extends PanelContainer

signal value_changed(value)

@onready var v_slider = $VSlider

func _ready() -> void:
	v_slider.value_changed.connect(value_changed.emit)
