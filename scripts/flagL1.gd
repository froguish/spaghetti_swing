extends Area2D

func _on_flagL1_body_entered(body):
	if body is KinematicBody2D: 
		get_tree().change_scene("res://scenes/level2.tscn")
