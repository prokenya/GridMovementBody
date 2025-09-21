class_name GridMovementBody
extends Node2D


@export_range(5, 200, 5) var speed = 150
@export var cell_size: int = 16

@onready var direction_ray: RayCast2D = RayCast2D.new()
@onready var tween: Tween

var bias: int = cell_size / 2
var next_tile_cords: Vector2 = position.snapped(Vector2(bias, bias))

var direction:Vector2
var direction_of_view:Vector2
var input_queue:Vector2 = Vector2.ZERO



func _ready() -> void:
	add_child(direction_ray)

func _physics_process(delta: float) -> void:
	direction = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	
	direction = direction.sign()
	if Vector2i(position) != Vector2i(next_tile_cords):
		move_character()
		
		if direction != Vector2.ZERO:
			if direction_of_view != direction:
				input_queue = direction
		return
	if input_queue != Vector2.ZERO:
		direction = input_queue
		input_queue = Vector2.ZERO
	if direction == Vector2.ZERO:
		return
	
	direction_of_view = direction
	
	var target_position = (position + direction * cell_size).snapped(Vector2(bias, bias))


	if not is_blocked(direction):
		if not is_blocked(Vector2(direction.x, 0)) and not is_blocked(Vector2(0, direction.y)):
			next_tile_cords = target_position
		else:
			if not is_blocked(Vector2(direction.x, 0)):
				next_tile_cords.x = target_position.x
			elif not is_blocked(Vector2(0, direction.y)):
				next_tile_cords.y = target_position.y
	else:
		if not is_blocked(Vector2(direction.x, 0)):
			next_tile_cords.x = target_position.x
		elif not is_blocked(Vector2(0, direction.y)):
			next_tile_cords.y = target_position.y

	

func is_blocked(dir: Vector2) -> bool:
	direction_ray.target_position = dir * cell_size
	direction_ray.force_raycast_update()
	return direction_ray.is_colliding()


func move_character():
	if tween:
		if tween.is_running(): 
			return
		tween.kill()
	tween = create_tween()

	var dist = position.distance_to(next_tile_cords)
	var duration = dist / speed

	tween.tween_property(self, "position", next_tile_cords, duration)

		
