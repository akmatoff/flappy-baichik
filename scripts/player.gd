extends CharacterBody2D

const GRAVITY = 1450.0
const FLAP_STRENGTH = -540.0
const MAX_FALL_SPEED = 760.0
const START_POSITION = Vector2(120, 400)

var flying = false
var falling = false 

func _ready():
	reset()
	
func reset():
	position = START_POSITION
	flying = false
	falling = false
	set_rotation(0)

func _physics_process(delta: float): 
	if flying or falling:
		velocity.y += GRAVITY * delta
		
		if velocity.y > MAX_FALL_SPEED:
			velocity.y = MAX_FALL_SPEED
			
		set_rotation(deg_to_rad(velocity.y * 0.01))
		
		move_and_collide(velocity * delta)
			
func flap():
	velocity.y = FLAP_STRENGTH
