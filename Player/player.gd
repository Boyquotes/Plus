extends CharacterBody2D
class_name Player

#variables
const acceleration : float = 45
var input_vector : Vector2
var speed : float = 300
var jumped : bool = false
var player_color : Array

#export variables
@export var jump_height : float
@export var peak_time : float
@export var descent_time : float
@export var colors : PackedColorArray

#onready variables
@onready var jump_velocity : float = ((2.0 * jump_height) / peak_time) * -1
@onready var jump_gravity : float = ((-2.0 * jump_height) / (pow(peak_time, 2))) * -1
@onready var fall_gravity : float = ((-2.0 * jump_height) / (pow(descent_time, 2))) * -1

@onready var animplayer = $AnimationPlayer
@onready var camera = $Camera2D

#functions
func _enter_tree():
	set_multiplayer_authority(str(name).to_int())
	for i in get_parent().get_children():
		if i is Player:
			player_color.append(i)

func _ready():
	if not is_multiplayer_authority(): return

	camera.make_current()
	modulate = colors[(player_color.size() -1)]

func _process(delta):
	if not is_multiplayer_authority(): return
	animations.rpc()
	inputs()

func _physics_process(delta):
	if not is_multiplayer_authority(): return #important

	#movement
	velocity.x = input_vector.x

	#gravity
	if not is_on_floor():
		velocity.y += get_gravity() * delta
	else:
		jumped = false

	move_and_slide()

#custom functions
func inputs():
	if not is_multiplayer_authority(): return
 
	if Input.get_action_raw_strength("Right"):
		input_vector.x = min(velocity.x + acceleration, speed)
	elif Input.get_action_raw_strength("Left"):
		input_vector.x = max(velocity.x - acceleration, -speed)
	else:
		input_vector.x = lerp(velocity.x, 0.0, 0.2)

	if Input.is_action_pressed("Jump") and not jumped:
			velocity.y = jump_velocity
			jumped = true

	if Input.is_action_just_pressed("Jump"):
		if is_on_wall() && Input.is_action_pressed("Left"):
			velocity.y = jump_velocity/0.85
		elif is_on_wall() && Input.is_action_pressed("Right"):
			velocity.y = jump_velocity/0.85
		else: return

@rpc("call_local")
func animations():
	pass

func get_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity
