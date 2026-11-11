extends Navigation2D

var pool_time = true

func _ready():
	var obstacles = get_node("../YSort/Objects")
	var pool = get_node("../Grass")
	var batch = get_tree().get_nodes_in_group("Batch")
	for i in batch:
		singleItem(i)
	autoTile(obstacles, 1)
	autoTile(obstacles, 2)
	autoTile(obstacles, 3)
	pool_time = false
	autoTile(pool, 2)
	get_node("NavigationPolygonInstance").enabled = false
	get_node("NavigationPolygonInstance").enabled = true

func singleItem(batch):
	var newPolygon = PoolVector2Array()
	var polygon = $NavigationPolygonInstance.get_navigation_polygon()
	var polygonTransform = batch.get_node("Area2D/CollisionPolygon2D").get_global_transform()
	var polygonBP = batch.get_node("Area2D/CollisionPolygon2D").get_polygon()
	for vertex in polygonBP:
		newPolygon.append(polygonTransform.xform(vertex))
	polygon.add_outline(newPolygon)
	polygon.make_polygons_from_outlines()
	$NavigationPolygonInstance.set_navigation_polygon(polygon)

func autoTile(tilemap, ID):
	var polygon = $NavigationPolygonInstance.get_navigation_polygon()
	var usedTiles = tilemap.get_used_cells_by_id(ID)
	var i = 0
	for tile in usedTiles:
		var newPolygon = PoolVector2Array()
		var polygonOffset = tilemap.map_to_world(tile) - Vector2(tilemap.get_cell_size()[0]-32,0)
		var tileRegion = tilemap.get_cell_autotile_coord(tile[0],tile[1])
		var tileTransform = tilemap.get_tileset().tile_get_shape_transform(ID, tileRegion[0])
		var polygonBP = tilemap.get_tileset().tile_get_shape(ID,tileRegion[0]).get_points()
		i = 0
		for vertex in polygonBP:
			if pool_time:
				if i == 0:
					vertex.x -=0
					vertex.y -=9
				elif i == 1:
					vertex.x +=6
					vertex.y -=6
				elif i == 2:
					vertex.x +=11
					vertex.y +=6
				elif i == 3:
					vertex.x +=0
					vertex.y +=6
				elif i == 4:
					vertex.x -=11
					vertex.y +=6
				elif i == 5:
					vertex.x -=6
					vertex.y -=6
			else:
				pass
			vertex += polygonOffset
			newPolygon.append(tileTransform.xform(vertex))
			i += 1
		polygon.add_outline(newPolygon)
	polygon.make_polygons_from_outlines()
	$NavigationPolygonInstance.set_navigation_polygon(polygon)
