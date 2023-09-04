local Token = require 'token'
local Type = Token.Type
local reporter = require 'reporter'

local Lexer = {}
Lexer.__index = Lexer

local KEYWORDS = {
	["and"] = Type.AND,
	["class"] = Type.CLASS,
	["else"] = Type.ELSE,
	["false"] = Type.FALSE,
	["for"] = Type.FOR,
	["fun"] = Type.FUN,
	["if"] = Type.IF,
	["nil"] = Type.NIL,
	["or"] = Type.OR,
	["print"] = Type.PRINT,
	["return"] = Type.RETURN,
	["super"] = Type.SUPER,
	["this"] = Type.THIS,
	["true"] = Type.TRUE,
	["var"] = Type.VAR,
	["while"] = Type.WHILE,
}

---@param source string
---@return Lexer
---@nodiscard
function Lexer.new(source)
	local self = setmetatable({}, Lexer)

	self.source = source
	self.pos = 1
	self.curChar = source:sub(1,1)
	self.saved = nil

	self.line1 = 1
	self.col1 = 0
	self.line2 = self.line1
	self.col2 = self.col1

	return self
end

---@private
function Lexer:advance(onlyEnd)
	if onlyEnd == nil then onlyEnd = false end

	local oldChar = self.curChar
	self.pos = self.pos + 1
	self.curChar = self.pos <= #self.source and self.source:sub(self.pos, self.pos) or nil

	if self.curChar == '\n' then
		self.line2 = self.line2 + 1
		self.col2 = 0
	else
		self.col2 = self.col2 + 1
	end

	if not onlyEnd then
		self.line1, self.col1 = self.line2, self.col2
	end

	return oldChar
end

---@private
---@return string?
---@nodiscard
function Lexer:peekChar()
	local p = self.pos + 1
	if p < #self.source then return self.source:sub(p, p) end
end

---Advances if current character is `char`
---@private
---@return boolean
---@nodiscard
function Lexer:match(char)
	if self.curChar == char then
		self:advance(true)
		return true
	end

	return false
end

---@private
---@param msg string
---@param printLine boolean?
---@return Token
---@nodiscard
function Lexer:error(msg, printLine)
	reporter:error(msg,
		self.line1, self.col1,
		self.line2, self.col2,
		printLine
	)

	return self:makeToken(Type.ERROR)
end

---@param type Token.Type
---@param value any
---@return Token
---@nodiscard
function Lexer:makeToken(type, value)
	return Token(type, value, {
		line1=self.line1, col1=self.col1,
		line2=self.line2, col2=self.col2,
	})
end

---@private
---@return Token
---@nodiscard
function Lexer:string()
	local str = ""
	while self.curChar and self.curChar ~= '"' do
		str = str .. self:advance(true)
	end

	if not self.curChar then
		return self:error("missing closing quote", false)
	end

	self:advance() -- '"'

	return self:makeToken(Type.STRING, str)
end

---@private
---@return Token
---@nodiscard
function Lexer:number()
	local num = ""
	while self.curChar and self.curChar:match "%d" do
		num = num .. self:advance(true)
	end

	local nextChar = self:peekChar()
	if self.curChar == '.' and nextChar and nextChar:match "%d" then
		num = num .. self:advance(true)
		while self.curChar and self.curChar:match "%d" do
			num = num .. self:advance(true)
		end
	end

	return self:makeToken(Type.NUMBER, tonumber(num))
end

---@private
---@nodiscard
---@return Token
function Lexer:identifier()
	local id = ""
	while self.curChar and self.curChar:match "%w" do
		id = id .. self:advance(true)
	end

	local type = Type.IDENTIFIER
	if KEYWORDS[id] then type = KEYWORDS[id] end
	if type ~= Type.IDENTIFIER then id = nil end
	return self:makeToken(type, id)
end

---@private
---@return Token
---@nodiscard
function Lexer:doNext()
	while self.curChar and self.curChar:match "%s" do
		self:advance()
	end

	if not self.curChar then return self:makeToken(Type.EOF) end

	if     self:match '(' then return self:makeToken(Type.LPAREN)
	elseif self:match ')' then return self:makeToken(Type.RPAREN)
	elseif self:match '{' then return self:makeToken(Type.LBRACE)
	elseif self:match '}' then return self:makeToken(Type.RBRACE)
	elseif self:match ',' then return self:makeToken(Type.COMMA)
	elseif self:match '.' then return self:makeToken(Type.DOT)
	elseif self:match '-' then return self:makeToken(Type.MINUS)
	elseif self:match '+' then return self:makeToken(Type.PLUS)
	elseif self:match '*' then return self:makeToken(Type.STAR)
	elseif self:match ';' then return self:makeToken(Type.SEMICOLON)
	end

	if     self:match '!' then
		if self:match '=' then return self:makeToken(Type.BANG_EQUAL)
		else return self:makeToken(Type.BANG) end
	elseif self:match '=' then
		if self:match '=' then return self:makeToken(Type.EQUAL_EQUAL)
		else return self:makeToken(Type.EQUAL) end
	elseif self:match '>' then
		if self:match '=' then return self:makeToken(Type.GREATER_EQUAL)
		else return self:makeToken(Type.GREATER) end
	elseif self:match '<' then
		if self:match '=' then return self:makeToken(Type.LESS_EQUAL)
		else return self:makeToken(Type.LESS) end

	elseif self:match '/' then
		if self:match '/' then
			while self.curChar and self.curChar ~= '\n' do
				self:advance()
			end
			return self:doNext()
		else
			return self:makeToken(Type.SLASH)
		end

	elseif self:match '"' then
		return self:string()
	elseif self.curChar and self.curChar:match "%d" then
		return self:number()
	elseif self.curChar and self.curChar:match "%a" then
		return self:identifier()
	else
		local e = self:error("unexpected character '"..self.curChar.."'")
		self:advance()
		return e
	end
end

---Returns the next token.
---@return Token?
---@nodiscard
function Lexer:next()
	if self.saved then
		local temp = self.saved
		self.saved = nil
		return temp
	else
		return self:doNext()
	end
end

---Returns the current token.
---@return Token
---@nodiscard
function Lexer:peek()
	if not self.saved then
		self.saved = self:next()
	end
	return self.saved
end

return setmetatable(Lexer, {
	__call = function(cls, ...) return cls.new(...) end, })
