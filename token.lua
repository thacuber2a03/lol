local Token = {}
Token.__index = Token

---@class Token
---@field public type Token.Type
---@field public value any
---@field public line integer
---@field public col integer

---@enum Token.Type
Token.Type = {
	LPAREN="LPAREN", RPAREN="RPAREN",
	LBRACE="LBRACE", RBRACE="RBRACE",
	COMMA="COMMA", DOT="DOT", MINUS="MINUS", PLUS="PLUS",
	SEMICOLON="SEMICOLON",SLASH="SLASH", STAR="STAR",

	BANG="BANG", BANG_EQUAL="BANG_EQUAL",
	EQUAL="EQUAL", EQUAL_EQUAL="EQUAL_EQUAL",
	GREATER="GREATER", GREATER_EQUAL="GREATER_EQUAL",
	LESS="LESS", LESS_EQUAL="LESS_EQUAL",

	IDENTIFIER="IDENTIFIER",
	STRING="STRING",
	NUMBER="NUMBER",

	AND="AND", CLASS="CLASS", ELSE="ELSE", FALSE="FALSE",
	FOR="FOR", FUN="FUN", IF="IF", NIL="NIL", OR="OR",
	PRINT="PRINT", RETURN="RETURN", SUPER="SUPER",
	THIS="THIS", TRUE="TRUE", VAR="VAR", WHILE="WHILE",

	EOF="EOF", ERROR="ERROR"
}

local function unescape(s)
	if type(s) ~= "string" then return s end
	return s
		:gsub("\n", "\\n")
		:gsub("\t", "\\t")
end

---@param type Token.Type
---@param value any
---@param line integer
---@param col integer
function Token.new(type, value, line, col)
	---@type Token
	local self = setmetatable({}, Token)

	self.type = type
	self.value = value
	self.line = line
	self.col = col

	return self
end

function Token:__tostring()
	local s = self.type
	if self.type == Token.Type.ERROR then
		local l1, c1, l2, c2 =
			self.value.line1, self.value.col1,
			self.value.line2, self.value.col2

		if l1 == l2 and c1 == c2 then
			s = s .. string.format(" at (%i, %i)", l1, c1)
		else
			s = s .. string.format(" from (%i, %i) to (%i, %i)", l1, c1, l2, c2)
		end
	else
		if self.value then s = s .. "(" .. unescape(self.value) .. ")" end
	end
	return s
end

return setmetatable(Token, {
	__call = function(cls, ...) return cls.new(...) end,
})
