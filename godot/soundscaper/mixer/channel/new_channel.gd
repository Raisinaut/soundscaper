extends PanelContainer

signal sound_added(audio_stream, filename)

@onready var browse_button = %BrowseButton
@onready var hover_detection : Button = %HoverDetection
@onready var browse_dialog = $BrowseDialog

var mouse_in_window : bool = false
var brightness_tween : Tween


func _ready():
	# Connect signals
	browse_button.pressed.connect(_on_browse_button_pressed)
	browse_dialog.files_selected.connect(_on_files_selected)
	get_window().files_dropped.connect(_on_files_dropped)

func _process(_delta: float) -> void:
	sync_color_with_hover()


# SIGNALS ----------------------------------------------------------------------
func _on_browse_button_pressed():
	browse_dialog.show()

func _on_files_dropped(files):
	if is_hovered():
		add_files(files)

func _on_files_selected(files):
	add_files(files)


# FILE MANAGEMENT --------------------------------------------------------------
## Emits a signal packet for every valid file
func add_files(files : Array) -> void:
	for file in files:
		var sound = load_audio(file)
		if sound != null:
			sound_added.emit(sound, get_filename(file))
		else:
			print("Could not load sound from file ", file)

## Retrieves a string before any extension and after the last /
func get_filename(file_path : String, trim_extension := true) -> String:
	var file_name : String = file_path.split("/")[-1]
	if trim_extension:
		file_name = file_name.split(".")[0]
	return file_name

## Loads audio as its corresponding AudioStream type.
func load_audio(path : String):
	var audio = null
	var extension = path.split(".")[-1]
	match extension:
		"wav":
			audio = AudioStreamWAV.load_from_file(path)
		"ogg":
			audio = AudioStreamOggVorbis.load_from_file(path)
		"mp3":
			audio = AudioStreamMP3.load_from_file(path)
	return audio


# CHECKS -----------------------------------------------------------------------
# Tracks mouse focus
func _notification(what: int) -> void:
	match(what):
		NOTIFICATION_WM_MOUSE_ENTER:
			mouse_in_window = true
		NOTIFICATION_WM_MOUSE_EXIT:
			mouse_in_window = false

## Checks if the mouse is hovering over the specified area
func is_hovered():
	var node = hover_detection
	var hover_rect = Rect2(node.position, node.size)
	var mouse_pos = get_local_mouse_position()
	return hover_rect.has_point(mouse_pos)

## Darkens the root node when hover is active
func sync_color_with_hover():
	if is_hovered() and mouse_in_window:
		tween_brightness(1.1)
	else:
		tween_brightness(1.0)

func tween_brightness(brightness : float):
	var c = Color.BLACK.lightened(brightness)
	brightness_tween = create_tween()
	brightness_tween.tween_property(self, "self_modulate", c, 0.1)
