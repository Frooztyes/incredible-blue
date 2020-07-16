extends Area2D

export(String, MULTILINE) var text_sign: String = ""
onready var message: ColorRect = get_node("CanvasLayer/Message")
onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")

func _ready() -> void:
	get_node("CanvasLayer/Message/Informations").text = text_sign
	
func _get_configuration_warning() -> String:
	return "Enter some text for the sign" if text_sign == "" else ""


func _on_Sign_body_entered(body: Node) -> void:
	animation_player.play("fade_in")


func _on_Sign_body_exited(body: Node) -> void:
	animation_player.play("fade_out")
