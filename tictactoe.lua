local _ = require('moses')
local emptyBoard
emptyBoard = function()
  return _.fill(_.range(1, 9), 0)
end
local isEmptySquare
isEmptySquare = function(loc, piece)
  return piece == 0
end
local isFilledSquare
isFilledSquare = function(loc, piece)
  return not isEmptySquare(loc, piece)
end
local getX
getX = function(loc)
  return (loc - 1) % 3
end
local getY
getY = function(loc)
  return math.floor((loc - 1) / 3)
end
local down
down = function(square)
  return square + 3
end
local up
up = function(square)
  return square - 3
end
local right
right = function(square)
  return square + 1
end
local left
left = function(square)
  return square - 1
end
local down_right
down_right = function(square)
  return down(right(square))
end
local down_left
down_left = function(square)
  return down(left(square))
end
local nextSquare
nextSquare = function(list, dir, len)
  local square = dir(list[#list])
  local newList = _.push(list, square)
  if #newList < len then
    return nextSquare(newList, dir, len)
  else
    return newList
  end
end
local triplet
triplet = function(at, dir)
  return nextSquare({
    at
  }, dir, 3)
end
local row
row = function(num)
  return triplet(3 * num - 2, right)
end
local col
col = function(num)
  return triplet(num, down)
end
local diagonal
diagonal = function()
  return triplet(1, down_right)
end
local subdiagonal
subdiagonal = function()
  return triplet(3, down_left)
end
local getTurn
getTurn = function(board)
  return #_.reject(board, isEmptySquare) % 2 + 1
end
local placePiece
placePiece = function(board, loc, piece)
  return _.map(board, function(i, v)
    if (i == loc) and (v == 0) then
      return piece
    else
      return v
    end
  end)
end
local newTurn
newTurn = function(board)
  return function(loc)
    local piece = getTurn(board)
    return placePiece(board, loc, piece)
  end
end
local tripletEquals
tripletEquals = function(piece, tripletPieces)
  local matches = _.filter(tripletPieces, function(i, v)
    return v == piece
  end)
  return #matches == 3
end
local getPieces
getPieces = function(board, locations)
  return _.map(locations, function(i, v)
    return board[v]
  end)
end
local winningTriplets = {
  row(1),
  row(2),
  row(3),
  col(1),
  col(2),
  col(3),
  diagonal(),
  subdiagonal()
}
local getWinnerTriplets
getWinnerTriplets = function(board)
  local winners
  winners = function(piece)
    return _.filter(winningTriplets, function(i, tri)
      return tripletEquals(piece, getPieces(board, tri))
    end)
  end
  return {
    winners(1),
    winners(2)
  }
end
local g, w
do
  local _obj_0 = love
  g, w = _obj_0.graphics, _obj_0.window
end
local drawLine
drawLine = function(direction)
  return function(gapSize)
    return function(num)
      local x1, y1 = 0, gapSize * num
      local x2, y2 = gapSize * 3, gapSize * num
      if direction == 'horizontal' then
        return g.line(x1, y1, x2, y2)
      elseif direction == 'vertical' then
        return g.line(y1, x1, y2, x2)
      end
    end
  end
end
local drawTriplet
drawTriplet = function(gapSize)
  return function(tri)
    local points = { }
    _.each(tri, function(i, loc)
      local x = getX(loc)
      local y = getY(loc)
      _.push(points, x * gapSize + gapSize / 2)
      return _.push(points, y * gapSize + gapSize / 2)
    end)
    return g.line(points)
  end
end
local horizontalLine = drawLine('horizontal')
local verticalLine = drawLine('vertical')
local drawPieceX
drawPieceX = function(gapSize)
  return function(loc)
    local x = getX(loc) * gapSize + (gapSize / 2)
    local y = getY(loc) * gapSize + (gapSize / 2)
    local o = gapSize / 4
    g.line(x - o, y - o, x + o, y + o)
    return g.line(x + o, y - o, x - o, y + o)
  end
end
local drawPieceO
drawPieceO = function(gapSize)
  return function(loc)
    local x = getX(loc) * gapSize + (gapSize / 2)
    local y = getY(loc) * gapSize + (gapSize / 2)
    local o = gapSize / 4
    return g.circle('line', x, y, o)
  end
end
local drawBoard
drawBoard = function(settings)
  local lineStyle, lineWidth, lineColor, gapSize, tripletColor
  lineStyle, lineWidth, lineColor, gapSize, tripletColor = settings.lineStyle, settings.lineWidth, settings.lineColor, settings.gapSize, settings.tripletColor
  local pieceX = drawPieceX(gapSize)
  local pieceO = drawPieceO(gapSize)
  local triLine = drawTriplet(gapSize)
  return function(board, winnerTriplets)
    if lineStyle then
      g.setLineStyle(lineStyle)
    end
    if lineWidth then
      g.setLineWidth(lineWidth)
    end
    if lineColor then
      g.setColor(lineColor)
    else
      g.setColor(255, 255, 255, 255)
    end
    for i = 1, 2 do
      horizontalLine(gapSize)(i)
    end
    for i = 1, 2 do
      verticalLine(gapSize)(i)
    end
    local winnerTriplets_all = _.flatten(winnerTriplets)
    return _.each(board, function(loc, piece)
      if _.find(winnerTriplets_all, loc) then
        g.setColor(tripletColor)
      else
        g.setColor(255, 255, 255, 255)
      end
      if piece == 1 then
        pieceX(loc)
      elseif piece == 2 then
        pieceO(loc)
      end
      return g.print(tostring(loc), getX(loc) * gapSize + 10, getY(loc) * gapSize + 10)
    end)
  end
end
local boardSize
boardSize = function(gapSize)
  return gapSize * 3
end
local boards = { }
local winnerTriplets = {
  { },
  { }
}
local settings = {
  gapSize = 100,
  lineStyle = 'rough',
  lineWidth = 10,
  tripletColor = {
    255,
    0,
    0
  }
}
local render = drawBoard(settings)
love.load = function()
  boards = _.push(boards, emptyBoard())
end
love.draw = function()
  local offset = boardSize(settings.gapSize) / 2
  g.translate(g.getWidth() / 2 - offset, g.getHeight() / 2 - offset)
  return render(boards[#boards], winnerTriplets)
end
love.keypressed = function(key)
  local loc = tonumber(key)
  if _.contains(_.range(1, 9), loc) then
    local board = boards[#boards]
    local newBoard = newTurn(board)(loc)
    if not (_.isEqual(newBoard, board)) then
      _.push(boards, newBoard)
      winnerTriplets = getWinnerTriplets(newBoard)
    end
  end
  if key == 'escape' then
    boards = {
      emptyBoard()
    }
    winnerTriplets = {
      { },
      { }
    }
  end
end
