extends Node

var filepath = "res://settings.ini"
var configfile

var settings = {}
var resolutions = ["1920 x 1080", "1280 x 720", "800 x 600", "960 x 540"]
var windows_types = ["Fullscreen", "Borderless Fullscreen", "Windowed"]

func _ready() -> void:
	configfile = ConfigFile.new()
	if configfile.load(filepath) == OK:
		for setting in configfile.get_section_keys("settings"):
			var setting_value = configfile.get_value("settings", setting)
			
			if str(setting_value) != "":
				settings[setting] = setting_value
			else:
				settings[setting] = null
	else:
		print("CONFIG FILE NOT FOUND")
		get_tree().quit()
		
	set_game_settings()
	
func set_game_settings():
	for setting in settings.keys():
		if setting == "window_type":
			_set_window_type(settings[setting])
		elif setting == "resolution":
			_set_resolution(settings[setting])
		elif setting == "master":
			_set_volume_bus(0, settings[setting])
		elif setting == "music":
			_set_volume_bus(1, settings[setting])
		elif setting == "sound":
			_set_volume_bus(2, settings[setting])

func _set_resolution(value: int) -> void:
	if not OS.window_borderless:
		var resolution = resolutions[value]
		var size_v = int(resolution.split(' x ')[0]) - 1
		var size_h = int(resolution.split(' x ')[1]) - 1
		OS.set_window_size(Vector2(size_v, size_h))
	
func _set_window_type(index: int) -> void:
	match index:
		0:
			OS.window_borderless = true
			OS.window_fullscreen = true
		1:
			OS.window_borderless = true
			OS.window_size = OS.get_screen_size()
			OS.window_position = Vector2.ZERO
		2:
			OS.window_fullscreen = false
			OS.window_borderless = false
	
	
func _set_volume_bus(bus: int, value: int) -> void:	
	var bus_value = ((value*24)/100)-24
	AudioServer.set_bus_volume_db(bus, bus_value)

func write_config():
	for setting in settings.keys():
		var setting_value = settings[setting]
		if setting_value != null:
			configfile.set_value("settings", setting , setting_value)
		else:
			configfile.set_value("settings", setting , "")	
	configfile.save(filepath)
