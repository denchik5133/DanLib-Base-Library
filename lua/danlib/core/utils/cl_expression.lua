/***
 *   @addon         DanLib
 *   @version       3.0.0
 *   @release_date  10/4/2023
 *   @author        denchik
 *   @contact       Discord: denchik_gm
 *                  Steam: https://steamcommunity.com/profiles/76561198405398290/
 *                  GitHub: https://github.com/denchik5133
 *                
 *   @description   Universal library for GMod Lua, combining all the necessary features to simplify script development. 
 *                  Avoid code duplication and speed up the creation process with this powerful and convenient library.
 *
 *   @usage         !danlibmenu (chat) | danlibmenu (console)
 *   @license       MIT License
 *   @notes         For feature requests or contributions, please open an issue on GitHub.
 */


/***
 *   cl_expression.lua
 *   This file provides a library of mathematical functions and utilities for compiling and evaluating expressions within the DanLib framework.
 *
 *   The following features and functions are included:
 *   - A collection of mathematical constants and functions, such as π, sine, cosine, logarithmic functions, and more.
 *   - Random number generation utilities, including generating random numbers within a specific range.
 *   - Functions for basic mathematical operations, including absolute value, sign determination, and square wave generation.
 *   - A method for calculating the sinc function, which is defined as sin(x)/x.
 *   - A compilation system for transforming string expressions into executable Lua functions while checking for reserved keywords.
 *   - An environment setup for compiled functions, allowing access to mathematical functions and custom libraries.
 *
 *   This file is designed to facilitate the evaluation of mathematical expressions in a safe and controlled manner,
 *   enabling developers to create dynamic and flexible calculations within the game interface.
 *
 *   Usage example:
 *   - To compile and evaluate a mathematical expression:
 *     local success, compiled_func = expression.Compile('sin(PI * 0.5) + randx(-1, 1)')
 *     if success then
 *         local result = compiled_func() -- Calling the compiled function
 *         print('Result: ' .. result) -- Output the result
 *     else
 *         print('Compilation error: ' .. compiled_func)
 *     end
 *
 *   @notes: Ensure that expressions do not contain forbidden keywords to avoid compilation errors.
 *   The library provides a robust set of mathematical functions that can be easily extended.
 */



-- used like <tag=[pi * rand()]>

-- Library of mathematical functions
local lib = {}

-- Constant π
lib.PI = math.pi
lib.pi = lib.PI

-- Random number generation
lib.rand = math.random
lib.random = lib.rand

-- Generates a random number in the range from a to b
function lib.randx(a, b)
    return lib.rand(a, b)
end

-- Returns the absolute value of x
function lib.abs(x)
    return math.abs(x)
end

-- Determines the sign of the number x: -1, 1 or 0
function lib.sgn(x)
    if (x < 0) then
        return -1
    elseif (x > 0) then
        return 1
    else
        return 0
    end
end

-- Generates a square signal with specified offset and width
function lib.pwm(offset, w)
    return (offset % 1 < w) and 1 or 0
end

-- Returns 1, -1 or 0 depending on the sine value of x
function lib.square(x)
    return lib.sgn(math.sin(x))
end

-- Definition of trigonometric and logarithmic functions
lib.acos = math.acos
lib.asin = math.asin
lib.atan = math.atan
lib.atan2 = math.atan2
lib.ceil = math.ceil
lib.cos = math.cos
lib.cosh = math.cosh
lib.deg = math.deg
lib.exp = math.exp
lib.floor = math.floor
lib.frexp = math.frexp
lib.ldexp = math.ldexp
lib.log = math.log
lib.log10 = math.log10
lib.max = math.max
lib.min = math.min
lib.rad = math.rad
lib.sin = math.sin
lib.sinh = math.sinh
lib.sqrt = math.sqrt
lib.tanh = math.tanh
lib.tan = math.tan

-- Calculates sinc(x) = sin(x)/x
function lib.sinc(x)
    return (x == 0) and 1 or (math.sin(x) / x)
end

-- Black list of reserved words
local blacklist = {
	'repeat', 'until', 'function', 'end'
}

local expressions = {}


-- Function for compiling a string into a function with a given environment
local function loadstring(str, env)
	local var = CompileString(str, env or 'loadstring', false)
	if (type(var) == 'string') then return nil, var, 2 end
	return setfenv(var, getfenv(1))
end


-- Compiles a string expression, checking for forbidden words
local function compile_expression(str, extra_lib)
	local source = str

	for _, word in pairs(blacklist) do
		if (str:find('[%p%s]' .. word) or str:find(word .. '[%p%s]')) then
			return false, string.format('illegal characters used %q', word)
		end
	end

	local functions = {}

	for k, v in pairs(lib) do 
		functions[k] = v
	end

	if extra_lib then
		for k, v in pairs(extra_lib) do 
			functions[k] = v 
		end
	end

	local t0 = os.clock()

	function functions.t()
		return os.clock() - t0
	end

	function functions.time()
		return os.clock() - t0
	end

	functions.select = select
	str = 'local input = select(1, ...) return ' .. str

	-- Compiling a string into a function
	local func, err = loadstring(str)
	if func then
		setfenv(func, functions)
		expressions[func] = source
		return true, func
	else
		return false, err
	end
end

-- Object for working with expressions
expression = {}

-- Method for compiling expressions
function expression.Compile(str)
    return compile_expression(str)
end
