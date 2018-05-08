local EVALUATE_TYPE = {
	SELECTOR    = "SEL",
	PARALLEL    = "PAR",
	SEQUENCE    = "SEQ",
	CONDITIONAL = "CON",
	BEHAVIOR    = "ACT",
}

local table_insert = table.insert
local table_remove = table.remove
local string_upper = string.upper
local string_match = string.match
local string_rep = string.rep
local string_len = string.len
local string_find = string.find
local string_sub = string.sub
local string_format = string.format
local ipairs = ipairs
local type = type
local tostring = tostring

local string_split = string.split or function (input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string_find(input, delimiter, pos, true) end do
        table_insert(arr, string_sub(input, pos, st - 1))
        pos = sp + 1
    end
    table_insert(arr, string_sub(input, pos))
    return arr
end

local util_filter = function(fn, datas)
	local result = {}
	for i, data in ipairs(datas) do
		if fn(data) then
			result[#result + 1] = data
		end
	end
	return result
end

local util_find = function ( fn, datas )
	for i, data in ipairs(datas) do
		if fn(data) then return data end
	end
end

-- 前期调试用,确定后改为nil或false
local debug = true

-- 行为树
local BehaviorTree = {}

BehaviorTree.__meta = {
    __index = BehaviorTree,
}

function BehaviorTree:new(fulltree)
	local ret = {}
    setmetatable(ret, self.__meta)
	ret:init(fulltree)
	return ret
end

function BehaviorTree:init(fulltree)
	self.fulltree = fulltree
end

function BehaviorTree:run(entity)
	self:_behave(self.fulltree, entity)
end

local function ___logState( tree, entity, result)
	print(string_format("%s:%s:%s", tree.bttype, tree.name, tostring(result)))
end

function BehaviorTree:_behave( tree, entity )
	local behaveType = tree.bttype
	if behaveType == EVALUATE_TYPE.CONDITIONAL then 
		-- 处理条件判断 CON
		return self:_condition(tree, entity)
	elseif behaveType == EVALUATE_TYPE.BEHAVIOR then 
		-- 处理动作 ACT
		return self:_action(tree, entity)
	elseif behaveType == EVALUATE_TYPE.SELECTOR then 
		-- 处理选择执行 SEL
		return self:_select(tree, entity)
	elseif behaveType == EVALUATE_TYPE.SEQUENCE then 
		-- 处理顺序执行 SEQ
		return self:_sequence(tree, entity)
	elseif behaveType == EVALUATE_TYPE.PARALLEL then 
		-- 处理并列执行 PAR
		return self:_parallel(tree, entity)
	end
	return false
end

function BehaviorTree:_select( tree, entity )
	local children = tree.children
	local result = util_find(function ( child, index )
		return self:_behave(child, entity)
	end, children)
	return result ~= nil
end

function BehaviorTree:_sequence( tree, entity )
	local children = tree.children
	local result = util_find(function ( child, index )
		return not self:_behave(child, entity)
	end, children)
	return result == nil
end

function BehaviorTree:_parallel( tree, entity )
	local children = tree.children
	local filterResult = util_filter(function ( child, index )
		return self:_behave(child, entity)
	end, children)
	local trueCount = #filterResult
	local allCount = #children
	local bttypeParam = tree.bttypeParam or "ALL"
	local result = false
	if "ALL" == bttypeParam then 
		-- Parallel Succeed On All Node: 所有True才返回True，否则返回False。
		result = trueCount == allCount
	elseif "TRUE" == bttypeParam then 
		result = true
	elseif "FALSE" == bttypeParam then 
		result = false
	else
		-- Parallel Hybird Node: 指定数量的Child Node返回True或False后才决定结果
		local count = tonumber(bttypeParam)
		if count then
			result = trueCount >= count
		end
	end
	return result
end

function BehaviorTree:_condition( tree, entity )
	return self:_run(tree, entity, "condition")
end

function BehaviorTree:_action( tree, entity )
	return self:_run(tree, entity, "action") ~= false
end

function BehaviorTree:_run( tree, entity, typeStr )
	local ret = entity[tree.fun](entity, tree.param)

	if debug then
		___logState( tree, entity, ret)
	end

	return ret
end

return BehaviorTree