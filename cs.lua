require "clib"

local moduleName = ...
local M = {}
_G[moduleName] = M
package.loaded[moduleName] = M

-- metatable
local mt = {}

local numLen = clib.size_number()		-- store double
local strLen = clib.size_string()		-- store a pointer to string
local boolLen = clib.size_bool()		-- store bool value

local TNUMBER = 0
local TSTRING = 1
local TBOOL = 2
local TTABLE = 3

local key_words = {
	_length_=true, _type_=true, _offset_=true, 
	_root_=true, _data_=true, _n_=true
}

local function _define_structure(ltype, offset)
	if (offset == nil) then
		offset = 0
	end
	local struct = {_length_ = 0}
	for k, v in pairs(ltype) do
		local curoffset = offset + struct._length_
		if (type(k) ~= "string") then
			error("key must be string")
		end
		if (key_words[k] == true) then
			error(string.format("keyname '%s' is not allowed used", k))
		end
		if (v == "number") then
			struct[k] = {_type_ = TNUMBER, _offset_ = curoffset}
			struct._length_ = struct._length_ + numLen
		elseif (v == "string") then
			struct[k] = {_type_ = TSTRING, _offset_ = curoffset}
			struct._length_ = struct._length_ + strLen
		elseif (v == "bool") then
			struct[k] = {_type_ = TBOOL, _offset_ = curoffset}
			struct._length_ = struct._length_ + boolLen
		elseif (type(v) == "table") then
			local substruct = _define_structure(v, curoffset)
			struct[k] = substruct;
			struct[k]._type_ = TTABLE;
			struct[k]._offset_ = curoffset;
			struct._length_ = struct._length_ + substruct._length_
		else 
			error(string.format("%s: invalid type", v))
		end
	end
	struct._root_ = struct
	return struct
end

local function _populate(stype)
	for k, v in pairs(stype) do
		if (type(v) == "table") then
			v._root_ = stype._root_
			setmetatable(v, mt)
			if (v._type_ == TTABLE) then
				_populate(v)
			end
		end
	end
end

function M.create(ltype, n)
	if (n == nil) then
		n = 1
	end
	if (n <= 0) then
		error("argument error: arg #2 should greater than 0")
	end
	local stype = _define_structure(ltype)
	local size = n * stype._length_
	local data, errmsg = clib.calloc(size)
	if (data == nil) then
		error(string.format("clib malloc: %s", errmsg))
	end
	stype._data_ 	= data
	stype._n_ 		= n
	_populate(stype)
	return stype
end

function M.get(nth, key)
	if (key._root_._data_ == nil) then
		error("array already be freed")
	end

	local data = key._root_._data_
	local len = key._root_._length_

	if (nth > key._root_._n_) then
		return nil
	end

	if (key._type_ == TNUMBER) then
		-- number
		return clib.get_number(data, len, nth-1, key._offset_)
	elseif (key._type_ == TSTRING) then
		-- string
		return clib.get_string(data, len, nth-1, key._offset_)
	elseif (key._type_ == TBOOL) then
		-- boolean
		return clib.get_bool(data, len, nth-1, key._offset_)
	end
end

function M.set(nth, key, value)
	if (key._root_._data_ == nil) then
		error("array already be freed")
	end

	local len = key._root_._length_

	if (nth > key._root_._n_) then
		-- realloc
		local oldsize = len * key._root_._n_
		local newsize = len * nth
		local data, errmsg = clib.realloc(key._root_._data_, oldsize, newsize)
		if (data == nil) then
			error(string.format("clib realloc: %s", errmsg))
		end
		key._root_._data_ = data
		key._root_._n_ = nth
	end

	local data = key._root_._data_

	if (key._type_ == TNUMBER) then
		-- number
		clib.set_number(data, len, nth-1, key._offset_, value)
	elseif (key._type_ == TSTRING) then
		-- string
		clib.set_string(data, len, nth-1, key._offset_, value)
	elseif (key._type_ == TBOOL) then
		-- boolean
		clib.set_bool(data, len, nth-1, key._offset_, value)
	end
end

function M.free(stype)
	clib.free(stype._data_)
	stype._data_ = nil
end

function mt.__index(key, nth)
	if (type(nth) ~= "number") then
		return nil
	end
	if (key._type_ == TTABLE) then
		error("substruct can't use index syntax")
	end
	return M.get(nth, key)
end

function mt.__newindex(key, nth, value)
	if (key._type_ == TTABLE) then
		error("substruct can't use index syntax")
	end
	if (type(nth) ~= "number") then
		error("index shoud be number")
	end
	M.set(nth, key, value)
end
