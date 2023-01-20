extends Area2D

func _on_flagL3_body_entered(body):
	if body is KinematicBody2D: 
		Globalmusic.stop()
		get_tree().change_scene("res://scenes/outro.tscn")
