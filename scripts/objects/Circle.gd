extends Area2D

onready var orbit_position = $Pivot/OrbitPosition
onready var move_tween = $MoveTween
onready var pivot = $Pivot
onready var animation_player = $AnimationPlayer
onready var sprite = $Sprite
onready var sprite_effect = $SpriteEffect
onready var collision_shapre = $CollisionShape2D
onready var label = $Label
onready var beep_sound = $Beep

var planet_textures: Array

enum MODES { STATIC, LIMITED }

var radius = 120
var rotation_speed = PI
var mode = MODES.STATIC
var move_range = 0
var move_speed = 2.0
var num_orbits = 3
var current_orbits = 0
var orbit_start = null
var jumper = null

func _ready():
	_pre_load_textures()
	
func init(_position, level=1):
	var _mode = settings.rand_weighted([5, level-1])
	set_mode(_mode)
	position = _position
	
	# Don't have moving circles for first 10 levels
#	var move_chance = clamp(level-10, 0, 9) / 10.0
	var move_chance = clamp(level-3, 0, 9) / 10.0
	if randf() < move_chance:
		move_range = max(25, 100 * rand_range(0.75, 1.25) * move_chance) * pow(-1, randi() % 2)
		move_speed = max(2.5 - ceil(level/5) * 0.25, 0.75)
		
	var small_chance = min(0.9, max(0, (level-10) / 20.0))
	if randf() < small_chance:
		radius = max(50, radius - level * rand_range(0.75, 1.25))
	
	animation_player.play("init")
	
	# Assing planet texture to circle
	var rand_index: int = randi() % planet_textures.size()
	sprite.texture = planet_textures[rand_index]
	
	sprite.material = sprite.material.duplicate()
	sprite_effect.material = sprite.material
	collision_shapre.shape = collision_shapre.shape.duplicate()
	collision_shapre.shape.radius = radius
	var img_size = sprite.texture.get_size().x / 2
	sprite.scale = Vector2.ONE * radius / img_size
	
	# Orbit position
	orbit_position.position.x = radius + 10
	rotation_speed *= pow(-1, randi() % 2)
	set_tween()

func set_mode(_mode):
	mode = _mode
	var color
	match mode:
		MODES.STATIC:
			label.hide()
			color = settings.theme["circle_plain"]
		MODES.LIMITED:
			current_orbits = num_orbits
			label.text = str(current_orbits)
			label.show()
			color = settings.theme["circle_plain"]
	sprite.material.set_shader_param("color", color)

func _process(delta: float) -> void:
	pivot.rotation += rotation_speed * delta
	if mode == MODES.LIMITED and jumper:
		check_orbits()
		update()
		
# Checks how many orbits does jumper got left
func check_orbits() -> void:
	if abs(pivot.rotation - orbit_start) > 2 * PI:
		current_orbits -= 1
		if settings.enable_sound:
			beep_sound.play()
		label.text = str(current_orbits)
		if current_orbits <= 0:
			jumper.die()
			jumper = null
			implode()
		orbit_start = pivot.rotation

# Play circles implode animation		
func implode():
	animation_player.play("implode")
	yield(animation_player, "animation_finished")
	queue_free()
	
func capture(target):
	jumper = target
	animation_player.play("capture")
	pivot.rotation = (jumper.position - position).angle()
	orbit_start = pivot.rotation
	
func _draw():
	if jumper:
		var r = ((radius - 30) / num_orbits) * (1 + num_orbits - current_orbits)
		draw_circle_arc_poly(Vector2.ZERO, r, orbit_start + PI/2, pivot.rotation + PI/2, settings.theme["circle_fill"])
	
func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PoolVector2Array()
	points_arc.push_back(center)
	var colors = PoolColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = angle_from + i * (angle_to - angle_from) / nb_points - PI/2
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)

func set_tween(object=null, key=null):
	if move_range == 0:
		return
		
	move_range *= -1
	move_tween.interpolate_property(self, "position:x", position.x, position.x + move_range, move_speed, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	move_tween.start()

func _pre_load_textures() -> void:
	planet_textures.append(preload("res://assets/images/planets/planet00.png"))
	planet_textures.append(preload("res://assets/images/planets/planet01.png"))
	planet_textures.append(preload("res://assets/images/planets/planet02.png"))
	planet_textures.append(preload("res://assets/images/planets/planet03.png"))
	planet_textures.append(preload("res://assets/images/planets/planet04.png"))
	planet_textures.append(preload("res://assets/images/planets/planet05.png"))
	planet_textures.append(preload("res://assets/images/planets/planet06.png"))
	planet_textures.append(preload("res://assets/images/planets/planet07.png"))
	planet_textures.append(preload("res://assets/images/planets/planet08.png"))
	planet_textures.append(preload("res://assets/images/planets/planet09.png"))
