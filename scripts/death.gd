extends Control

var whereto

func _on_retry_pressed():
	whereto = deathloc.whereto
	Globalmusic.play()
	get_tree().change_scene(whereto)


func _on_quit_pressed():
	get_tree().quit()
