extends Node2D

@onready var new_area_shape: CollisionShape2D = $"New Area Shape"

var all_areas: Array[AreaExtended2D]



func _ready() -> void:
	all_areas.assign(find_children("*", "Area2D"))


func _physics_process(delta: float) -> void:
	var new_area:= AreaExtended2D.create(new_area_shape.position, new_area_shape.shape)
	new_area.name= "New Area"
	add_child(new_area)
	
	AreaExtended2D.run_immediate_overlap_check(new_area, all_areas)
	get_tree().quit()
