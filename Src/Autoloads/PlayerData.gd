extends Node


signal score_updated
signal player_died
signal player_damaged

const MAX_HEALTH = 100

var score: = 0 setget set_score
var deaths: = 0 setget set_deaths
var health: = MAX_HEALTH setget set_health
var max_health: = MAX_HEALTH setget set_max_health
var level_score: = 0 setget set_level_score
var position: Vector2 = Vector2.ZERO setget set_position

func reset() -> void:
	score = 0 
	deaths = 0
	health = max_health

func set_score(value: int) -> void:
	score = value
	emit_signal("score_updated")

func set_deaths(value: int) -> void:
	deaths = value
	emit_signal("player_died")

func set_level_score(value: int) -> void:
	level_score = value
	emit_signal("score_updated")
	
func set_position(value: Vector2) -> void:
	position = value
	
func set_health(value: int) -> void:
	health = value
	emit_signal("player_damaged")
	
func set_max_health(value: int) -> void:
	max_health = value
