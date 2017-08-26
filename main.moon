io.stdout\setvbuf 'no'


{graphics: g} = love


_ = require 'moses'


square = (v) -> v^2
add = (a, b) -> a + b

iseven = (n) -> n % 2 == 0

sumlist = (list) -> _.reduce list, add

t = {1,1,2,3,3,2,1,2,2,2,1,2,3,4,3,2,1,2,3}

sum = _.reduce t, add
sum_of_squared = _.reduce _.map(t, square), add

print sum, sum ^ 2
print sum_of_squared

print sumlist _.select(t, (i,v)->iseven(v))


components = {
	{id: 0, type: 'Transform'}
	{id: 0, type: 'Light'}
	{id: 2, type: 'Transform'}
	{id: 2, type: 'Canvas'}
}

min_id = _.min _.pluck(components, 'id')
print 'min id:', min_id

grouped = _.groupBy components, (i, v) ->
	v.type == 'Transform' and 'positional' or 'misc'

transform_only = _.filter components, (i, v) ->
	v.type == 'Transform'

transform_ids = _.pluck(transform_only, 'id')

_.each grouped, (group_name, t) ->
	_.each t, (i,v) ->
		print group_name, v.type

_.each transform_ids, print


----
-- array functions


commacat = (t) ->
	table.concat t, ', '


array = _.range 1, 10

-- random sample of n size
sample = _.sample array, 3
print 'n-sample', commacat sample

 -- with seed
s1 = _.sample array, 3, 987654
s2 = _.sample array, 3, 987654
assert _.same s1, s2


sP = _.sampleProb array, 0.5, os.time!
print 'p-sample', commacat sP



letters = _.toArray 'a', 'b', 'c'
more_letters = _.toArray 'c', 'd', 'e'
union = _.union letters, more_letters

print 'union', _.concat union



require 'tictactoe'
