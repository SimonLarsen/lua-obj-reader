local obj_reader = {}

local file_exists = function(path)
	if love then
		return love.filesystem.exists(path)
	end

	local f = io.open(file, "r")
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

-- from: http://lua-users.org/wiki/SplitJoin
local string_split = function(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
         table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

function obj_reader.read(path)
	assert(file_exists(path), "File does not exist: " .. path)

	local get_lines

	if love then
		get_lines = love.filesystem.lines
	else
		get_lines = io.lines
	end

	local obj = {
		v = {},
		vt = {},
		vn = {},
		f= {},
	}

	for line in get_lines(path) do
		local parts = string_split(line, "%s+")

		if parts[1] == "mtllib" then
			local mtl_path_parts = string_split(path, "/")
			mtl_path_parts[#mtl_path_parts] = parts[2]
			local mtl_path = table.concat(mtl_path_parts, "/")
			obj.materials = obj_reader.read_materials(table)

		elseif parts[1] == "v" then
			local v = {
				x = tonumber(parts[2]),
				y = tonumber(parts[3]),
				z = tonumber(parts[4]),
				w = tonumber(parts[5]) or 1.0
			}
			table.insert(obj.v, v)

		elseif parts[1] == "vt" then
			local vt = {
				x = tonumber(parts[2]),
				y = tonumber(parts[3]),
				z = tonumber(parts[4]),
			}
			table.insert(obj.vt, vt)

		elseif parts[1] == "vn" then
			local vn = {
				x = tonumber(parts[2]),
				y = tonumber(parts[3]),
				z = tonumber(parts[4]),
			}
			table.insert(obj.vn, vn)

		elseif parts[1] == "f" then
			local f = {}
			for i=2, #parts do
				local f_parts = string_split(parts[i], "/")
				local v = {}

				v.v = tonumber(f_parts[1])
				v.vt = tonumber(f_parts[2])
				v.vn = tonumber(f_parts[3])

				table.insert(f, v)
			end
			table.insert(obj.f, f)
		end
	end

	return obj
end

function obj_reader.read_materials(path)
	if love then get_line = love.filesystem.lines
	else get_lines = io.lines end
end

return obj_reader
