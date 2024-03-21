extends CharacterBody2D

@onready var animation = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var Raycast = $RayCast2D
@onready var Raycast2 = $RayCast2D2
@onready var Raycast3 = $RayCast2D3

const SPEED = 300.0
const JUMP_VELOCITY_STEP = 30
var jump_power_initial = -200
var jump_power = 0
var jump_time_max = 0.175
var jump_timer = 0
var is_jumping = false

var push_force = 80.0
var pickupDistance = 40
var isCarryingCube = false
var onedirection = Vector2()

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if Input.is_action_pressed("right"):
		sprite.scale.x = abs(sprite.scale.x) 
	if Input.is_action_pressed("left"):
		sprite.scale.x = abs(sprite.scale.x) * -1
	
	if not is_on_floor():
		velocity.y += (gravity * 3) * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump_timer = 0.0
		is_jumping = true
		apply_jump_force(jump_power_initial)
		jump_power = jump_power_initial
	elif Input.is_action_pressed("jump") and is_jumping and jump_timer < jump_time_max:
		jump_power -= JUMP_VELOCITY_STEP
		apply_jump_force(jump_power)
	
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	update_animation()
	move_and_slide()
	
	if Input.is_action_pressed("left"):
		onedirection = Vector2.LEFT
		
	if Input.is_action_pressed("right"):
		onedirection = Vector2.RIGHT
	
	Raycast.target_position = onedirection * 25
	
	if is_on_floor():
		for i in get_slide_collision_count():
			var c = get_slide_collision(i)
			if c.get_collider() is RigidBody2D:
				c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
		jump_timer = 0.0
		is_jumping = false
	else:
		jump_timer += delta
	
	if Input.is_action_just_pressed("Restart"):
		get_tree().reload_current_scene()

func apply_jump_force(power):
	velocity.y = power

func _input(event):
	if event.is_action_released("jump") and is_jumping:
		jump_timer = jump_time_max

func update_animation():
	if velocity.x != 0:
		animation.play("run")
	else:
		animation.play("idle")
	if velocity.y != 0:
		animation.play("jump")

func _process(delta):
	if not isCarryingCube:
		if Input.is_action_just_pressed("pick"):
			var collision = Raycast2.get_collider()
			if collision == null:
				collision = Raycast3.get_collider()
			if collision == null:
				collision = Raycast.get_collider()
			if collision and collision.is_in_group("Cube"):
				var cube = collision
				pick_up_cube(cube)

	elif isCarryingCube:
		if Input.is_action_just_pressed("pick"):
			place_cube()
		elif Input.is_action_just_pressed("throw"):
			throw_cube()

func pick_up_cube(cube):
	isCarryingCube = true 
	
	var cube_parent = cube.get_parent()
	cube_parent.remove_child(cube)

	self.add_child(cube)
	cube.get_node("CollisionShape2D").set_deferred("disabled", true)	
	cube.freeze = true
	cube.position = Vector2(0,-30)

func place_cube():
	var player_parent = self.get_parent()
	var cube_child = self.get_child(6)

	isCarryingCube = false
	
	cube_child.get_node("CollisionShape2D").set_deferred("disabled", false)
	self.remove_child(cube_child)
	player_parent.add_child(cube_child)
	cube_child.freeze = false
	
	if onedirection == Vector2.RIGHT:
		cube_child.global_position = self.global_position + Vector2(30, 0)
	if onedirection == Vector2.LEFT:
		cube_child.global_position = self.global_position + Vector2(-30, 0)

func throw_cube():
	var player_parent = self.get_parent()
	var cube_child = self.get_child(6)

	isCarryingCube = false
	
	cube_child.get_node("CollisionShape2D").set_deferred("disabled", false)
	self.remove_child(cube_child)
	player_parent.add_child(cube_child)
	cube_child.freeze = false
	
	if onedirection == Vector2.RIGHT:
		cube_child.global_position = self.global_position + Vector2(35, -35)
		cube_child.apply_central_impulse(Vector2(300,-150))
	if onedirection == Vector2.LEFT:
		cube_child.global_position = self.global_position + Vector2(-35, -35)
		cube_child.apply_central_impulse(Vector2(-300,-150))
