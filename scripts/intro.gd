extends Control

var story = ["res://intro/story2.png", "res://intro/story3.png"]
var currentstory = 0

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		if currentstory == 2:
			Globalmusic.play()
			get_tree().change_scene("res://scenes/tutorial1.tscn")
		else:
			$ViewportContainer/TextureRect.texture = load(story[currentstory])
			currentstory += 1
