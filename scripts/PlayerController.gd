extends KinematicBody2D

const MAX_SPEED = 1300
const ACCELERATION = 30
const FRICTION = 10
const GRAVITY = 2000
const CHAIN_PULL = 105
const JUMP_FORCE = 800

const SODAFORCE = 600
const SODASPEED = 700
const SODAFRICTION = 3

var gforce = GRAVITY
var maximumspeed = MAX_SPEED
var thefriction = FRICTION
var sodazone = false
var input_direction = 0

var velocity = Vector2(0, 0)
var hook_velocity = Vector2.ZERO
onready var hook = $hook
var hook_pos = Vector2.ZERO
var hook_coll = Vector2.ZERO

enum states {GROUND, AIR, HOOKED}
var state : int = states.GROUND

var can_reach = load("res://sprite/can_reach.png")
var cant_reach = load("res://sprite/cant_reach.png")

var idle = "idle"
var walk = "walk"
var jump = "jump"
var fall = "fall"

func _ready():
	Engine.set_target_fps(Engine.get_iterations_per_second())

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed && hook.is_colliding() && state != states.HOOKED && sodazone == false && hook.get_collider().name != "barriers":
			$hooksfx.play()
			state = states.HOOKED
			hook_coll = hook.get_collision_point()
		else:
			state = states.AIR

func _draw():
	if state == states.HOOKED:
		draw_line(to_local(get_position()), to_local(hook_coll), Color8(254, 174, 52), 10)

func get_input(delta):
	#grapple hook position and x-axis direction
	hook_pos = to_local(hook_coll).normalized()
	input_direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	#collision handling velocity
	if is_on_ceiling():
		velocity.y = lerp(velocity.y, 0, 30 * delta)
	elif is_on_wall():
		velocity.x = lerp(velocity.x, 0, 30 * delta)

	#handling ground states and y velocity
	if state != states.HOOKED:
		if is_on_floor():
			state = states.GROUND
			$coyote.start()
			if get_floor_normal().dot(Vector2.UP) < 1:
				velocity.y += gforce * delta
			else:
				velocity.y = 0
		else:
			state = states.AIR
			velocity.y += gforce * delta
	
	#jumping
	if Input.is_action_just_pressed("jump"):
		if state == states.GROUND or !$coyote.is_stopped():
			velocity.y = 0
			velocity.y -= JUMP_FORCE
		elif state == states.AIR:
			$buffer.start()
	elif !$buffer.is_stopped() && state == states.GROUND:
		state = states.AIR
		velocity.y -= JUMP_FORCE
		$buffer.start()
		
	if Input.is_action_pressed("sink"):
		if sodazone == true:
			if state == states.AIR:
				velocity.y += GRAVITY * 10 * delta
	
	#x-axis velocity
	if input_direction != 0:
		velocity.x += input_direction * ACCELERATION
		if state == states.GROUND:
			velocity.x = clamp(velocity.x, -600, 600)
		elif state == states.AIR:
			velocity.x = clamp(velocity.x, -900, 900)
	else:
		velocity.x = lerp(velocity.x, 0, thefriction * delta)
	
	#hook velocity
	if state == states.HOOKED:
		hook_velocity = hook_pos
		hook_velocity.x *= CHAIN_PULL
		hook_velocity.y *= (CHAIN_PULL * 0.33)
	else:
		hook.look_at(get_global_mouse_position())
		hook_velocity = Vector2.ZERO
		
	velocity += hook_velocity
	
	#move player and then clamp velocity afterwards
	var _movement = move_and_slide(velocity, Vector2.UP)
	
	velocity.x = clamp(velocity.x, -maximumspeed, maximumspeed)
	velocity.y = clamp(velocity.y, -maximumspeed, maximumspeed)

func _physics_process(delta):
	if hook.is_colliding() && hook.get_collider().name != "barriers" && sodazone == false:
		Input.set_custom_mouse_cursor(can_reach)
	else:
		Input.set_custom_mouse_cursor(cant_reach)
	for i in get_slide_count():
		if get_slide_collision(i).collider.name == "spikes":
			var location = get_tree().get_current_scene().get_name()
			get_node("/root/deathloc").whereto = "res://scenes/" + location + ".tscn"
			Globalmusic.stop()
			get_tree().change_scene("res://scenes/death.tscn")
			Input.set_custom_mouse_cursor(null)
	get_input(delta)
	play_anim()
	update()

func entersoda():
	gforce = SODAFORCE
	maximumspeed = SODASPEED
	thefriction = SODAFRICTION
	
	idle = "s_idle"
	walk = "s_walk"
	jump = "s_jump"
	fall = "s_fall"
	
	$Sprite.hide()
	$Sprite2.show()
	
	sodazone = true
	if state == states.HOOKED:
		state = states.AIR

func exitsoda():
	gforce = GRAVITY
	maximumspeed = MAX_SPEED
	thefriction = FRICTION
	
	idle = "idle"
	walk = "walk"
	jump = "jump"
	fall = "fall"
	
	$Sprite2.hide()
	$Sprite.show()
	
	sodazone = false

func play_anim():
	if is_on_wall():
		$anim.play(idle)
	elif !is_on_floor():
		if velocity.y < 0:
			if state != states.HOOKED:
				$anim.advance(0)
				$anim.play(jump)
		elif velocity.y > 0:
			$anim.advance(0)
			$anim.play(fall)
	elif input_direction != 0:
		$anim.play(walk)
	elif input_direction == 0:
		$anim.play(idle)

func play_walk_sfx():
	if !$walksfx.playing:
		$walksfx.pitch_scale = rand_range(0.8, 1.2)
		$walksfx.play()

func play_s_walk_sfx():
	if !$s_walksfx.playing:
		$s_walksfx.pitch_scale = rand_range(0.8, 1.2)
		$s_walksfx.play()

func jump_sfx():
	if !$jumpsfx.playing:
		$jumpsfx.pitch_scale = 0.8
		$jumpsfx.play()
