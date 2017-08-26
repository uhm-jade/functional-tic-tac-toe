_ = require 'moses'

-- piece:
--   0: empty
--   1: x
--   2: o


emptyBoard = ->
	_.fill _.range(1, 9), 0

isEmptySquare = (loc, piece) ->
	piece == 0

isFilledSquare = (loc, piece) ->
	not isEmptySquare loc, piece

getX = (loc) ->
	(loc - 1) % 3

getY = (loc) ->
	math.floor (loc - 1) / 3

down = (square) ->
	square + 3

up = (square) ->
	square - 3

right = (square) ->
	square + 1

left = (square) ->
	square - 1

down_right = (square) ->
	down right square

down_left = (square) ->
	down left square

nextSquare = (list, dir, len) ->
	square = dir list[#list]
	newList = _.push list, square
	if #newList < len
		nextSquare newList, dir, len
	else
		newList

triplet = (at, dir) ->
	nextSquare {at}, dir, 3

row = (num) ->
	triplet 3 * num - 2, right

col = (num) ->
	triplet num, down

diagonal = ->
	triplet 1, down_right

subdiagonal = ->
	triplet 3, down_left

getTurn = (board) ->
	#_.reject(board, isEmptySquare) % 2 + 1

placePiece = (board, loc, piece) ->
	_.map board, (i, v) ->
		if (i == loc) and (v == 0)
			piece
		else
			v

newTurn = (board) ->
	(loc) ->
		piece = getTurn board
		placePiece board, loc, piece

tripletEquals = (piece, tripletPieces) ->
	matches = _.filter tripletPieces, (i, v) ->
		v == piece
	#matches == 3

getPieces = (board, locations) ->
	_.map locations, (i, v) -> board[v]

winningTriplets = {
	row(1), row(2), row(3)
	col(1), col(2), col(3)
	diagonal!, subdiagonal!
}
getWinnerTriplets = (board) ->
	winners = (piece) ->
		_.filter winningTriplets, (i, tri) ->
			tripletEquals piece, getPieces(board, tri)
	{winners(1), winners(2)}



----------------------------------
-- draw code
----------------------------------

{graphics: g, window: w} = love

drawLine = (direction) ->
	(gapSize) ->
		(num) ->
			x1, y1 = 0, gapSize * num
			x2, y2 = gapSize * 3, gapSize * num

			if direction == 'horizontal'
				g.line x1, y1, x2, y2
			elseif direction == 'vertical'
				g.line y1, x1, y2, x2

drawTriplet = (gapSize) ->
	(tri) ->
		points = {}
		_.each tri, (i, loc) ->
			x = getX loc
			y = getY loc
			_.push points, x * gapSize + gapSize/2
			_.push points, y * gapSize + gapSize/2
		g.line points


horizontalLine = drawLine('horizontal')
verticalLine = drawLine('vertical')


drawPieceX = (gapSize) -> (loc) ->
	x = getX(loc) * gapSize + (gapSize / 2)
	y = getY(loc) * gapSize + (gapSize / 2)
	o = gapSize / 4
	g.line x - o, y - o, x + o, y + o
	g.line x + o, y - o, x - o, y + o

drawPieceO = (gapSize) -> (loc) ->
	x = getX(loc) * gapSize + (gapSize / 2)
	y = getY(loc) * gapSize + (gapSize / 2)
	o = gapSize / 4
	g.circle 'line', x, y, o



drawBoard = (settings) ->
	{:lineStyle, :lineWidth, :lineColor, :gapSize, :tripletColor} = settings
	pieceX = drawPieceX gapSize
	pieceO = drawPieceO gapSize
	triLine = drawTriplet gapSize

	(board, winnerTriplets) ->
		if lineStyle
			g.setLineStyle lineStyle
		if lineWidth
			g.setLineWidth lineWidth
		if lineColor
			g.setColor lineColor
		else
			g.setColor 255, 255, 255, 255

		for i = 1, 2
			horizontalLine(gapSize)(i)
		for i = 1, 2
			verticalLine(gapSize)(i)

		winnerTriplets_all = _.flatten winnerTriplets

		_.each board, (loc, piece) ->
			if _.find winnerTriplets_all, loc
				g.setColor tripletColor
			else
				g.setColor 255, 255, 255, 255

			if piece == 1
				pieceX loc
			elseif piece == 2
				pieceO loc

			g.print tostring(loc),
				getX(loc) * gapSize + 10,
				getY(loc) * gapSize + 10

		-- if tripletColor
			-- g.setColor tripletColor
		-- if lineWidth
			-- g.setLineWidth lineWidth

		-- _.each winnerTriplets, (i, triList) ->
		-- 	_.each triList, (i, tri) ->
		-- 		triLine tri


boardSize = (gapSize) ->
	gapSize * 3


----------------------------------
-- love callbacks
----------------------------------


boards = {}
winnerTriplets = {{},{}}

settings = {
	gapSize: 100,
	lineStyle: 'rough'
	lineWidth: 10
	tripletColor: {255, 0, 0}
}
render = drawBoard settings

love.load = ->
	boards = _.push boards, emptyBoard!

love.draw = ->
	offset = boardSize(settings.gapSize) / 2
	g.translate g.getWidth! / 2 - offset, g.getHeight! / 2 - offset
	render boards[#boards], winnerTriplets

love.keypressed = (key) ->
	loc = tonumber(key)
	if _.contains _.range(1, 9), loc
		board = boards[#boards]
		newBoard = newTurn(board)(loc)
		unless _.isEqual newBoard, board
			_.push boards, newBoard
			winnerTriplets = getWinnerTriplets newBoard
			print #winnerTriplets[1], #winnerTriplets[2]

	if key == 'escape'
		boards = {emptyBoard!}
		winnerTriplets = {{},{}}
