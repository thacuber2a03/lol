local node = require 'node'
local Type = require 'token'.Type
local reporter = require 'reporter'

local Parser = {}
Parser.__index = Parser

---@class Parser
---@field private lexer Lexer
---@field private pos integer

---@param lexer Lexer
---@return Parser
function Parser.new(lexer)
	local self = setmetatable({}, Parser)

	self.lexer = lexer

	return self
end

function Parser:error(msg, printLine)
	local pos = self.lexer:peek().pos
	reporter:error(msg,
		pos.line1, pos.col1,
		pos.line2, pos.col2,
		printLine
	)
	self:next()
	return node.Error(
		pos.line1, pos.col1,
		pos.line2, pos.col2
	)
end

---Parses the source code.
---@return Stmt[]
function Parser:parse()
	local declarations = {}
	while not self:isAtEnd() do
		table.insert(declarations, self:declaration())
	end
	return declarations
end

function Parser:declaration()
	return self:statement()
end

function Parser:statement()
	if self:match(Type.PRINT) then
		return self:printStatement()
	end

	return self:expressionStatement()
end

function Parser:expressionStatement()
	local expr = self:expression()
	self:consume(Type.SEMICOLON, "expected ';' after expression")
	return node.Expression(expr)
end

function Parser:printStatement()
	local expr = self:expression()
	self:consume(Type.SEMICOLON, "expected ';' after expression")
	return node.Print(expr)
end

function Parser:expression()
	if self:check(Type.STRING)
	or self:check(Type.NUMBER)
	or self:check(Type.TRUE)
	or self:check(Type.FALSE)
	or self:check(Type.NIL) then
		return node.Literal(self:next())
	end

	return self:error("unrecognized expression")
end

function Parser:next() return self.lexer:next() end
function Parser:peek() return self.lexer:peek() end

function Parser:match(type)
	if self:check(type) then
		self:next()
		return true
	end

	return false
end

function Parser:check(type)
	return self:peek().type == type
end

function Parser:consume(type, err)
	if self:check(type) then
		self:next()
	else
		self:error(err)
	end
end

function Parser:isAtEnd()
	return self:check(Type.EOF)
end

return setmetatable(Parser, {
	__call = function(cls, ...) return cls.new(...) end,
})
