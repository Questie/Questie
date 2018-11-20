from slpp import slpp as lua

def AddItems(list):
	for item in list:
		items.append(item)

items = []

itemdb = {}

if __name__ == '__main__':
	f = open("questDB.lua", "r")
	data = f.read()
	luatable = lua.slpp.decode(data)
	for key, value in luatable.iteritems():
		try:
			if(value[1][2]):
				#print(key, value[1])
				AddItems(value[1][2])
		except IndexError:
			g = 0  
		try:
			if(value[9][2]):
				#print(key, value[1])
				AddItems(value[9][2])
		except IndexError:
			g = 0  
		if(value[10] != None):
			items.append(value[10])

	print(len(items))
	f.close()

	f = open("itemDB.lua", "r")
	data = f.read()
	luatable = lua.slpp.decode(data)
	for item in items:
		i = 0
		try:
			i = item[0]
		except TypeError:
			i = item
		if i in luatable:
			itemdb[str(i)] = luatable[i]

	luafile = lua.slpp.encode(itemdb)
	itemfile = open("itemDBNew.lua", "w")
	itemfile.write(luafile)
	f.close()
	itemfile.close()
		
