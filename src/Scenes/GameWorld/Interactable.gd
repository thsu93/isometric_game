extends Node2D

onready var dialogue_path = $AssociatedDialogue.dialogue_path
signal start_dialogue(dialogue_path)
var inside = false

func _on_Area2D_body_entered(body):
	if body.has_method("get_type") and body.get_type()=="player":
		inside = true

func _on_Area2D_body_exited(body):
	if body.has_method("get_type") and body.get_type()=="player":
		inside = false
	
func _process(_delta):
	if inside and Input.is_action_just_pressed("ui_select"):
		emit_signal("start_dialogue", dialogue_path)
