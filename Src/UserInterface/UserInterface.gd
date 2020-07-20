extends Control


onready var scene_tree: = get_tree()
onready var pause_overlay: ColorRect = $PauseOverlay
onready var score: Label = $Score
onready var pause_title: Label = $PauseOverlay/Title
onready var healthbar: Control = $HealthBar
onready var second_label: Control = $HBoxContainer/SecondLabel
onready var minute_label: Control = $HBoxContainer/MinuteLabel
onready var msecond_label: Control = $HBoxContainer/MillisecondLabel

onready var bow: Control = $Weapon/BowImage
onready var sword: Control = $Weapon/SwordImage
onready var arrows_number: Control = $Weapon/BowImage/HBoxContainer/ArrowsNumber

const DIED_MESSAGE: = "You died"

var paused: = false setget set_paused
var time_start = 0
var time_now = 0

func _ready() -> void:
	time_start = OS.get_unix_time()
	PlayerData.connect("score_updated", self, "update_interface")
	PlayerData.connect("player_died", self, "_on_PlayerData_player_died")
	PlayerData.connect("player_damaged", self, "_damage_take")
	PlayerData.connect("time_level_change", self, "_time_level_update")
	PlayerData.connect("arrows_number_change", self, "_arrow_number_update")
	update_interface()

func _process(delta: float) -> void:
	_time_level_update()

func _time_level_update():
	time_now = OS.get_ticks_msec()
	var milliseconds = str(time_now % 100)
	var seconds = str((time_now/1000) % 60 )
	var minutes = str((time_now/1000) / 60 )
	if int(milliseconds) < 10:
		milliseconds = "0" + milliseconds
		
	if int(seconds) < 10:
		seconds = "0" + seconds
		
	if int(minutes) < 10:
		minutes = "0" + minutes
		
	minute_label.text = minutes
	second_label.text = seconds
	msecond_label.text = milliseconds
	
func _damage_take():
	healthbar._on_health_updated(PlayerData.health, PlayerData.max_health)

func _on_PlayerData_player_died() -> void:
	self.paused = true
	pause_title.text = DIED_MESSAGE
	
func _input(event: InputEvent) -> void:
	if event.is_action_released("change_attack"):
		if bow.visible == true:
			bow.visible = false
			sword.visible = true
		elif sword.visible == true:
			sword.visible = false
			bow.visible = true
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and pause_title.text != DIED_MESSAGE:
		self.paused = not paused
		scene_tree.set_input_as_handled()

func update_interface() -> void:	
	_arrow_number_update()
	score.text = "Score : %s" % str(PlayerData.score+PlayerData.level_score)

func set_paused(value: bool) -> void:
	paused = value
	scene_tree.paused = value
	pause_overlay.visible = value

func _arrow_number_update() -> void:
	arrows_number.text = "× " + str(PlayerData.arrows)
