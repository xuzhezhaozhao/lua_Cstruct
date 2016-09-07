require "mylib"

-- char[16], int, int
student = {name="number", id="string", score="number"}
school = {name="string", student=student, pub="number", id="number", http="number"}

local numLen = 8		-- store double
local strLen = 8		-- store a pointer

--[
-- struct = {
-- _length_
-- _offset_
-- key = {
--		type = 0, 1, 2
--		offset
--		struct
-- }
-- }
--]
local function define_structure(ltype, offset)
	if (offset == nil) then
		offset = 0
	end
	local struct = {_length_ = 0}
	for k, v in pairs(rtype) do
		local curoffset = offset + struct._length_
		if (v == "number") then
			struct[k] = {type = 0, offset = curoffset}
			struct._length_ = struct._length_ + numLen
		elseif (v == "string") then
			struct[k] = {type = 1, offset = curoffset}
			struct._length_ = struct._length_ + strLen
		elseif (type(v) == "table") then
			local substruct = define_structure(v, curoffset)
			struct[k] = {type = 2, offset = curoffset, struct = substruct}
			struct._length_ = struct._length_ + substruct._length_
		end
	end
	return struct
end

function create_structure(ltype, n)
	local stype = define_structure(ltype)
	local data, errmsg = mylib.calloc(n, stype._length_)
	stype._data_ 	= data
	stype._n_ 		= n
	return stype
end

function get(stype, nth, key)
	if (key.type == 0) then
		-- number
		return mylib.get_number(stype._data_, nth, key.offset)
	elseif (key.type == 1) then
		-- string
		return mylib.get_string(stype._data_, nth, key.offset)
	elseif (key.type == 2) then
		-- table, error
		return nil
	else
		return nil
	end
end

function set(stype, nth, key)
end
