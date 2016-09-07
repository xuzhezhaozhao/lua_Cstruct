require "mylib"

-- char[16], int, int
local student = {id="number", name="string", score="number"}
local school = {name="string", id="number",  pub="number", student=student, http="number"}

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
	for k, v in pairs(ltype) do
		local curoffset = offset + struct._length_
		if (v == "number") then
			struct[k] = {_type_ = 0, _offset_ = curoffset}
			struct._length_ = struct._length_ + numLen
		elseif (v == "string") then
			struct[k] = {_type_ = 1, _offset_ = curoffset}
			struct._length_ = struct._length_ + strLen
		elseif (type(v) == "table") then
			local substruct = define_structure(v, curoffset)
			struct[k] = substruct;
			struct[k]._type_ = 2;
			struct[k]._offset_ = curoffset;
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
	if (key._type_ == 0) then
		-- number
		return mylib.get_number(stype._data_, stype._length_, nth, key._offset_)
	elseif (key._type_ == 1) then
		-- string
		return mylib.get_string(stype._data_, stype._length_, nth, key._offset_)
	elseif (key._type_ == 2) then
		-- table, error
		return nil
	else
		return nil
	end
end

function set(stype, nth, key, value)
	if (key._type_ == 0) then
		-- number
		mylib.set_number(stype._data_, stype._length_, nth, key._offset_, value)
	elseif (key._type_ == 1) then
		-- string
		mylib.set_string(stype._data_, stype._length_,  nth, key._offset_, value)
	elseif (key._type_ == 2) then
		-- table, error
	else
	end
end
