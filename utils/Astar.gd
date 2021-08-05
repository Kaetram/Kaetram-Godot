extends Node2D

#(C) Andrea Giammarchi with special thanks to Alessandro Crugnola [www.sephiroth.it]
#Recoded for Godot GDScript 
#Use find_path(...) at the bottom of this script

var Grid
var Start
var Goal
var Find

func AStarMethod():
	if Find == "Diagonal" || Find == "Euclidean" :
		Find = funcref(self, "DiagonalSuccessors")
	elif Find == "DiagonalFree" || Find == "EuclideanFree" :
		Find = funcref(self, "DiagonalSuccessors_")
	else: 
		Find = funcref(self, "anon")

func anon(_N, _S, _E, _W, N, S, E, W, result): return result
	
func _Grid(x, y):
	return Grid[y][x] == 0

func Point(Parent, Pos):
	var properties = {
		"Parent" : Parent,
		"value" : Pos.x + (Pos.y * cols),
		"x" : Pos.x,
		"y" : Pos.y,
		"f" : 0,
		"g" : 0
	}
	return properties

func MakePath():
	var _Start = Point(null, Start)
	var _Goal = Point(null, Goal)
	var a_star = []#new Array(limit)
	for i in range(limit):
		a_star.append(0)
	var Open = [_Start]
	var Closed = []
	var result = []
	var _Successors
	var _Point
	var _Path
	var length = Open.size() #... not done in the js - 
	var _max
	var _min
	var j = 0
	var i
	
	while length : #...js has "=" single - assignment and condition?
		_max = limit
		_min = -1
		for I in range(length) :
			if Open[I].f < _max :
				_max = Open[I].f
				_min = I
			i = I
				
				
		_Point = Open[_min] #... _Point = Open.splice(min, 1)[0];
		Open.remove(_min)
		
		if _Point.value == _Goal.value :
			Closed.append(_Point)
			_Path = Closed.back();
			
			result.append(Vector2(_Path.x, _Path.y))
			_Path = _Path.Parent			
			while _Path:			#while (dont know if this is proper do while)
				result.append(Vector2(_Path.x, _Path.y))
				_Path = _Path.Parent
				
			a_star = []
			Closed = []
			Open = []		
			result.invert()
		else :
			_Successors = Successors(_Point.x, _Point.y)
			
			j = _Successors.size()
			i = 0
			while i < j :				
				_Path = Point(_Point, _Successors[i]);
				if !a_star[_Path.value] :
					_Path.g = _Point.g + Distance.call_func(_Successors[i], _Point);
					_Path.f = _Path.g + Distance.call_func(_Successors[i], _Goal);
					Open.append(_Path);
					a_star[_Path.value] = true;
				i += 1
			Closed.append(_Point);
		
		length = Open.size()
	return result


func Successors(x, y):

	var N = y - 1
	var S = y + 1
	var E = x + 1
	var W = x - 1
	var _N = N > -1 && _Grid(x, N)
	var _S = S < rows && _Grid(x, S)
	var _E = E < cols && _Grid(E, y)
	var _W = W > -1 && _Grid(W, y)
	var result = []

	if _N : result.append(Vector2(x, N))

	if _E : result.append(Vector2(E, y))
	
	if _S : result.append(Vector2(x, S))

	if _W : result.append(Vector2(W, y))
	
	Find.call_func(_N, _S, _E, _W, N, S, E, W, result)
	return result


func DiagonalSuccessors(_N, _S, _E, _W, N, S, E, W, result):
	if _N :
		if _E && _Grid(E, N) : result.append(Vector2(E, N))
		if _W && _Grid(W, N) : result.append(Vector2(W, N))

	if _S :
		if _E && _Grid(E, S) : result.append(Vector2(E, S))
		if _W && _Grid(W, S) : result.append(Vector2(W, S))

func DiagonalSuccessors_(_N, _S, _E, _W, N, S, E, W, result):
	_N = N > -1
	_S = S < rows
	_E = E < cols
	_W = W > -1

	if _E :
		if _N && _Grid(E, N) : result.append(Vector2(E, N))
		if _S && _Grid(E, S) : result.append(Vector2(E, S))

	if _W :
		if _N && _Grid(W, N) : result.append(Vector2(W, N))
		if _S && _Grid(W, S) : result.append(Vector2(W, S))


func Diagonal(Pos, Goal) :
	return max(abs(Pos.x - Goal.x), abs(Pos.y - Goal.y))

func Euclidean(Pos, Goal) :
	return sqrt(pow(Pos.x - Goal.x, 2) + pow(Pos.y - Goal.y, 2))

func Manhattan(Pos, Goal) :
	return abs(Pos.x - Goal.x) + abs(Pos.y - Goal.y)


func SetDistanceFunction():
	match Find :
		"Diagonal" : 
			Distance = funcref(self, "Diagonal")
		"DiagonalFree" : 
			Distance = funcref(self, "Diagonal")
		"Euclidean" : 
			Distance = funcref(self, "Euclidean")
		"EuclideanFree" : 
			Distance = funcref(self, "Euclidean")
		"Manhattan" : 
			Distance = funcref(self, "Manhattan")

var cols
var rows
var limit
var Distance 

func _ready():
	create_grid(Globals.map_size.x, Globals.map_size.y)

func create_grid(width, height):
	Grid = []
	
	for y in range(height):
		Grid.append([])
		for x in range(width):
			Grid[y].append(0)
			
	cols = Grid[0].size()
	rows = Grid.size()
	
	limit = cols * rows

func find_path(start_position, end_position, algo = 'Manhattan'):
	Start = start_position
	Goal = end_position
	Find = algo
	
	SetDistanceFunction()
	AStarMethod()
	
	var path = MakePath()
	
	for i in range(len(path)):
		path[i] = Vector2(path[i].x * 16 + 8, path[i].y * 16 + 8)
	
	return path
