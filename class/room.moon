random = love.math.random -- convenience

export class Room
	tileSize: 80
	roomDensity: 4
	doorSize: 4

	new: (@world, @x, @y, @level) =>
		w, h = love.graphics.getDimensions!
		@roomWidth  = math.floor w / @tileSize
		@roomHeight = math.floor h / @tileSize
		@tiles = {}
		@enemies = {}
		@doorsOpen = true
		@generateRoom!

	getWorldSize: =>
		@roomWidth * @tileSize, @roomHeight * @tileSize

	getWorldPosition: =>
		w, h = @getWorldSize!
		@x * w, @y * h

	getWorldRect: =>
		x, y = @getWorldPosition!
		w, h = @getWorldSize!
		x, y, w, h

	getWorldCenter: =>
		x, y, w, h = @getWorldRect!
		x + w/2, y + h/2

	generateRoom: =>
		-- compute possible spawn positions (all tiles within walls)
		spawnPositions = [ vector x,y for x=2, @roomWidth - 1 for y=2, @roomHeight - 1 ]

		-- outer wall calculations
		wallWidth = @roomWidth/2 - @doorSize/2
		wallHeight = @roomHeight/2 - @doorSize/2
		midX = @roomWidth/2 + @doorSize/2 + 1
		midY = @roomHeight/2 + @doorSize/2 + 1

		-- doors
		@doors = {
			@addRoomTile             1, wallHeight + 1,         1, @doorSize, Door -- left
			@addRoomTile wallWidth + 1,              1, @doorSize,         1, Door -- top
			@addRoomTile    @roomWidth, wallHeight + 1,         1, @doorSize, Door -- right
			@addRoomTile wallWidth + 1,    @roomHeight, @doorSize,         1, Door -- bottom
		}

		-- top left
		@addRoomTile 1, 1, wallWidth, 1
		@addRoomTile 1, 1, 1, wallHeight

		-- top right
		@addRoomTile midX, 1, wallWidth, 1
		@addRoomTile @roomWidth, 1, 1, wallHeight

		-- bottom left
		@addRoomTile 1, @roomHeight, wallWidth, 1
		@addRoomTile 1, midY, 1, wallHeight

		-- bottom right
		@addRoomTile midX, @roomHeight, wallWidth, 1
		@addRoomTile @roomWidth, midY, 1, wallHeight

		-- generate some tiles
		for i=1, @roomDensity
			pos = table.remove spawnPositions, love.math.random #spawnPositions
			mirrored = vector pos.x + (@roomWidth/2 - pos.x)*2 + 1, pos.y

			@addRoomTile pos.x, pos.y, 1, 1
			@addRoomTile mirrored.x, mirrored.y, 1, 1

		-- throw in some enemies
		for i=2, 2 + @level
			pos = table.remove spawnPositions, love.math.random #spawnPositions
			worldPos = vector(@getWorldPosition!) + (pos - vector 0.5, 0.5) * @tileSize

			EnemyType = switch love.math.random 3
				when 1
					Octorok
				when 2
					Tektite
				when 3
					Follower

			with e = EnemyType @world, 0, 0
				\setPositionCentered worldPos\unpack!
				table.insert @enemies, e

	closeDoors: =>
		return if not @doorsOpen

		for door in *@doors
			door\close!

		@doorsOpen = false

	openDoors: =>
		return if @doorsOpen

		for door in *@doors
			door\open!

		@doorsOpen = true

	isCompleted: =>
		aliveEnemies = [ enemy for enemy in *@enemies when enemy.health > 0 ]
		#aliveEnemies == 0

	withinWalls: (player) =>
		x, y, w, h = player.world\getRect player
		wx, wy, ww, wh = @getWorldRect!

		wx += @tileSize
		wy += @tileSize
		ww -= @tileSize*2
		wh -= @tileSize*2

		-- god i hate this
		x > wx and y > wy and x + w < wx + ww and y + h < wy + wh

	addRoomTile: (tx, ty, tw, th, TileClass = Wall) =>
		wx, wy = @getWorldPosition!

		wall = TileClass @world,
			wx + util.multiple(tx - 1) * @tileSize,
			wy + util.multiple(ty - 1) * @tileSize,
			util.multiple(tw) * @tileSize,
			util.multiple(th) * @tileSize

		table.insert @tiles, wall
		wall
