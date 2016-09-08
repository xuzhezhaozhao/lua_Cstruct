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

local function _define_structure(ltype, offset)
	if (offset == nil) then
		offset = 0
	end
	local struct = {_length_ = 0}
	for k, v in pairs(ltype) do
		local curoffset = offset + struct._length_
		if (v == "number") then
			struct[k] = {_type_ = TNUMBER, _offset_ = curoffset}
			struct._length_ = struct._length_ + numLen
		elseif (v == "string") then
			struct[k] = {_type_ = TSTRING, _offset_ = curoffset}
			struct._length_ = struct._length_ + strLen
		elseif (v == "bool") then
			struct[k] = {_type_ = TBOOL, offset = curoffset}
			struct._length_ = struct._length_ + strLen
		elseif (type(v) == "table") then
			local substruct = _define_structure(v, curoffset)
			struct[k] = substruct;
			struct[k]._type_ = TTABLE;
			struct[k]._offset_ = curoffset;
			struct._length_ = struct._length_ + substruct._length_
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
	local stype = _define_structure(ltype)
	local data, errmsg = clib.calloc(n*stype._length_)
	stype._data_ 	= data
	stype._n_ 		= n
	_populate(stype)
	return stype
end


function M.get(nth, key)
	local data = key._root_._data_
	local len = key._root_._length_

	if (key._type_ == TNUMBER) then
		-- number
		return clib.get_number(data, len, nth-1, key._offset_)
	elseif (key._type_ == TSTRING) then
		-- string
		return clib.get_string(data, len, nth-1, key._offset_)
	elseif (key._type_ == TBOOL) then
		-- boolean
		return clib.get_bool(data, len, nth-1, key._offset_)
	elseif (key._type_ == TTABLE) then
		-- table, error
		return nil
	else
		return nil
	end
end

function M.set(nth, key, value)
	local len = key._root_._length_

	if (nth > key._root_._n_) then
		-- realloc
		key._root_._data_ = clib.realloc(key._root_._data_, len*nth)
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
	elseif (key._type_ == TTABLE) then
		-- table, error
	else
	end
end

function M.free(stype)
	clib.free(stype._data_)
	stype._data_ = nil
end

function mt.__index(self, k)
	if (type(k) ~= "number") then
		return nil
	end
	return M.get(k, self)
end

function mt.__newindex(self, k, value)
	if (type(k) ~= "number") then
		return nil
	end
	M.set(k, self, value)
end
