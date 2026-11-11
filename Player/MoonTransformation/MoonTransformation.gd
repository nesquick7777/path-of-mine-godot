extends KinematicBody2D

const ACCELERATION = 600
const DASH_MAX_SPEED = 150
const MAX_SPEED = 100
const FRICTION = 500


var roll_vector = Vector2.DOWN
var velocity = Vector2.ZERO
var attackTruth = true
var stringAttack = "Attack1"
var combo = true

onready var spritePlayer = $SpritePlayer
onready var animationPlayer = $AnimationPlayer
onready var sprite = $Sprite
onready var hitBox = $HitPosition2D/Hitbox
onready var hitBox2 = $Hitbox2
onready var hitBox3 = $Hitbox3

func _ready():
	$Shadow.visible = true
	$PlayerShdow.visible = false
	$SpritePlayer.visible = false
	Global.connect("transformationOver", self, "death")
	animationPlayer.play("Idle")
	hitBox.damage = 1
	hitBox.knockback_vector = Vector2.RIGHT
	hitBox2.damage = 4
	hitBox2.knockback_vector = Vector2.LEFT
	hitBox3.damage = 4
	hitBox3.knockback_vector = Vector2.RIGHT

#STATES
enum {
	MOVE,
	ROLL,
	ATTACK,
	DEATH
}
var state = MOVE


func _physics_process(delta):
	match state:
		DEATH:
			animationPlayer.playback_speed = 1.5
			animationPlayer.play("Death")
		MOVE:
			sprite.flip_h = velocity.x < 0
			_move_state(delta)
		ROLL:
			sprite.flip_h = velocity.x < 0
			_roll_state(delta)
		ATTACK:
			_attack_state(delta)

func _move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		animationPlayer.play("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationPlayer.play("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	move(delta)
	if Input.is_key_pressed(KEY_SPACE):
		state = ROLL
	elif Input.is_action_pressed("ui_shoot_up") or Input.is_action_pressed("ui_shoot_down") or Input.is_action_pressed("ui_shoot_left") or Input.is_action_pressed("ui_shoot_right"):
		state = ATTACK

func move(delta):
	velocity = move_and_slide(velocity)


func _attack_state(delta):
	var position = self.get_global_position()
	var pointingDirection = (get_global_mouse_position()-position).normalized()
	var angle = 90 - rad2deg(pointingDirection.angle())
	
	if Input.is_action_pressed("ui_shoot_left") and attackTruth and (angle >= 0 and angle <=180):
		hitBox.knockback_vector = Vector2.RIGHT
		hitBox.damage = 1
		stringAttack = "Attack2"
		animationPlayer.playback_speed = 2.5
		$HitPosition2D.scale.x = 1
		attackTruth = false
		sprite.flip_h = false
	elif Input.is_action_pressed("ui_shoot_left") and attackTruth:
		hitBox.knockback_vector = Vector2.LEFT
		hitBox.damage = 1
		$HitPosition2D.scale.x = -1
		attackTruth = false
		sprite.flip_h = true
		stringAttack = "Attack2"
		animationPlayer.playback_speed = 2.5
	elif Input.is_action_pressed("ui_shoot_right") and attackTruth:
		stringAttack = "Attack3"
		attackTruth = false
		animationPlayer.playback_speed = 2
	animationPlayer.play(stringAttack)
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
	move(delta)



func _roll_state(delta):
	animationPlayer.playback_speed = 1.7
	animationPlayer.play("Dash")
	velocity = roll_vector * DASH_MAX_SPEED
	move(delta)

func _roll_finished():
	animationPlayer.playback_speed = 1
	velocity = velocity * 0.8
	state = MOVE
	
func _attack_finished():
	$HitPosition2D/Hitbox/CollisionShape2D2.set_deferred("disabled",true)
	animationPlayer.playback_speed = 1
	state = MOVE
	attackTruth = true
	combo = true
func combo_finished():
	if !combo:
		pass
	else:
		_attack_finished()


func combo():
	var position = self.get_global_position()
	var pointingDirection = (get_global_mouse_position()-position).normalized()
	var angle = 90 - rad2deg(pointingDirection.angle())
	
	if (Input.is_action_pressed("ui_shoot_right") or Input.is_action_pressed("ui_shoot_left")) and combo:
		if Input.is_action_pressed("ui_shoot_left") and (angle >= 0 and angle <=180):
			hitBox.knockback_vector = Vector2.RIGHT
			sprite.flip_h = false
		else:
			hitBox.knockback_vector = Vector2.LEFT
			sprite.flip_h = true
		combo = false
		animationPlayer.play("Attack3")
		animationPlayer.playback_speed = 2.5


func shortPress():
	if Input.is_action_pressed("ui_shoot_right") or Input.is_action_pressed("ui_shoot_left"):
		hitBox.damage = 3
		stringAttack = "Attack1"
		animationPlayer.playback_speed = 1

func disableAttack2():
	$HitPosition2D/Hitbox/CollisionShape2D2.set_deferred("disabled",true)

func death():
	state = DEATH
