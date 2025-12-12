extends HoverPanelContainer

signal sound_added(audio_stream, filename)

@onready var browse_button = %BrowseButton
@onready var browse_dialog = $BrowseDialog


func _ready():
	super()
	# Connect signals
	browse_button.pressed.connect(_on_browse_button_pressed)
	browse_dialog.files_selected.connect(_on_files_selected)
	get_window().files_dropped.connect(_on_files_dropped)


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
