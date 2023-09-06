local Type = require 'token'.Type

local Compiler = {}
Compiler.__index = Compiler

---@param ast Node
---@param indentSize integer
---@return Compiler
---@nodiscard
function Compiler.new(ast, indentSize)
	local self = setmetatable({}, Compiler)

	self.ast = ast

	self.result = ""
	self.indentLevel = 0
	self.indentSize = indentSize

	return self
end

---@private
function Compiler:indent()
	self.indentLevel = self.indentLevel + 1
end

---@private
function Compiler:unindent()
	self.indentLevel = self.indentLevel - 1
end

---Add `code` to `self.result`, respecting indentation.
---@param code string
---@private
function Compiler:emitWithIndent(code)
	if self.indentLevel ~= 0 then
		if not self.indentSize then
			self.result = self.result .. string.rep('\t', self.indentLevel)
		else
			self.result = self.result .. string.rep(' ', self.indentLevel + self.indentSize)
		end
	end

	self:emit(code)
end

function Compiler:emit(code)
	self.result = self.result .. code
end

---@param node Node
---@return string
function Compiler:visit(node)
	local name = "compile" .. node.type
	assert(self[name], "fatal: unknown node "..node.type)
	return self[name](self, node)
end

---@return string
---@nodiscard
function Compiler:compile()
	for _, s in ipairs(self.ast) do self:visit(s) end
	return self.result
end

function Compiler:compileBlock(node)
	for _, s in ipairs(node.statements) do self:visit(s) end
end

function Compiler:compileIf(node)
	self:emitWithIndent "if "
	self:visit(node.condition)
	self:emit " then\n"

	self:indent()
	self:visit(node.thenBranch)
	self:unindent()

	if node.elseBranch then
		self:emitWithIndent "else\n"

		self:indent()
		self:visit(node.elseBranch)
		self:unindent()
	end

	self:emitWithIndent "end\n"
end

function Compiler:compileWhile(node)
	self:emitWithIndent "while "

end

function Compiler:compilePrint(node)
	self:emitWithIndent "print("
	self:visit(node.expression)
	self:emit ")\n"
end

function Compiler:compileLiteral(node)
	local tok = node.value
	if tok.type == Type.TRUE then self:emit "true"
	elseif tok.type == Type.FALSE then self:emit "false"
	elseif tok.type == Type.NIL then self:emit "nil"

	elseif tok.type == Type.STRING
	or tok.type == Type.NUMBER then
		self:emit(tok.value)
	else
		self:visit(node.value) -- must be "Grouping", "Super" or others
	end
end

return setmetatable(Compiler, { __call = function(cls, ...) return cls.new(...) end })
