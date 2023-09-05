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

---Add `code` to `result`, respecting indentation.
---@param code string
---@private
function Compiler:emit(code)
	if not self.indentSize then
		self.result = self.result .. string.rep('\t', self.indentLevel)
	else
		self.result = self.result .. string.rep(' ', self.indent + self.indentSize)
	end

	self.result = self.result .. code .. "\n"
end

---@param node Node
---@return string
function Compiler:visit(node)
	assert(self[node.type], "fatal: unknown node "..node.type)
	return self[node.type](self, node)
end

---@return string
---@nodiscard
function Compiler:compile()
	for _, s in ipairs(self.ast) do
		self.code = self.code .. self:visit(s)
	end
	return self.code
end

return setmetatable(Compiler, { __call = function(cls, ...) return cls.new(...) end })
