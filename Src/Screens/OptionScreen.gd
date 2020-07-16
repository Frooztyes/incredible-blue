extends Control

onready var dropdown: = $Menu/Resolution/ResolutionDropdown
onready var windows: = $Menu/Window/WindowDropdown

var menu_scene = "res://Src/Screens/MainScreen.tscn"
var settings
		
func _on_ResolutionDropdown_item_selected(index: int) -> void:
	GlobalSettings._set_resolution(index)

func _on_Window_item_selected(index: int) -> void:
	match index:
		0:
			OS.window_borderless = true
			OS.window_fullscreen = true
			dropdown.disabled = false
		1:
			OS.window_fullscreen = false
			OS.window_borderless = true
			OS.window_size = OS.get_screen_size()
			OS.window_position = Vector2.ZERO
			dropdown.disabled = true
		2:
			OS.window_fullscreen = false
			OS.window_borderless = false
			dropdown.disabled = false
			_on_ResolutionDropdown_item_selected(dropdown.selected)
				
func _on_CheckButton_pressed() -> void:
		OS.set_window_fullscreen(true) if not OS.window_fullscreen else OS.set_window_fullscreen(false)
			
func _on_master_value_changed(value: float) -> void:
	_change_bus_volume(value, 0, get_node("Menu/Master/Value"))
	
func _on_music_value_changed(value: float) -> void:
	_change_bus_volume(value, 1, get_node("Menu/Music/Value"))
	
func _on_sound_value_changed(value: float) -> void:
	_change_bus_volume(value, 2, get_node("Menu/Sound/Value"))
	
func _change_bus_volume(value: float, bus: int, label: Node) -> void:
	label.text = str(int(((value+24)*100)/24))

	AudioServer.set_bus_volume_db(bus, value)
	if value == -24:
		AudioServer.set_bus_mute(bus, true)
	else:
		AudioServer.set_bus_mute(bus, false)
		
func _set_sliders(bus: int, label: Node, slider: Node) -> void:
	var bus_value = AudioServer.get_bus_volume_db(bus)
	label.text = str(int(((bus_value+24)*100)/24))
	slider.value = bus_value
	
func _ready() -> void:
	settings = GlobalSettings.settings.duplicate()
	add_items()
	init_settings()
	
func init_settings() -> void:
	for setting in settings.keys():
		if setting == "window_type":
			windows.selected = settings[setting]
			_on_Window_item_selected(settings[setting])
		elif setting == "resolution":
			dropdown.selected = settings[setting]
			_on_ResolutionDropdown_item_selected(settings[setting])
		elif setting == "master":
			_set_volume_bus(0, settings[setting], 
			get_node("Menu/Master/HSlider"), get_node("Menu/Master/Value"))
		elif setting == "music":
			_set_volume_bus(1, settings[setting], 
			get_node("Menu/Music/HSlider"), get_node("Menu/Music/Value"))
		elif setting == "sound":
			_set_volume_bus(2, settings[setting], 
			get_node("Menu/Sound/HSlider"), get_node("Menu/Sound/Value"))
			
func _set_volume_bus(bus: int, value: int, slider: Node, label: Node) -> void:	
	var bus_value = ((value*24)/100)-24
	AudioServer.set_bus_volume_db(bus, bus_value)
	label.text = str(value)
	slider.value = bus_value
	
func add_items() -> void:
	for resolution in GlobalSettings.resolutions:
		dropdown.add_item(resolution)
		
	for window in GlobalSettings.windows_types:
		windows.add_item(window)
	
func save() -> void:
	for setting in settings.keys():
		if setting == "window_type":
			GlobalSettings.settings[setting] = windows.selected
		elif setting == "resolution":
			GlobalSettings.settings[setting] = dropdown.selected
		elif setting == "master":
			GlobalSettings.settings[setting] = int(get_node("Menu/Master/Value").text)
		elif setting == "music":
			GlobalSettings.settings[setting] = int(get_node("Menu/Music/Value").text)
		elif setting == "sound":
			GlobalSettings.settings[setting] = int(get_node("Menu/Sound/Value").text)
			
	GlobalSettings.write_config()
	get_tree().change_scene(menu_scene)
	
	
func cancel() -> void:
	init_settings()			
	get_tree().change_scene(menu_scene)

