-- my first complex error reporter
-- it *is* boring string manipulation after all ^-^

local reporter = {}

function reporter:setSource(source)
	self.source = source
	self.didError = false
end

function reporter:setSpacesPerTab(n)
	assert(type(n) == "number", "what")
	self.spacesPerTab = n
end

---@private
function reporter:assertSource()
	assert(self.source, "error reporter error (yeah): no source set")
end

function reporter:error(msg, line1, col1, line2, col2, printLine)
	if printLine == nil then printLine = true end
	self.didError = true

	line2 = line2 or line1
	col2 = col2 or col1

	io.write("fatal: ", msg, " [", line1, ", ", col1, "]\n")

	if printLine then
		io.write "|\n"
		local text = self:getTextBetweenLines(line1, line2)
		io.write("|\t", text:gsub("\t", string.rep(" ", self.spacesPerTab)), "\n")
		io.write("|\t", self:getErrLocationStr(text, line1, col1, line2, col2), "\n")
	end

	return self.didError
end

---@param line1 integer
---@param line2 integer
---@return string
function reporter:getTextBetweenLines(line1, line2)
	self:assertSource()
	line2 = line2 or line1

	local lines = {}
	for m in self.source:gmatch("[^\n]*") do
		table.insert(lines, m)
	end

	return table.concat(lines, "\n", line1, line2)
end

---@private
---@param line1 integer
---@param col1 integer
---@param line2 integer
---@param col2 integer
---@return string
function reporter:getErrLocationStr(text, line1, col1, line2, col2)
	self:assertSource()

	local tabCount = 0
	for _ in text:gmatch "\t" do tabCount = tabCount + 1 end

	local res = string.rep(" ", tabCount * self.spacesPerTab)
	if line1 == line2 then
		res = res .. string.rep(" ", col1 - 1 - tabCount)
		res = res .. string.rep("^", col2 - col1 + 1)
	else
		res = res .. string.rep("^", #text - tabCount)
	end
	return res
end

return reporter
