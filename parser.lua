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
---@nodiscard
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
	if self:match(Type.LBRACE) then
		return self:block()
	elseif self:match(Type.PRINT) then
		return self:printStatement()
	elseif self:match(Type.WHILE) then
		return self:whileStatement()
	elseif self:match(Type.IF) then
		return self:ifStatement()
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

function Parser:whileStatement()
	self:consume(Type.LPAREN, "expected '(' after while")
	local cond = self:expression()
	self:consume(Type.RPAREN, "expected ')' after expression")
	local stmt = self:statement()
	return node.While(cond, stmt)
end

function Parser:ifStatement()
	self:consume(Type.LPAREN, "expected '(' after if")
	local cond = self:expression()
	self:consume(Type.RPAREN, "expected ')' after expression")
	local thenBranch = self:statement()

	local elseBranch
	if self:match(Type.ELSE) then
		elseBranch = self:statement()
	end

	return node.If(cond, thenBranch, elseBranch)
end

function Parser:block()
	local declarations = {}
	while not (self:isAtEnd() or self:match(Type.RBRACE)) do
		table.insert(declarations, self:declaration())
	end
	return node.Block(declarations)
end

function Parser:expression()
	-- tail-call optimization go brrrrrr
	return self:assignment()
end

function Parser:assignment()
	-- TODO(thacuber2a03): assignments
	return self:logicOr()
end

function Parser:binary(methodName, types, result)
	local left = self[methodName](self)

	while true do
		local didMatch = false

		for _, t in ipairs(types) do
			if self:check(t) then
				local op = self:next()
				local right = self[methodName](self)
				left = result(left, op, right)
				didMatch = true
			end
		end

		if not didMatch then break end
	end

	return left
end

function Parser:logicOr() return self:binary("logicAnd", { Type.OR }, node.Logical) end
function Parser:logicAnd() return self:binary("equality", { Type.AND }, node.Logical) end

function Parser:equality() return self:binary("comparison", { Type.BANG_EQUAL, Type.EQUAL_EQUAL }, node.Binary) end
function Parser:comparison() return self:binary("term", { Type.GREATER, Type.GREATER_EQUAL, Type.LESS, Type.LESS_EQUAL }, node.Binary) end
function Parser:term() return self:binary("factor", { Type.PLUS, Type.MINUS }, node.Binary) end
function Parser:factor() return self:binary("unary", { Type.SLASH, Type.STAR }, node.Binary) end

function Parser:unary()
	if self:check(Type.BANG) or self:check(Type.MINUS) then
		local op = self:next()
		return node.Unary(op, self:unary())
	end

	return self:call()
end

function Parser:call()
	local name = self:primary()

	while true do
		if self:match(Type.DOT) then
			local object = self:consume(Type.IDENTIFIER)
			name = node.Get(name, object)
		elseif self:match(Type.LPAREN) then
			local args = {}
			if not self:match(Type.RPAREN) then args = self:arguments() end
			name = node.Call(name, args)
		else
			break
		end
	end

	return name
end

function Parser:arguments()
	local arguments = { self:expression() }
	while not self:match(Type.COMMA) do
		table.insert(arguments, self:expression())
	end
	return arguments
end

function Parser:primary()
	if self:check(Type.TRUE)
	or self:check(Type.FALSE)
	or self:check(Type.NIL)
	or self:check(Type.THIS)
	or self:check(Type.NUMBER)
	or self:check(Type.STRING)
	or self:check(Type.IDENTIFIER) then
		return node.Literal(self:next())
	end

	if self:match(Type.LPAREN) then
		local expr = self:expression()
		self:consume(Type.RPAREN, "expected closing ')'")
		return node.Grouping(expr)
	end

	if self:check(Type.SUPER) then
		local super = self:next()
		self:consume(Type.DOT, "expected '.' after 'super'")
		local id = self:consume(Type.IDENTIFIER)
		return node.Super(id, super)
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
