class_name FilterControl
extends PanelContainer

const MIN_HZ : int = 10
const MAX_HZ : int = 20500

@export var hz_curve : Curve

@onready var high_pass_knob : DisplayKnob = %HighPassKnob
@onready var low_pass_knob : DisplayKnob = %LowPassKnob

var high_pass_filter := AudioEffectHighPassFilter.new()
var low_pass_filter := AudioEffectLowPassFilter.new()


func _ready() -> void:
	# SIGNALS
	high_pass_knob.turned.connect(_on_high_pass_changed)
	low_pass_knob.turned.connect(_on_low_pass_changed)
	
	# DEFAULT POSITIONING
	high_pass_knob.turn_to(-1.0)
	low_pass_knob.turn_to(1.0)
	high_pass_knob.set_default_position(-1.0)
	low_pass_knob.set_default_position(1.0)

func get_effects() -> Array:
	return [high_pass_filter, low_pass_filter]

func remap_to_hz(value : float) -> int:
	var curved_value = hz_curve.sample(value)
	return int(remap(curved_value, -1.0, 1.0, MIN_HZ, MAX_HZ))


# SIGNALS -----------------------------------------------------------------------
func _on_high_pass_changed(value : float) -> void:
	high_pass_filter.cutoff_hz = remap_to_hz(value)

func _on_low_pass_changed(value : float) -> void:
	low_pass_filter.cutoff_hz = remap_to_hz(value)
