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
				s = s .. tostring(v)
				if i ~= #self.statements then s = s .. ', ' end
			end
			s = s .. ']'

			return s .. ')'
		end,
	})
end

---@class Stmt.Class : Stmt
---@field public methods Stmt.Function[]
---@field public superclass Expr.Var
---@field public name Token

function node.Class(methods, superclass, name)
	return setmetatable({
		type = 'Class',
		methods = methods,
		superclass = superclass,
		name = name,
	}, {
		__tostring = function(self)
			local s = 'Class('

			s = s .. '['
			for i, v in ipairs(self.methods) do
				s = s .. tostring(v)
				if i ~= #self.methods then s = s .. ', ' end
			end
			s = s .. '], '

			s = s .. tostring(self.superclass) .. ', '
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
---@field public params Token[]
---@field public name Token

function node.Function(body, params, name)
	return setmetatable({
		type = 'Function',
		body = body,
		params = params,
		name = name,
	}, {
		__tostring = function(self)
			local s = 'Function('

			s = s .. '['
			for i, v in ipairs(self.body) do
				s = s .. tostring(v)
				if i ~= #self.body then s = s .. ', ' end
			end
			s = s .. '], '

			s = s .. '['
			for i, v in ipairs(self.params) do
				s = s .. tostring(v)
				if i ~= #self.params then s = s .. ', ' end
			end
			s = s .. '], '

			s = s .. tostring(self.name)

			return s .. ')'
		end,
	})
end

---@class Stmt.If : Stmt
---@field public condition Expr
---@field public elseBranch Stmt
---@field public thenBranch Stmt

function node.If(condition, thenBranch, elseBranch)
	return setmetatable({
		type = 'If',
		condition = condition,
		thenBranch = thenBranch,
		elseBranch = elseBranch,
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
---@field public initializer Expr
---@field public name Token

function node.Variable(initializer, name)
	return setmetatable({
		type = 'Variable',
		initializer = initializer,
		name = name,
	}, {
		__tostring = function(self)
			local s = 'Variable('

			s = s .. tostring(self.initializer) .. ', '
			s = s .. tostring(self.name)

			return s .. ')'
		end,
	})
end

---@class Stmt.While : Stmt
---@field public body Stmt
---@field public condition Expr

function node.While(body, condition)
	return setmetatable({
		type = 'While',
		body = body,
		condition = condition,
	}, {
		__tostring = function(self)
			local s = 'While('

			s = s .. tostring(self.body) .. ', '
			s = s .. tostring(self.condition)

			return s .. ')'
		end,
	})
end

---@class Expr.Assign : Expr
---@field public value Expr
---@field public name Token

function node.Assign(value, name)
	return setmetatable({
		type = 'Assign',
		value = value,
		name = name,
	}, {
		__tostring = function(self)
			local s = 'Assign('

			s = s .. tostring(self.value) .. ', '
			s = s .. tostring(self.name)

			return s .. ')'
		end,
	})
end

---@class Expr.Binary : Expr
---@field public op Token
---@field public left Expr
---@field public right Expr

function node.Binary(op, left, right)
	return setmetatable({
		type = 'Binary',
		op = op,
		left = left,
		right = right,
	}, {
		__tostring = function(self)
			local s = 'Binary('

			s = s .. tostring(self.op) .. ', '
			s = s .. tostring(self.left) .. ', '
			s = s .. tostring(self.right)

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
				s = s .. tostring(v)
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
---@field public op Token
---@field public left Expr
---@field public right Expr

function node.Logical(op, left, right)
	return setmetatable({
		type = 'Logical',
		op = op,
		left = left,
		right = right,
	}, {
		__tostring = function(self)
			local s = 'Logical('

			s = s .. tostring(self.op) .. ', '
			s = s .. tostring(self.left) .. ', '
			s = s .. tostring(self.right)

			return s .. ')'
		end,
	})
end

---@class Expr.Set : Expr
---@field public name Token
---@field public value Expr
---@field public object Expr

function node.Set(name, value, object)
	return setmetatable({
		type = 'Set',
		name = name,
		value = value,
		object = object,
	}, {
		__tostring = function(self)
			local s = 'Set('

			s = s .. tostring(self.name) .. ', '
			s = s .. tostring(self.value) .. ', '
			s = s .. tostring(self.object)

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
---@field public operator Token
---@field public right Expr

function node.Unary(operator, right)
	return setmetatable({
		type = 'Unary',
		operator = operator,
		right = right,
	}, {
		__tostring = function(self)
			local s = 'Unary('

			s = s .. tostring(self.operator) .. ', '
			s = s .. tostring(self.right)

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
			local s = 'Error('

			return s .. ')'
		end,
	})
end

return node
