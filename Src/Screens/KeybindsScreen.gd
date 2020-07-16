extends Control

onready var buttoncontrainer= get_node("Menu/VBoxContainer")
onready var buttonscript = load("res://Src/Screens/KeyButton.gd")
onready var back_scene = "res://Src/Screens/MainScreen.tscn"

var keybinds
var buttons = {}

func _ready() -> void:
	keybinds = Global.keybinds.duplicate()
	
	for key in keybinds.keys():
		var hbox = HBoxContainer.new()
		var label = Label.new()
		var button = Button.new()
		
		hbox.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		label.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		button.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		
		label.text = key
		
		var button_value = keybinds[key]
		
		if button_value != null:
			button.text = OS.get_scancode_string(button_value)
		else:
			button.text = "Unassigned"
			
		button.set_script(buttonscript)
		button.key = key
		button.value = button_value
		button.menu = self
		button.toggle_mode = true
		button.focus_mode = Control.FOCUS_NONE
		
		hbox.add_child(label)
		hbox.add_child(button)
		buttoncontrainer.add_child(hbox)
		
		buttons[key] = button
		
		
func change_bind(key, value):
	keybinds[key] = value
	for k in keybinds.keys():
		if k != key and value != null and keybinds[k] == value:
			keybinds[k] = null
			buttons[k].value = null
			buttons[k].text = "Unassigned"
			

func back() -> void:
	get_tree().change_scene(back_scene)


func save() -> void:
	Global.keybinds = keybinds.duplicate()
	Global.set_game_binds()
	Global.write_config()
	back()