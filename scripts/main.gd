extends Node2D

@export var pipe_scene : PackedScene
@export var score_label : Label
@export var highscore_label : Label

var game_started = false
var game_over = false
var bgScroll
var score = 0
var highscore = 0
var screen_size : Vector2i
const SCROLL_SPEED = 250
const BG_SCROLL_SPEED = 7
const PIPE_RANGE = 90
const TOP_OFFSET = 30       

const save_path = "user://score.save"

var pipes : Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Canvas/Grayscale.hide()
	screen_size = get_viewport_rect().size
	
	reset_game()

func reset_game():
	game_started = false
	game_over = false
	score = 0
	
	$Canvas/Grayscale.hide()
	$Canvas/Menu.hide()
	score_label.text = str(score)
	$Player.reset()
	$GameOverSound.stop()
	get_tree().call_group("pipes", "queue_free")
	
	pipes.clear()
	spawn_pipes()
	load_data()
	
func start_game():
	game_started = true
	$Player.flying = true
	$Player.flap()
	$PipeTimer.start()

func handle_flap():
	$FlapSound.play()
				
	if game_started == false:
		start_game()
	else:
		if game_over == false:
			$Player.flap()

func _input(event):
	if game_over == false:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				handle_flap()
		elif event is InputEventScreenTouch:
			if event.pressed:
				handle_flap()
		elif event is InputEventKey:
			if event.keycode == KEY_SPACE and event.pressed:
				handle_flap()
		
func _process(delta): 
	if game_started:
		check_top()
			
		$Ground/ParallaxBackground.scroll_base_offset.x -= SCROLL_SPEED * delta 
		$ParallaxBackground.scroll_base_offset.x -= BG_SCROLL_SPEED * delta  
		
		for pipe in pipes:  
			pipe.position.x -= SCROLL_SPEED * delta 

func spawn_pipes():
	var pipe = pipe_scene.instantiate()
	pipe.position.x = screen_size.x + 250
	pipe.position.y = (screen_size.y / 2.0) - randi_range(-PIPE_RANGE, PIPE_RANGE)
	pipe.hit.connect(player_hit)
	pipe.pass_pipe.connect(increase_score)
	add_child(pipe)
	pipes.append(pipe)
	
func player_hit():
	$Player.falling = true
	stop_game()
	
func check_top():
	if $Player.position.y < 0 + TOP_OFFSET:
		$Player.falling = true
		stop_game()
		
func stop_game():
	if not game_over:
		$PipeTimer.stop()
		$Player.flying = false
		$Canvas/Menu.show()
		$GameOverSound.play()
		$PunchSound.play()
		$Canvas/Grayscale.show()
		save_data()
	
	game_started = false
	game_over = true

func increase_score():
	score += 1
	score_label.text = str(score)

func save_data():
	if score > highscore:
		var file = FileAccess.open(save_path, FileAccess.WRITE)
		file.store_16(score)
		file.close()

func load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		highscore = file.get_16()
		highscore_label.text = str(highscore)
			
		if highscore != null:
			return highscore
		
		file.close()
		
		return 0
		
	return 0

func _on_pipe_timer_timeout() -> void:
	spawn_pipes()

func _on_ground_hit() -> void:
	$Player.falling = false
	stop_game()

func _on_menu_restart() -> void:
	reset_game()
