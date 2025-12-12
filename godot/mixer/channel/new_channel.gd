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
	for file_path in files:
		sound_added.emit(file_path)


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
