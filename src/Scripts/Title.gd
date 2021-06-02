extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var path

# Called when the node enters the scene tree for the first time.
func _ready():
	var button = $Menu/HBoxContainer/Buttons/Button
	button.connect("pressed", self, "_on_Button_pressed", [button.scene_to_load])

func _on_Button_pressed(scene_to_load):
	path = scene_to_load
	$Fade.show()
	$Fade.fade_in()

func _on_Fade_fade_finished():
	get_tree().change_scene(path)
