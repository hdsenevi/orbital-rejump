extends Node

onready var music = $Music
onready var hud = $HUD

var Circle = preload("res://scenes/objects/Circle.tscn")
var Jumper = preload("res://scenes/objects/Jumper.tscn")

var player
var score = 0 setget set_score
var num_circles = 0
var high_score = 0
var level = 0
var initial_music_volume = 0
var new_high_score = false
var bonus = 0

func _ready() -> void:
	randomize()
	load_score()
	$HUD.hide()
	initial_music_volume = music.volume_db
	
func new_game():
	new_high_score = false
	set_score(0)
	bonus = 0
	num_circles = 0
	level = 1
	$HUD.update_score(score, 0)
	$Camera2D.position = $StartPosition.position
	player = Jumper.instance()
	player.position = $StartPosition.position
	add_child(player)
	player.connect("captured", self, "_on_Jumper_captured")
	player.connect("died", self, "_on_Jumper_died")
	spawn_circle($StartPosition.position)
	$HUD.show()
	$HUD.show_message("Go!")
	if settings.enable_music:
		music.volume_db = initial_music_volume
		$Music.play()
	
func spawn_circle(_position=null):
	var c = Circle.instance()
	if !_position:
		var x = rand_range(-150, 150)
		var y = rand_range(-500, -400)
		_position = player.target.position + Vector2(x, y)
	add_child(c)
	c.connect("full_orbit", self, "set_bonus", [1])
	c.init(_position, level)
	
func _on_Jumper_captured(object):
	$Camera2D.position = object.position
	object.capture(player)
	
	# If you call spawn_circle without call_deferred, godot with complain as we will be
	# changing physics process while it's doing the physics calculations
	# that is why we need to "defer" calling spawn_circle at the end of physics processing
	call_deferred("spawn_circle")
	
	# increment score
	set_score(score + (1 * bonus))
	set_bonus(bonus + 1)
	num_circles += 1
	
	if num_circles > 0 && num_circles % settings.circles_per_level == 0:
		level += 1
		hud.show_message("Level %s" % str(level))

func _on_Jumper_died():
	if score > high_score:
		high_score = score
		save_score()
		
	get_tree().call_group("circles", "implode")
	$Screens.game_over(score, high_score)
	$HUD.hide()
	if settings.enable_music:
		fade_music()

func set_score(value):
	hud.update_score(score, value)
	score = value
	if score > high_score && !new_high_score:
		hud.show_message("New Record!")
		new_high_score = true

func load_score():
	var f = File.new()
	if f.file_exists(settings.score_file):
		f.open(settings.score_file, File.READ)
		high_score = f.get_var()
		f.close()
	
func save_score(): 
	var f = File.new()
	f.open(settings.score_file, File.WRITE)
	f.store_var(high_score)
	f.close()

func fade_music():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(music, "volume_db", -50, 1.0)
	yield(tween, "finished")
	music.stop()

func set_bonus(value):
	if value > 1: 
		bonus = value 
	else: 
		bonus = 1
		
	hud.update_bonus(bonus)
