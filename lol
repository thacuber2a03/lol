#!/usr/bin/env lua

local reporter = require 'reporter'
local Lexer = require 'lexer'
local Parser = require 'parser'
local Compiler = require 'compiler'

---@type table
local args

do --- argument parser
	local parser = require 'argparse' ()
		:name "lol"
		:description "transpiles Lox to Lua."

	parser:argument "input"
		:description "input file."

	parser:argument "output"
		:description "output file."
		:default "out.lua"

	parser:option "-s" "--spaces"
		:description "amount of spaces per tab to indent with. if '-t' supplied, applies for error messages."
		:default(4)
		:convert(tonumber)

	parser:flag "-t" "--tabs"
		:description "indent using tabs instead of spaces"

	args = parser:parse()

	reporter:setSpacesPerTab(args.spaces)
end

---@type string
local source

do --- source read
	local file <close>, err = io.open(args.input, "rb")
	if not file then
		io.write(string.format("could not open file '%s': %s", args.input, err))
		os.exit(-1)
	end

	source = file:read "*a"
	reporter:setSource(source)
end

local start = os.clock()
local lexer = Lexer(source)
local parser = Parser(lexer)
local ast = parser:parse()
local compiler = Compiler(ast, not args.tabs and args.spaces or nil)
local code = compiler:compile()
local finish = os.clock()

if reporter.didError then os.exit(-1) end

io.write("successfully finished compilation in ", (finish - start) * 1000, " milliseconds")

do -- source output
	local file <close>, err = io.open(args.output, "w+b")
	if not file then
		io.write(string.format("could not open file '%s': %s", args.output, err))
		os.exit(-1)
	end

	file:write(code)
end
