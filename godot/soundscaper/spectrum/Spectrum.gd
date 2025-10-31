extends Control

const MIN_DB = 60

@onready var analyzerInstance : AudioEffectSpectrumAnalyzerInstance = AudioServer.get_bus_effect_instance(0,0)
@onready var disable_delay_timer : Timer = $DisabledDelayTimer

@export_range(0, 20500) var FREQ_MIN = 0
@export_range(0, 20500) var FREQ_MAX = 16000
@export var VU_COUNT : int = 40
@export var frequency_response : Curve
@export var volume_gradient : Gradient

var prev_energy : Array = []
var reactivity : float = 0.6
var reaction_speed : float = 12.0
var vu_separation : float = 0.7
var disabled = false : set = set_disabled


func _ready():
	# initialize prev_energy array
	prev_energy.resize(VU_COUNT)
	prev_energy.fill(0)

func _process(_delta):
	if disabled:
		return
	queue_redraw()


# SETTERS ----------------------------------------------------------------------
func set_color(c : Color):
	volume_gradient.set_color(1, c)

## Used to avoid looping output from Analyzer buffer while bus is silent
func set_disabled(state : bool) -> void:
	if state == true:
		#wait a time for VUs to settle before disabling
		disable_delay_timer.start()
		await disable_delay_timer.timeout
		disabled = state
	else:
		#immediately enable
		disable_delay_timer.stop() # prevent latent disable
		disabled = state

func _draw():
	var vu_width : float = size.y / VU_COUNT
	var vu_separation_remainder : float = vu_width - (vu_width * vu_separation)
	var vu_width_with_separation : float = (size.y + vu_separation_remainder) / VU_COUNT # compensate for reduced VU size
	var vu_length : float = 0
	
	var origin = Vector2(anchor_bottom + size.x, anchor_right)
	
	var prev_hz = FREQ_MIN # starting frequency
	
	for i in VU_COUNT:
		@warning_ignore("integer_division")
		var hz = i * FREQ_MAX / VU_COUNT
		var magnitude: float = analyzerInstance.get_magnitude_for_frequency_range(prev_hz, hz).length()
		var energy = clamp((MIN_DB + linear_to_db(magnitude)) / MIN_DB, 0, 1)
		
		# Apply frequency responsiveness
		var hz_zero_to_one : float = remap(hz, 0, FREQ_MAX, 0, 1)
		var response_multiplier : float = 1.0 + frequency_response.sample(hz_zero_to_one)
		energy *= response_multiplier
		
		# Smooth out the reaction
		var energy_difference = energy - prev_energy[i]
		var energy_speed = remap(energy_difference, -1, 1, -reaction_speed, reaction_speed) * reactivity
		energy = max(0, prev_energy[i] + energy_speed * get_process_delta_time())
		prev_energy[i] = energy 
		
		# Set VU height
		vu_length = energy * size.x * 2
		
		# Draw final VU
		var vu_color = Color.WHITE
		if volume_gradient:
			vu_color = volume_gradient.sample(energy * 2)
		draw_rect(Rect2(origin.x - vu_length, origin.y + vu_width_with_separation * i, vu_length, vu_width_with_separation * vu_separation), vu_color)
		prev_hz = hz
