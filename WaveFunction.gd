extends Node

class_name WaveFunction

"""The Wavefunction class is responsible for storing which tiles
are permitted and forbidden in each location of an output image.
"""

var random = RandomNumberGenerator.new()

var coefficients
var weights

func initialize(size, weights):
	"""Initialize a new Wavefunction for a grid of `size`,
	where the different tiles have overall weights `weights`.
	Arguments:
	size -- a 2-tuple of (width, height)
	weights -- a dict of tile -> weight of tile
	"""
	self.coefficients = init_coefficients(size, weights.keys())
	self.weights = weights

func init_coefficients(size, tiles):
	"""Initializes a 2-D wavefunction matrix of coefficients.
	The matrix has size `size`, and each element of the matrix
	starts with all tiles as possible. No tile is forbidden yet.
	NOTE: coefficients is a slight misnomer, since they are a
	set of possible tiles instead of a tile -> number/bool dict. This
	makes the code a little simpler. We keep the name `coefficients`
	for consistency with other descriptions of Wavefunction Collapse.
	Arguments:
	size -- a 2-tuple of (width, height)
	tiles -- a set of all the possible tiles
	Returns:
	A 2-D matrix in which each element is a set
	"""
	coefficients = []
	
	for x in range(size[0]):
		var row = []
		for y in range(size[1]):
			row.append(tiles)
		coefficients.append(row)
	
	return coefficients

func get_tiles(co_ords: Vector2):
	"""Returns the set of possible tiles at `co_ords`"""
	return self.coefficients[co_ords.x][co_ords.y]

func get_collapsed(co_ords):
	"""Returns the only remaining possible tile at `co_ords`.
	If there is not exactly 1 remaining possible tile then
	this method raises an exception.
	"""
	var opts = self.get_tiles(co_ords)
	assert(len(opts) == 1)
	return opts[0]

func get_all_collapsed():
	"""Returns a 2-D matrix of the only remaining possible
	tiles at each location in the wavefunction. If any location
	does not have exactly 1 remaining possible tile then
	this method raises an exception.
	"""
	var width = len(self.coefficients)
	var height = len(self.coefficients[0])
	
	var collapsed = []
	for x in range(width):
		var row = []
		for y in range(height):
			row.append(self.get_collapsed(Vector2(x, y)))
		collapsed.append(row)
	
	return collapsed

func shannon_entropy(co_ords):
	"""Calculates the Shannon Entropy of the wavefunction at
	`co_ords`.
	"""
	var sum_of_weights = 0
	var sum_of_weight_log_weights = 0
	for opt in self.coefficients[co_ords.x][co_ords.y]:
		var weight = self.weights[opt]
		sum_of_weights += weight
		sum_of_weight_log_weights += weight * log(weight)
	
	return log(sum_of_weights) - (sum_of_weight_log_weights / sum_of_weights)

func is_fully_collapsed():
	"""Returns true if every element in Wavefunction is fully
	collapsed, and false otherwise.
	"""
	for x in self.coefficients:
		for y in self.coefficients[x]:
			if len(self.coefficients[x][y]) > 1:
				return false

	return true

func collapse(co_ords):
	"""Collapses the wavefunction at `co_ords` to a single, definite
	tile. The tile is chosen randomly from the remaining possible tiles
	at `co_ords`, weighted according to the Wavefunction's global
	`weights`.
	This method mutates the Wavefunction, and does not return anything.
	"""
	var opts = self.coefficients[co_ords.x][co_ords.y]
	var valid_weights : Dictionary
	
	for tile in self.weights.keys():
		if tile in opts:
			valid_weights[tile] = self.weights[tile]
	
	var total_weights = 0
	for weight in valid_weights.values():
		total_weights += weight
		
	var rnd = random.randf() * total_weights	
		
	var chosen
	for tile in self.weights.keys():
		rnd -= self.weights[tile]
		if rnd < 0:
			chosen = tile
			break
	
	self.coefficients[co_ords.x][co_ords.y] = chosen

func constrain(co_ords, forbidden_tile):
	"""Removes `forbidden_tile` from the list of possible tiles
	at `co_ords`.
	This method mutates the Wavefunction, and does not return anything.
	"""
	
	self.coefficients[co_ords.x][co_ords.y].remove(forbidden_tile)