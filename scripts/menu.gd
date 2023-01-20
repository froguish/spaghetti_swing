extends Control

var rot_speed = deg2rad(15)
var rotation = 0

func _ready():
	$VBoxContainer2/Start.grab_focus()

func _physics_process(delta):
	rotation = $PanelContainer/backdrop.get_rotation() + (rot_speed * delta)
	$PanelContainer/backdrop.set_rotation(rotation)

func _on_Start_pressed():
	get_tree().change_scene("res://scenes/intro.tscn")

func _on_Quit_pressed():
	get_tree().quit()
