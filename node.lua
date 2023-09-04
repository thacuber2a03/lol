local node = {}

---@class Stmt

---@class Expr
---@class Stmt.Block : Stmt
---@field public statements Stmt[]

function node.Block(statements)
	return setmetatable({
		type = 'Block',
		statements = statements,
	}, {
		__tostring = function(self)
			local s = 'Block('

			s = s .. '['
			for i, v in ipairs(self.statements) do
				s = s .. v
				if i ~= #self.statements then s = s .. ', ' end
			end
			s = s .. ']'

			return s .. ')'
		end,
	})
end

---@class Stmt.Class : Stmt
---@field public superclass Expr.Variable
---@field public methods Stmt.Function[]
---@field public name Token

function node.Class(superclass, methods, name)
	return setmetatable({
		type = 'Class',
		superclass = superclass,
		methods = methods,
		name = name,
	}, {
		__tostring = function(self)
			local s = 'Class('

			s = s .. tostring(self.superclass) .. ', '
			s = s .. '['
			for i, v in ipairs(self.methods) do
				s = s .. v
				if i ~= #self.methods then s = s .. ', ' end
			end
			s = s .. '], '

			s = s .. tostring(self.name)

			return s .. ')'
		end,
	})
end

---@class Stmt.Expression : Stmt
---@field public expression Expr

function node.Expression(expression)
	return setmetatable({
		type = 'Expression',
		expression = expression,
	}, {
		__tostring = function(self)
			local s = 'Expression('

			s = s .. tostring(self.expression)

			return s .. ')'
		end,
	})
end

---@class Stmt.Function : Stmt
---@field public body Stmt[]
---@field public name Token
---@field public params Token[]

function node.Function(body, name, params)
	return setmetatable({
		type = 'Function',
		body = body,
		name = name,
		params = params,
	}, {
		__tostring = function(self)
			local s = 'Function('

			s = s .. '['
			for i, v in ipairs(self.body) do
				s = s .. v
				if i ~= #self.body then s = s .. ', ' end
			end
			s = s .. '], '

			s = s .. tostring(self.name) .. ', '
			s = s .. '['
			for i, v in ipairs(self.params) do
				s = s .. v
				if i ~= #self.params then s = s .. ', ' end
			end
			s = s .. ']'

			return s .. ')'
		end,
	})
end

---@class Stmt.If : Stmt
---@field public condition Expr
---@field public elseBranch Stmt
---@field public thenBranch Stmt

function node.If(condition, elseBranch, thenBranch)
	return setmetatable({
		type = 'If',
		condition = condition,
		elseBranch = elseBranch,
		thenBranch = thenBranch,
	}, {
		__tostring = function(self)
			local s = 'If('

			s = s .. tostring(self.condition) .. ', '
			s = s .. tostring(self.elseBranch) .. ', '
			s = s .. tostring(self.thenBranch)

			return s .. ')'
		end,
	})
end

---@class Stmt.Print : Stmt
---@field public expression Token

function node.Print(expression)
	return setmetatable({
		type = 'Print',
		expression = expression,
	}, {
		__tostring = function(self)
			local s = 'Print('

			s = s .. tostring(self.expression)

			return s .. ')'
		end,
	})
end

---@class Stmt.Return : Stmt
---@field public value Expr
---@field public keyword Token

function node.Return(value, keyword)
	return setmetatable({
		type = 'Return',
		value = value,
		keyword = keyword,
	}, {
		__tostring = function(self)
			local s = 'Return('

			s = s .. tostring(self.value) .. ', '
			s = s .. tostring(self.keyword)

			return s .. ')'
		end,
	})
end

---@class Stmt.Variable : Stmt
---@field public name Token
---@field public initializer Expr

function node.Variable(name, initializer)
	return setmetatable({
		type = 'Variable',
		name = name,
		initializer = initializer,
	}, {
		__tostring = function(self)
			local s = 'Variable('

			s = s .. tostring(self.name) .. ', '
			s = s .. tostring(self.initializer)

			return s .. ')'
		end,
	})
end

---@class Stmt.While : Stmt
---@field public condition Expr
---@field public body Stmt

function node.While(condition, body)
	return setmetatable({
		type = 'While',
		condition = condition,
		body = body,
	}, {
		__tostring = function(self)
			local s = 'While('

			s = s .. tostring(self.condition) .. ', '
			s = s .. tostring(self.body)

			return s .. ')'
		end,
	})
end

---@class Expr.Assign : Expr
---@field public name Token
---@field public value Expr

function node.Assign(name, value)
	return setmetatable({
		type = 'Assign',
		name = name,
		value = value,
	}, {
		__tostring = function(self)
			local s = 'Assign('

			s = s .. tostring(self.name) .. ', '
			s = s .. tostring(self.value)

			return s .. ')'
		end,
	})
