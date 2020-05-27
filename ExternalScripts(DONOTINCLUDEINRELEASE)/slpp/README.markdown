#### SLPP
SLPP is a simple lua-python data structures parser.

Lua data check:

```lua
data = '{ array = { 65, 23, 5 }, dict = { string = "value", array = { 3, 6, 4}, mixed = { 43, 54.3, false, string = "value", 9 } } }'
> data = assert(loadstring('return ' .. data))()
> for i,j in pairs(data['dict']) do print(i,j) end
mixed   table: 0x2014290
string  value
array   table: 0x2014200
```

Parse lua data:

```python
>>> from slpp import slpp as lua
>>> data = lua.decode('{ array = { 65, 23, 5 }, dict = { string = "value", array = { 3, 6, 4}, mixed = { 43, 54.3, false, string = "value", 9 } } }')
>>> print data
{'array': [65, 23, 5], 'dict': {'mixed': {0: 43, 1: 54.33, 2: False, 4: 9, 'string': 'value'}, 'array': [3, 6, 4], 'string': 'value'}}
```

Dump python object:

```python
>>> lua.encode(data)
'{array = {65,23,5},dict = {mixed = {43,54.33,false,9,string = "value"},array = {3,6,4},string = "value"}}'
```

Dump test:

```lua
> data = assert(loadstring('return ' .. '{array = {65,23,5,},dict = {mixed = {43,54.33,false,9,string = "value",},array = {3,6,4,},string = "value",},}'))()
> print(data['dict'])
table: 0x1b64ea0
> for i,j in pairs(data['dict']) do print(i,j) end
mixed   table: 0x880afe0
array   table: 0x880af60
string  value
```
