extends Area2D

func _on_soda_zone_body_entered(body):
	if body is KinematicBody2D: 
		get_tree().call_group("player", "entersoda")

func _on_soda_zone_body_exited(body):
	if body is KinematicBody2D:
		get_tree().call_group("player", "exitsoda")
