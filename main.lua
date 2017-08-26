io.stdout:setvbuf('no')
local g
g = love.graphics
local _ = require('moses')
local square
square = function(v)
  return v ^ 2
end
local add
add = function(a, b)
  return a + b
end
local iseven
iseven = function(n)
  return n % 2 == 0
end
local sumlist
sumlist = function(list)
  return _.reduce(list, add)
end
local t = {
  1,
  1,
  2,
  3,
  3,
  2,
  1,
  2,
  2,
  2,
  1,
  2,
  3,
  4,
  3,
  2,
  1,
  2,
  3
}
local sum = _.reduce(t, add)
local sum_of_squared = _.reduce(_.map(t, square), add)
print(sum, sum ^ 2)
print(sum_of_squared)
print(sumlist(_.select(t, function(i, v)
  return iseven(v)
end)))
local components = {
  {
    id = 0,
    type = 'Transform'
  },
  {
    id = 0,
    type = 'Light'
  },
  {
    id = 2,
    type = 'Transform'
  },
  {
    id = 2,
    type = 'Canvas'
  }
}
local min_id = _.min(_.pluck(components, 'id'))
print('min id:', min_id)
local grouped = _.groupBy(components, function(i, v)
  return v.type == 'Transform' and 'positional' or 'misc'
end)
local transform_only = _.filter(components, function(i, v)
  return v.type == 'Transform'
end)
local transform_ids = _.pluck(transform_only, 'id')
_.each(grouped, function(group_name, t)
  return _.each(t, function(i, v)
    return print(group_name, v.type)
  end)
end)
_.each(transform_ids, print)
local commacat
commacat = function(t)
  return table.concat(t, ', ')
end
local array = _.range(1, 10)
local sample = _.sample(array, 3)
print('n-sample', commacat(sample))
local s1 = _.sample(array, 3, 987654)
local s2 = _.sample(array, 3, 987654)
assert(_.same(s1, s2))
local sP = _.sampleProb(array, 0.5, os.time())
print('p-sample', commacat(sP))
local letters = _.toArray('a', 'b', 'c')
local more_letters = _.toArray('c', 'd', 'e')
local union = _.union(letters, more_letters)
print('union', _.concat(union))
return require('tictactoe')
