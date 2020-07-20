extends Control

signal pulse()

const FLASH_RATE = 0.05
const N_FLASHES = 4

onready var health_over = $HealthOver
onready var health_under = $HealthUnder
onready var update_tween = $UpdateTween
onready var pulse_tween = $PulseTween
onready var flash_tween = $FlashTween

export (Color) var health_color = Color.red
export (Color) var pulse_color = Color.darkred
export (Color) var flash_color = Color.orangered
export (float, 0, 1, 0.05) var caution_zone = 0.5
export (float, 0, 1, 0.05) var danger_zone = 0.2
export (bool) var will_pulse = false

func _on_health_updated(health, amount):
	health_over.value = health
	update_tween.interpolate_property(
		health_under, "value", health_under.value, health, 0.4, 
		Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.4)
	update_tween.start()
	
	_assign_color(health)
	
	if amount < 0:
		_flash_damage()

			
func _assign_color(health):
	if health == 0:
		pulse_tween.set_active(false)
		
func _flash_damage():
	for i in range(N_FLASHES * 2):
		var color = health_over.tint_progress if i % 2 == 1 else flash_color
		var time = FLASH_RATE * i + FLASH_RATE
		flash_tween.interpolate_property(health_over, time, "set", "tint_progress", color)
	flash_tween.start()


func _on_max_health_updated(max_health):
	health_over.max_value = max_health
	health_under.max_value = max_health

