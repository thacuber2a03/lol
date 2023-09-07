local debugger = require 'debugger'

local reporter = require 'reporter'
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

	
	self.assignExpr = false
	self.variables = {}

	self.result = ""
	self.indentLevel = 0
	self.indentSize = indentSize

	return self
end

---@private
---@param tok Token
---@param msg string
---@param printLine boolean?
function Compiler:error(tok, msg, printLine)
	reporter:error(msg,
		tok.pos.line1, tok.pos.col1,
		tok.pos.line2, tok.pos.col2, printLine
	)
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
			self.result = self.result .. string.rep(' ', self.indentLevel * self.indentSize)
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
	assert(node, "what")
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
	self:emitWithIndent "do\n"
	self:indent()
	for _, s in ipairs(node.statements) do self:visit(s) end
	self:unindent()
	self:emitWithIndent "end\n"
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
	self.assignExpr = true
	self:emitWithIndent "while "
	self:visit(node.condition)
	self:emit " do\n"
	self.assignExpr = false

	
	self:indent()
	self:visit(node.body)
	self:unindent()
	

	self:emitWithIndent "end\n"
end

function Compiler:compileFor(node)
	if node.initializer
	and node.initializer.type == "Variable" then
		local id = node.initializer.name.value
		local condition = node.condition
		local step = node.step

		if condition.type == "Binary"
		and condition.left.type == "Var"
		and condition.left.name.value == id
		and condition.op.type == Type.LESS_EQUAL
		and condition.right.type == "Literal"
		and condition.right.value.type == Type.NUMBER

		and step.type == "Assign"
		and step.name.value == id
		and step.value.type == "Binary"
		and step.value.left.type == "Var"
		and step.value.left.name.value == id
		and step.value.right.type == "Literal"
		and step.value.right.value.type == Type.NUMBER then

			-- holy shit that was one hell of a ride
			self:emitWithIndent "for "
			self:emit(node.initializer.name.value)
			self:emit " = "
			self:emit(node.initializer.initializer.value.value)
			self:emit ", "
			self:emit(node.condition.right.value.value)
			if node.step.value.right.value.value ~= 1 then
				self:emit ", "
				self:emit(node.step.value.right.value.value)
			end
			self:emit " do\n"

			
			self:indent()
			self:visit(node.body)
			self:unindent()
			

			self:emitWithIndent "end\n"
			return
		end
	end

	if node.initializer then self:visit(node.initializer) end

	self:emitWithIndent "while "
	if node.condition then
		self:visit(node.condition)
	else
		self:emit("true")
	end
	self:emit " do\n"

	
	self:indent()

	self:visit(node.body)
	if node.step then self:visit(node.step) end

	self:unindent()
	
	self:emitWithIndent "end\n"
end

function Compiler:compileFunction(node)
	-- "local" for a performance boost
	-- as you can't import files from/to Lox
	self:emitWithIndent "local function "
	self:emit(node.name.value)
	self:emit "("
	for i, p in ipairs(node.params) do
		self:emit(p)
		if i ~= #node.params then self:emit ", " end
	end
	self:emit ")\n"

	self:indent()
	self:visit(node.body)
	self:unindent()

	self:emitWithIndent "end\n"
end

function Compiler:compileVar(node)
	if not self.variables[node.name.value] then
		self:error(node.name, "'" .. node.name.value .. "' not yet defined")
	end
	self:emit(node.name.value)
end

function Compiler:compileAssign(node)
	if not self.variables[node.name.value] then
		self:error(node.name, "'" .. node.name.value .. "' not yet defined")
	end

	if self.assignExpr then
		-- there's definitely better ways to do this one
		self:emitWithIndent "(function() "
		self:emit(node.name.value)
		self:emit " = "
		self:visit(node.value)
		self:emit "; return "
		self:emit(node.name.value)
		self:emit " end)()\n"
	else
		self:emitWithIndent(node.name.value)
		self:emit " = "
		self:visit(node.value)
		self:emit "\n"
	end
end

function Compiler:compileVariable(node)
	if self.variables[node.name.value] then
		self:error(node.name, "'" .. node.name.value .. "' is already defined")
	end
	self.variables[node.name.value] = true
	self:emitWithIndent("local ")
	self:emit(node.name.value)
	if node.initializer then
		self:emit " = "
		self:visit(node.initializer)
	end
	self:emit "\n"
end

function Compiler:compilePrint(node)
	self:emitWithIndent "print("
	self:visit(node.expression)
	self:emit ")\n"
end

function Compiler:compileExpression(node) -- statement
	-- basically no work
	self:visit(node.expression)
end

function Compiler:compileCall(node)
	self:visit(node.callee)
	self:emit "("
	for i, a in ipairs(node.arguments) do
		self:visit(a)
		if i ~= #node.arguments then self:emit ", " end
	end
	self:emit ")"
end

function Compiler:compileGrouping(node)
	self:emit "("
	self:visit(node.expression)
	self:emit ")"
end

function Compiler:compileBinary(node)
	self:visit(node.left)
	self:emit " "
	local op = node.op.type
	if     op == Type.PLUS          then self:emit "+"
	elseif op == Type.MINUS         then self:emit "-"
	elseif op == Type.STAR          then self:emit "*"
	elseif op == Type.SLASH         then self:emit "/"
	elseif op == Type.EQUAL_EQUAL   then self:emit "=="
	elseif op == Type.BANG_EQUAL    then self:emit "~="
	elseif op == Type.LESS          then self:emit "<"
	elseif op == Type.LESS_EQUAL    then self:emit "<="
	elseif op == Type.GREATER       then self:emit ">"
	elseif op == Type.GREATER_EQUAL then self:emit ">="
	else error("unknown operator "..op)
	end
	self:emit " "
	self:visit(node.right)
end

function Compiler:compileLiteral(node)
	local tok = node.value
	if tok.type == Type.TRUE then self:emit "true"
	elseif tok.type == Type.FALSE then self:emit "false"
	elseif tok.type == Type.NIL then self:emit "nil"

	elseif tok.type == Type.NUMBER
		or tok.type == Type.IDENTIFIER then
		self:emit(tok.value)
	elseif tok.type == Type.STRING then
		self:emit('"'..tok.value..'"')
	else
		self:visit(node.value) -- must be "Grouping", "Super" or others
	end
end

return setmetatable(Compiler, { __call = function(cls, ...) return cls.new(...) end })