end

---@class Expr.Binary : Expr
---@field public right Expr
---@field public left Expr
---@field public op Token

function node.Binary(right, left, op)
	return setmetatable({
		type = 'Binary',
		right = right,
		left = left,
		op = op,
	}, {
		__tostring = function(self)
			local s = 'Binary('

			s = s .. tostring(self.right) .. ', '
			s = s .. tostring(self.left) .. ', '
			s = s .. tostring(self.op)

			return s .. ')'
		end,
	})
end

---@class Expr.Call : Expr
---@field public paren Token
---@field public callee Expr
---@field public arguments Expr[]

function node.Call(paren, callee, arguments)
	return setmetatable({
		type = 'Call',
		paren = paren,
		callee = callee,
		arguments = arguments,
	}, {
		__tostring = function(self)
			local s = 'Call('

			s = s .. tostring(self.paren) .. ', '
			s = s .. tostring(self.callee) .. ', '
			s = s .. '['
			for i, v in ipairs(self.arguments) do
				s = s .. v
				if i ~= #self.arguments then s = s .. ', ' end
			end
			s = s .. ']'

			return s .. ')'
		end,
	})
end

---@class Expr.Get : Expr
---@field public name Token
---@field public object Expr

function node.Get(name, object)
	return setmetatable({
		type = 'Get',
		name = name,
		object = object,
	}, {
		__tostring = function(self)
			local s = 'Get('

			s = s .. tostring(self.name) .. ', '
			s = s .. tostring(self.object)

			return s .. ')'
		end,
	})
end

---@class Expr.Grouping : Expr
---@field public expression Expr

function node.Grouping(expression)
	return setmetatable({
		type = 'Grouping',
		expression = expression,
	}, {
		__tostring = function(self)
			local s = 'Grouping('

			s = s .. tostring(self.expression)

			return s .. ')'
		end,
	})
end

---@class Expr.Literal : Expr
---@field public value any

function node.Literal(value)
	return setmetatable({
		type = 'Literal',
		value = value,
	}, {
		__tostring = function(self)
			local s = 'Literal('

			s = s .. tostring(self.value)

			return s .. ')'
		end,
	})
end

---@class Expr.Logical : Expr
---@field public right Expr
---@field public left Expr
---@field public op Token

function node.Logical(right, left, op)
	return setmetatable({
		type = 'Logical',
		right = right,
		left = left,
		op = op,
	}, {
		__tostring = function(self)
			local s = 'Logical('

			s = s .. tostring(self.right) .. ', '
			s = s .. tostring(self.left) .. ', '
			s = s .. tostring(self.op)

			return s .. ')'
		end,
	})
end

---@class Expr.Set : Expr
---@field public value Expr
---@field public object Expr
---@field public name Token

function node.Set(value, object, name)
	return setmetatable({
		type = 'Set',
		value = value,
		object = object,
		name = name,
	}, {
		__tostring = function(self)
			local s = 'Set('

			s = s .. tostring(self.value) .. ', '
			s = s .. tostring(self.object) .. ', '
			s = s .. tostring(self.name)

			return s .. ')'
		end,
	})
end

---@class Expr.Super : Expr
---@field public method Token
---@field public keyword Token

function node.Super(method, keyword)
	return setmetatable({
		type = 'Super',
		method = method,
		keyword = keyword,
	}, {
		__tostring = function(self)
			local s = 'Super('

			s = s .. tostring(self.method) .. ', '
			s = s .. tostring(self.keyword)

			return s .. ')'
		end,
	})
end

---@class Expr.This : Expr
---@field public keyword Token

function node.This(keyword)
	return setmetatable({
		type = 'This',
		keyword = keyword,
	}, {
		__tostring = function(self)
			local s = 'This('

			s = s .. tostring(self.keyword)

			return s .. ')'
		end,
	})
end

---@class Expr.Unary : Expr
---@field public right Expr
---@field public operator Token

function node.Unary(right, operator)
	return setmetatable({
		type = 'Unary',
		right = right,
		operator = operator,
	}, {
		__tostring = function(self)
			local s = 'Unary('

			s = s .. tostring(self.right) .. ', '
			s = s .. tostring(self.operator)

			return s .. ')'
		end,
	})
end

---@class Expr.Var : Expr
---@field public name Token

function node.Var(name)
	return setmetatable({
		type = 'Var',
		name = name,
	}, {
		__tostring = function(self)
			local s = 'Var('

			s = s .. tostring(self.name)

			return s .. ')'
		end,
	})
end

---@class Expr.Error : Expr

function node.Error()
	return setmetatable({
		type = 'Error',
	}, {
		__tostring = function(self)
			local s = 'Error'

			return s .. ')'
		end,
	})
end

return node
