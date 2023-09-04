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
---@field public methods Stmt.Function[]
---@field public name Token
---@field public superclass Expr.Variable

function node.Class(methods, name, superclass)
	return setmetatable({
		type = 'Class',
		methods = methods,
		name = name,
		superclass = superclass,
	}, {
		__tostring = function(self)
			local s = 'Class('

			s = s .. '['
			for i, v in ipairs(self.methods) do
				s = s .. v
				if i ~= #self.methods then s = s .. ', ' end
			end
			s = s .. '], '

			s = s .. tostring(self.name) .. ', '
			s = s .. tostring(self.superclass)

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
---@field public thenBranch Stmt
---@field public elseBranch Stmt

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
			s = s .. tostring(self.thenBranch) .. ', '
			s = s .. tostring(self.elseBranch)

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
---@field public left Expr
---@field public op Token
---@field public right Expr

function node.Binary(left, op, right)
	return setmetatable({
		type = 'Binary',
		left = left,
		op = op,
		right = right,
	}, {
		__tostring = function(self)
			local s = 'Binary('

			s = s .. tostring(self.left) .. ', '
			s = s .. tostring(self.op) .. ', '
			s = s .. tostring(self.right)

			return s .. ')'
		end,
	})
end

---@class Expr.Call : Expr
---@field public callee Expr
---@field public paren Token
---@field public arguments Expr[]

function node.Call(callee, paren, arguments)
	return setmetatable({
		type = 'Call',
		callee = callee,
		paren = paren,
		arguments = arguments,
	}, {
		__tostring = function(self)
			local s = 'Call('

			s = s .. tostring(self.callee) .. ', '
			s = s .. tostring(self.paren) .. ', '
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
---@field public object Expr
---@field public name Token

function node.Get(object, name)
	return setmetatable({
		type = 'Get',
		object = object,
		name = name,
	}, {
		__tostring = function(self)
			local s = 'Get('

			s = s .. tostring(self.object) .. ', '
			s = s .. tostring(self.name)

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
---@field public left Expr
---@field public op Token
---@field public right Expr

function node.Logical(left, op, right)
	return setmetatable({
		type = 'Logical',
		left = left,
		op = op,
		right = right,
	}, {
		__tostring = function(self)
			local s = 'Logical('

			s = s .. tostring(self.left) .. ', '
			s = s .. tostring(self.op) .. ', '
			s = s .. tostring(self.right)

			return s .. ')'
		end,
	})
end

---@class Expr.Set : Expr
---@field public object Expr
---@field public name Token
---@field public value Expr

function node.Set(object, name, value)
	return setmetatable({
		type = 'Set',
		object = object,
		name = name,
		value = value,
	}, {
		__tostring = function(self)
			local s = 'Set('

			s = s .. tostring(self.object) .. ', '
			s = s .. tostring(self.name) .. ', '
			s = s .. tostring(self.value)

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