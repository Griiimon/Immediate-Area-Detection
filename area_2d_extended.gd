class_name AreaExtended2D
extends Area2D

# will be emitted by run_immediate_overlap_check()
signal immediate_area_enter


#region testing
func _ready() -> void:
	immediate_area_enter.connect(on_immediate_enter)


func on_immediate_enter(area: AreaExtended2D):
	prints(name, "entered by", area.name)
#endregion


static func create(pos: Vector2, shape: Shape2D, instant_server_registration: bool= true)-> AreaExtended2D:
	var area:= AreaExtended2D.new()
	area.position= pos
	var coll_shape:= CollisionShape2D.new()
	coll_shape.shape= shape
	area.add_child(coll_shape)
	
	if instant_server_registration:
		# this will cause this Area to be added to the Physics Space immediately
		PhysicsServer2D.area_set_transform(area.get_rid(), area.global_transform)

	return area


# check if the newly spawned area overlaps with any of the passed areas and trigger immediate_area_enter
static func run_immediate_overlap_check(new_area: AreaExtended2D, areas: Array[AreaExtended2D], max_results: int = 32, collision_mask: int= 0xFFFFFFFF):
	var space: PhysicsDirectSpaceState2D= new_area.get_world_2d().direct_space_state
	
	var shape_query:= PhysicsShapeQueryParameters2D.new()
	shape_query.collide_with_areas= true
	shape_query.collide_with_bodies= false
	shape_query.collision_mask= collision_mask

	# loop through all areas and run intersect_shape() to find potential overlap with new_area
	for area in areas:
		# assumes the Area has a CollsionShape2D child at the first child index
		# [ can be extended for Areas with multiple Collision shapes ]
		assert(area.get_child(0) is CollisionShape2D)
		shape_query.shape= (area.get_child(0) as CollisionShape2D).shape
		shape_query.transform= area.global_transform
		shape_query.exclude= [area.get_rid()]
		
		var query_result: Array[Dictionary]= space.intersect_shape(shape_query, max_results)
		
		if query_result:
			for overlap in query_result:
				if overlap.collider == new_area:
					area.immediate_area_enter.emit(new_area)
					break
