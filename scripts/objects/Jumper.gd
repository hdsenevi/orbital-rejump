extends Area2D

signal captured
signal died

onready var trail = $Trail/Points
onready var sprite = $Sprite
onready var jump_sound = $Jump
onready var capture_sound = $Capture

var velocity = Vector2(100, 0)
var jump_speed = 1000
var target = null
var trail_length = 25
var jumper_textures: Array

func _ready():
	_pre_load_textures()
	var rand_index = randi() % 20
	sprite.texture = jumper_textures[rand_index]
	
	# Don't override jumper color
	# sprite.material.set_shader_param("color", settings.theme["player_body"])
	
	trail.gradient.set_color(1, settings.theme["player_trail"])

func _unhandled_input(event: InputEvent) -> void:
	# check if a touch input has occured
	if target && event is InputEventScreenTouch && event.is_pressed():
		jump()
		
func jump():
	target.implode()
	target = null
	velocity = transform.x * jump_speed
	if settings.enable_sound:
		jump_sound.play()

func _on_Jumper_area_entered(area: Area2D) -> void:
	target = area
	velocity = Vector2.ZERO
	emit_signal("captured", area)
	if settings.enable_sound:
		capture_sound.play()
	
func _physics_process(delta: float) -> void:
	if trail.points.size() > trail_length:
		trail.remove_point(0)
	trail.add_point(position)
	
	if target:
		transform = target.orbit_position.get_global_transform()
	else:
		position += velocity * delta

func die():
	target = null
	queue_free()

func _on_VisibilityNotifier2D_screen_exited() -> void:
	if !target:
		emit_signal("died")
		die()

func _pre_load_textures() -> void:
	jumper_textures.append(preload("res://assets/images/jumpers/jumper_1.png"))
	jumper_textures.append(preload("res://assets/images/jumpers/jumper_2.png"))
	jumper_textures.append(preload("res://assets/images/jumpers/jumper_3.png"))
	jumper_textures.append(preload("res://assets/images/jumpers/jumper_4.png"))
	jumper_textures.append(preload("res://assets/images/jumpers/jumper_5.png"))
	jumper_textures.append(preload("res://assets/images/jumpers/jumper_6.png"))
	jumper_textures.append(preload("res://assets/images/jumpers/jumper_7.png"))
	jumper_textures.append(preload("res://assets/images/jumpers/jumper_8.png"))
	jumper_textures.append(preload("res://assets/images/jumpers/jumper_9.png"))
	jumper_textures.append(preload("res://assets/images/jumpers/jumper_10.png"))
	jumper_textures.append(preload("res://assets/images/jumpers/jumper_11.png"))
	jumper_textures.append(preload("res://assets/images/jumpers/jumper_12.png"))
	jumper_textures.append(preload("res://assets/images/jumpers/jumper_13.png"))
	jumper_textures.append(preload("res://assets/images/jumpers/jumper_14.png"))
	jumper_textures.append(preload("res://assets/images/jumpers/jumper_15.png"))
	jumper_textures.append(preload("res://assets/images/jumpers/jumper_16.png"))
	jumper_textures.append(preload("res://assets/images/jumpers/jumper_17.png"))
	jumper_textures.append(preload("res://assets/images/jumpers/jumper_18.png"))
	jumper_textures.append(preload("res://assets/images/jumpers/jumper_19.png"))
	jumper_textures.append(preload("res://assets/images/jumpers/jumper_20.png"))
	
