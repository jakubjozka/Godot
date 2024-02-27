extends CharacterBody2D

@onready var animation = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var Raycast = $RayCast2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var push_force = 80.0
var pickupDistance = 40
var isCarryingCube = false
var onedirection = Vector2()

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if Input.is_action_pressed("right"):
		sprite.scale.x = abs(sprite.scale.x) * -1
	if Input.is_action_pressed("left"):
		sprite.scale.x = abs(sprite.scale.x)
	
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

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

func update_animation():
	if velocity.x != 0:
		animation.play("RUN")
	else:
		animation.play("IDLE")
	
	if velocity.y != 0:
		animation.play("JUMP")

func _process(delta):
	if not isCarryingCube:
		if Input.is_action_just_pressed("pick"):
			var collision = Raycast.get_collider()
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
	
	cube.gravity_scale = 0

	var cube_parent = cube.get_parent()
	cube_parent.remove_child(cube)

	self.add_child(cube)
	cube.get_node("CollisionShape2D").set_deferred("disabled", true)	
	cube.freeze = true
	cube.position = Vector2(0,-30)

func place_cube():
	var player_parent = self.get_parent()
	var cube_child = self.get_child(4)

	isCarryingCube = false
	cube_child.gravity_scale = 1
	
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
	var cube_child = self.get_child(4)

	isCarryingCube = false
	cube_child.gravity_scale = 1
	
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
