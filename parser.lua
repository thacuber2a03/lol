local Parser = {}
Parser.__index = Parser

function Parser.new(lexer)
	local self = setmetatable({}, Parser)

	self.lexer = lexer

	return self
end

function Parser:parse()
end

return setmetatable(Parser, {
	__call = function(cls, ...) return cls.new(...) end,
})
