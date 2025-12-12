extends CanvasLayer

@onready var channel_container = %ChannelContainer
@onready var save_button = %SaveButtton
@onready var load_button = %LoadButton
@onready var browse_dialog = $BrowseDialog

enum BROWSE_ACTIONS {SAVE, LOAD}
var browse_action = BROWSE_ACTIONS.SAVE

func _ready() -> void:
	browse_dialog.filters = [
		"*.json"
	]
	save_button.pressed.connect(_on_save_button_pressed)
	load_button.pressed.connect(_on_load_button_pressed)
	browse_dialog.file_selected.connect(_on_file_selected)


# SIGNALS ----------------------------------------------------------------------
func _on_save_button_pressed() -> void:
	browse_action = BROWSE_ACTIONS.SAVE
	browse_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	browse_dialog.show()

func _on_load_button_pressed() -> void:
	browse_action = BROWSE_ACTIONS.LOAD
	browse_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	browse_dialog.show()

func _on_file_selected(file) -> void:
	match browse_action:
		BROWSE_ACTIONS.SAVE:
			var data = channel_container.get_used_channel_data()
			SaveManager.save_data(data, file)
		BROWSE_ACTIONS.LOAD:
			var preset = SaveManager.load_data(file)
			channel_container.load_configuration(preset)
