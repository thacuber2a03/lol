#!/usr/bin/env lua

local Lexer = require 'lexer'
local Parser = require 'parser'
local reporter = require 'reporter'

---@type table
local args

do --- argument parser
	local parser = require 'argparse' ()
		:name "lol"
		:description "Transpiles Lox to Lua."

	parser:argument "input"
		:description "Input file."

	parser:argument "output"
		:description "Output file."
		:default "out.lua"

	parser:option "-s" "--spaces"
		:description "Amount of spaces per tab to print error messages with."
		:default(4)
		:convert(tonumber)

	args = parser:parse()

	reporter:setSpacesPerTab(args.spaces)
end

---@type string
local source

do --- source read
	local file <close>, err = io.open(args.input, "rb")
	if not file then
		io.write(string.format("could not open file %s: %s", args.input, err))
		os.exit(-1)
	end

	source = file:read "*a"
	reporter:setSource(source)
end

local lexer = Lexer(source)
local parser = Parser(lexer)
print(parser:parse())
