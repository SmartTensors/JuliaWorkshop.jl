?exp

function estimate_pi(n)
	s = 1.0
	for i in 1:n
		s += (isodd(i) ? -1 : 1) / (2i + 1)
	end
	4s # or return 4s
end

@time p = estimate_pi(100_000_000)
println("π ≈ $p")
println("Error is $(p - π)")

import PyCall

sys = PyCall.pyimport("sys")
sys.version

@time PyCall.py"""
import math

def estimate_pi(n):
	s = 1.0
	for i in range(1, n + 1):
		s += (-1 if i % 2 else 1) / (2 * i + 1)
	return 4 * s

p = estimate_pi(100_000_000)
print(f"π ≈ {p}") # f-strings are available in Python 3.6+
print(f"Error is {p - math.pi}")
"""


PyCall.py"p"

PyCall.py"p" - p

np = PyCall.pyimport("numpy")
a = np.random.rand(2, 3)

exp_a = np.exp(a)

PyCall.py"""
import numpy as np

result = np.log($exp_a)
"""

PyCall.py"result"

import PyPlot

x = range(-5π, 5π; length=100)
PyPlot.plt.plot(x, sin.(x) ./ x) # we'll discuss this syntax in the next section
PyPlot.plt.title("sin(x) / x")
PyPlot.plt.grid("True")
PyPlot.plt.gcf()

println(collect(range(10, 80, step=20)))
println(collect(10:20:80)) # 10:20:80 is equivalent to the previous range
println(collect(range(10, 80, length=5))) # similar to NumPy's linspace()
step = (80-10)/(5-1) # 17.5
println(collect(10:step:80)) # equivalent to the previous range

a = sin.(x) ./ x
b = [sin(i) / i for i in x]
@assert a == b

a = @. sin(x) / x
b = sin.(x) ./ x
@assert a == b

@time estimate_pi(100_000_000);

import BenchmarkTools

BenchmarkTools.@benchmark estimate_pi(100_000_000)

BenchmarkTools.@btime estimate_pi(100_000_000)

PyCall.py"""
from timeit import timeit

duration = timeit("estimate_pi(100_000_000)", number=1, globals=globals())
"""

PyCall.py"duration"

i = 42 # 64-bit integer
f = 3.14 # 64-bit float
c = 3.4 + 4.5im # 128-bit complex number

bi = BigInt(2)^1000 # arbitrarily long integer
bf = BigFloat(1) / 7 # arbitrary precision

r = 15//6 * 9//20 # rational number

5 / 2

5 ÷ 2

div(5, 2)

57 % 10

(-57) % 10

s = "ångström" # Julia strings are UTF-8 encoded by default
println(s)

s = "Julia strings
	 can span
	 several lines\n\n
	 and they support the \"usual\" escapes like
	 \x41, \u5bb6, and \U0001f60a!"
println(s)

s = repeat("tick, ", 10) * "BOOM!"
println(s)

s = join([i for i in 1:4], ", ")
println(s)

s = join([i for i in 1:4], ", ", " and ")

split("   one    three     four   ")

split("one,,three,four!", ",")

occursin("sip", "Mississippi")

replace("I like coffee", "coffee" => "tea")

s = """
	   1. the first line feed is ignored if it immediately follows \"""
	   2. triple quotes let you use "quotes" easily
	   3. indentation is ignored
		   - up to left-most character
		   - ignoring the first line (the one with \""")
	   4. the final line feed it n̲o̲t̲ ignored
	   """
println("<start>")
println(s)
println("<end>")

total = 1 + 2 + 3
s = "1 + 2 + 3 = $total = $(1 + 2 + 3)"
println(s)

s = "The car costs \$10,000"
println(s)

s = raw"In a raw string, you only need to escape quotes \", but not
		$ or \. There is one exception, however: the backslash \
		must be escaped if it's just before quotes like \\\"."
println(s)

s = raw"""
   Triple quoted raw strings are possible too: $, \, \t, "
	 - They handle indentation and the first line feed like regular
	   triple quoted strings.
	 - You only need to escape triple quotes like \""", and the
	   backslash before quotes like \\".
   """
println(s)

a = 'å' # Unicode code point (single quotes)

s = "café"
println(s, " has ", length(s), " code points")

s = "cafe\u0301"
println(s, " has ", length(s), " code points")

for c in "cafe\u0301"
	display(c)
end

sizeof('é')

sizeof("a")

sizeof("é")

sizeof("家")

sizeof("🏳️‍🌈") # this is a grapheme with 4 code points of 4 + 3 + 3 + 4 bytes

[sizeof(string(c)) for c in "🏳️‍🌈"]

import Unicode

for g in Unicode.graphemes("e\u0301🏳️‍🌈")
  println(g)
end

s = "être"
println(s[1])
println(s[3])
println(s[4])
println(s[5])

try
	s[2]
catch ex
	ex
end

s[1:3]

for c in s
	println(c)
end

for i in eachindex(s)
	println(i, ": ", s[i])
end

findfirst(isequal('t'), "être")

findlast(isequal('p'), "Mississippi")

findnext(isequal('i'), "Mississippi", 2)

findnext(isequal('i'), "Mississippi", 2 + 1)

findprev(isequal('i'), "Mississippi", 5 - 1)

regex = r"c[ao]ff?(?:é|ee)"

occursin(regex, "A bit more coffee?")

m = match(regex, "A bit more coffee?")
m.match

m.offset

m = match(regex, "A bit more tea?")
isnothing(m) && println("I suggest coffee instead")

regex = r"(.*)#(.+)"
line = "f(1) # nice comment"
m = match(regex, line)
code, comment = m.captures
println("code: ", repr(code))
println("comment: ", repr(comment))

m[2]

m.offsets

m = match(r"(?<code>.+)#(?<comment>.+)", line)
m[:comment]

replace("Want more bread?", r"(?<verb>more|some)" => s"a little")

replace("Want more bread?", r"(?<verb>more|less)" => s"\g<verb> and \g<verb>")

a = 1
if a == 1
	println("One")
elseif a == 2
	println("Two")
else
	println("Other")
end

@assert false ⊻ false == false
@assert false ⊻ true == true
@assert true ⊻ false == true
@assert true ⊻ true == false

a = 2
a == 1 && println("One")
a == 2 && println("Two")

a = 1
a == 1 || println("Not one")
a == 2 || println("Not two")

a = 1
result = if a == 1
			 "one"
		 else
			 "two"
		 end
result

a = 1
result = if a == 2
			"two"
		  end

isnothing(result)

typeof(nothing)

for a in 1:2, b in 1:3, c in 1:2
	println((a, b, c))
end

for a in 1:2, b in 1:3, c in 1:2
	println((a, b, c))
	(a, b, c) == (2, 1, 1) && break
end

found = false
for person in ["Joe", "Jane", "Wally", "Jack", "Julia"] # try removing "Wally"
	println("Looking at $person")
	person == "Wally" && (found = true; break)
end
found || println("I did not find Wally.")

t = (1, "Two", 3, 4, 5)

t[1]

t[1:2]

t[end]

t[end - 1:end]

try
  t[2] = 2
catch ex
  ex
end

empty_tuple = ()
one_element_tuple = (42,)

a, b, c, d, e = (1, "Two", 3, 4, 5)
println("a=$a, b=$b, c=$c, d=$d, e=$e")

(a, (b, c), (d, e)) = (1, ("Two", 3), (4, 5))
println("a=$a, b=$b, c=$c, d=$d, e=$e")

a, b, c = (1, "Two", 3, 4, 5)
println("a=$a, b=$b, c=$c")

t = (1, "Two", 3, 4, 5)
a, b = t[1:2]
c = t[3:end]
println("a=$a, b=$b, c=$c")

(a, b), c = t[1:2], t[3:end]
println("a=$a, b=$b, c=$c")

nt = (name="Julia", category="Language", stars=5)

nt.name

dump(nt)

struct Person
	name
	age
end

p = Person("Mary", 30)

p.age

function Person(name)
	Person(name, -1)
end

function Person()
	Person("no name")
end

p = Person()

struct Person2
	name
	age
	function Person2(name)
		new(name, -1)
	end
end

function Person2()
	Person2("no name")
end

p = Person2()

try
	Person2("Bob", 40)
catch ex
	ex
end

try
	p.name = "Someone"
catch ex
	ex
end

mutable struct Person3
	name
	age
end

p = Person3("Lucy", 79)
p.age += 1
p

a = [1, 4, 9, 16]

a[1] = 10
a[2:3] = [20, 30]
a

try
  a[3] = "Three"
catch ex
  ex
end

a = Any[1, 4, 9, 16]
a[3] = "Three"
a

Float64[1, 4, 9, 16]

a = []

eltype([1, 4, 9, 16])

[1, 2, 3.0, 4.0]

[1, 2, "Three", 4]

a = [1]
push!(a, 4)
push!(a, 9, 16)

pop!(a)

M = [1   2   3   4
	 5   6   7   8
	 9  10  11  12]

M = [1 2 3 4; 5 6 7 8; 9 10 11 12]

M[2:3, 3:4]

M'

M1 = [1 2
	  3 4]
M2 = [5 6
	  7 8]
vcat(M1, M2)

[M1; M2]

hcat(M1, M2)

[M1 M2]

M3 = [9 10 11 12]
[M1 M2; M3]

hvcat((2, 1), M1, M2, M3)

hvcat(1, 42)

hvcat((1, 1, 1), 10, 11, 12) # a column vector with values 10, 11, 12
hvcat(1, 10, 11, 12) # equivalent to the previous line

[10 11 12]'

display([1, 2, 3, 4])

println("Vector: ", [1, 2, 3, 4])
println("Column vector: ", hvcat(1, 1, 2, 3, 4))
println("Row vector: ", [1 2 3 4])
println("Matrix: ", [1 2 3; 4 5 6])

a = [x^2 for x in 1:4]

a = [x^2 for x in 1:5 if x ∉ (2, 4)]

a = [(i,j) for i in 1:3 for j in 1:i]

a = [row * col for row in 1:3, col in 1:5]

d = Dict("tree"=>"arbre", "love"=>"amour", "coffee"=>"café")
println(d["tree"])

println(get(d, "unknown", "pardon?"))

keys(d)

values(d)

haskey(d, "love")

"love" in keys(d) # this is slower than haskey()

d = Dict(i=>i^2 for i in 1:5)

for (k, v) in d
	println("$k maps to $v")
end

d1 = Dict("tree"=>"arbre", "love"=>"amour", "coffee"=>"café")
d2 = Dict("car"=>"voiture", "love"=>"aimer")

d = merge(d1, d2)

merge!(d1, d2)

p = "tree" => "arbre"
println(typeof(p))
k, v = p
println("$k maps to $v")

a = [1, 2, 3]
d = Dict(a => "My array")
println("The dictionary is: $d")
println("Indexing works fine as long as the array is unchanged: ", d[a])
a[1] = 10
println("This is the dictionary now: $d")
try
	println("Key changed, indexing is now broken: ", d[a])
catch ex
	ex
end

for pair in d
	println(pair)
end

odd = Set([1, 3, 5, 7, 9, 11])
prime = Set([2, 3, 5, 7, 11])

5 ∈ odd

5 in odd

in(5, odd)

odd ∪ prime

union(odd, prime)

odd ∩ prime

intersect(odd, prime)

setdiff(odd, prime) # values in odd but not in prime

symdiff(odd, prime) # values that are not in the intersection

Set([i^2 for i in 1:4])

@enum Fruit apple=1 banana=2 orange=3

banana

Fruit(2)

instances(Fruit)

banana === Fruit(2)

objectid(banana)

objectid(Fruit(2))

a = [1, 2, 4]
b = [1, 2, 4]
@assert a == b  # a and b are equal
@assert a !== b # but they are not the same object

function estimate_pi2(n)
	4 * sum((isodd(i) ? -1 : 1)/(2i+1) for i in 0:n)
end

@assert estimate_pi(100) == estimate_pi2(100)

for (i, s) in zip(10:13, ["Ten", "Eleven", "Twelve"])
	println(i, ": ", s)
end

for (i, s) in enumerate(["One", "Two", "Three"])
	println(i, ": ", s)
end

collect(1:5)

[1:5;]

function fibonacci(n)
	Channel() do ch
		a, b = 1, 1
		for i in 1:n
			put!(ch, a)
			a, b = b, a + b
		end
	end
end

for f in fibonacci(10)
	println(f)
end

function draw_face(x, y, width=3, height=4)
	println("x=$x, y=$y, width=$width, height=$height")
end

draw_face(10, 20, 30)

try
	draw_face(10, 20; width=30)
catch ex
	ex
end

function copy_files(target_dir, paths...)
	println("target_dir=$target_dir, paths=$paths")
end

copy_files("/tmp", "a.txt", "b.txt")

function copy_files2(paths...; confirm=false, target_dir)
	println("paths=$paths, confirm=$confirm, $target_dir")
end

copy_files2("a.txt", "b.txt"; target_dir="/tmp")

function copy_files3(paths...; confirm=false, target_dir, options...)
	println("paths=$paths, confirm=$confirm, $target_dir")
	verbose = options[:verbose]
	println("verbose=$verbose")
end

copy_files3("a.txt", "b.txt"; target_dir="/tmp", verbose=true, timeout=60)

square(x) = x^2

function square(x)
	x^2
end

estimate_pi3(n) = 4 * sum((isodd(i) ? -1 : 1)/(2i+1) for i in 0:n)

map(x -> x^2, 1:4)

map(x -> (println("Number $x"); x^2), 1:4)

map(x -> (
  println("Number $x");
  x^2), 1:4)

map(x -> begin
		println("Number $x")
		x^2
	end, 1:4)

map(function (x)
		println("Number $x")
		x^2
	end, 1:4)

map(1:4) do x
  println("Number $x")
  x^2
end

function my_for(func, collection)
	for i in collection
		func(i)
	end
end

my_for(1:4) do i
	println("The square of $i is $(i^2)")
end

function spawn_server(startup_func, server_type)
	println("Starting $server_type server")
	server_id = 1234
	println("Configuring server $server_id...")
	startup_func(server_id)
end

# This is the DSL part
spawn_server("web") do server_id
	println("Creating HTML pages on server $server_id...")
end

handlers = []

on_click(handler) = push!(handlers, handler)

click(event) = foreach(handler->handler(event), handlers)

on_click() do event
	println("Mouse clicked at $event")
end

on_click() do event
	println("Beep.")
end

click((x=50, y=20))
click((x=120, y=10))

function with_database(func, name)
	println("Opening connection to database $name")
	db = "a db object for database $name"
	try
		func(db)
	finally
		println("Closing connection to database $name")
	end
end

with_database("jobs") do db
	println("I'm working with $db")
	#error("Oops") # try uncommenting this line
end



"a b c" |> uppercase |> split

"a b c" |> uppercase |> split |> tokens->join(tokens, ", ")

[π/2, "hello", 4] .|> [sin, length, x->x^2]

f = exp ∘ sin ∘ sqrt
f(2.0) == exp(sin(sqrt(2.0)))

struct Person
	name
	age
end

function greetings(greeter)
	println("Hi, my name is $(greeter.name), I am $(greeter.age) years old.")
end

p = Person("Alice", 70)
greetings(p)

struct City
	name
	country
	age
end

import Dates
c = City("Auckland", "New Zealand", Dates.year(Dates.now()) - 1840)

greetings(c)

struct Developer
	name
	age
	language
end

function greetings(dev::Developer)
	println("Hi, my name is $(dev.name), I am $(dev.age) years old.")
	println("My favorite language is $(dev.language).")
end

d = Developer("Amy", 40, "Julia")
greetings(d)

methods(greetings)

methodswith(Developer)

multdisp(a::Int64, b::Int64) = 1
multdisp(a::Int64, b::Float64) = 2
multdisp(a::Float64, b::Int64) = 3
multdisp(a::Float64, b::Float64) = 4

multdisp(10, 20) # try changing the arguments to get each possible output

multdisp(a::Any, b::Int64) = 5

multdisp(10, 20)

ambig(a::Int64, b) = 1
ambig(a, b::Int64) = 2

try
	ambig(10, 20)
catch ex
	ex
end

ambig(a::Int64, b::Int64) = 3
ambig(10, 20)

function how_can_i_help(greeter)
	greetings(greeter)
	println("How can I help?")
end

how_can_i_help(p) # called on a Person
how_can_i_help(d) # called on a Developer

super(dev::Developer) = Person(dev.name, dev.age)

function greetings(dev::Developer)
	greetings(super(dev))
	println("My favorite language is $(dev.language).")
end

greetings(d)

function greetings(dev::Developer)
	invoke(greetings, Tuple{Any}, dev)
	println("My favorite language is $(dev.language).")
end

greetings(d)

struct Rectangle
	width
	height
end

width(rect::Rectangle) = rect.width
height(rect::Rectangle) = rect.height

area(rect) = width(rect) * height(rect)

struct Square
	length
end

width(sq::Square) = sq.length
height(sq::Square) = sq.length

area(Square(5))

abstract type AbstractShape end
abstract type AbstractRectangle <: AbstractShape end  # <: means "subtype of"
abstract type AbstractSquare <: AbstractRectangle end

area(rect::AbstractRectangle) = width(rect) * height(rect)

struct Rectangle_v2 <: AbstractRectangle
  width
  height
end

width(rect::Rectangle_v2) = rect.width
height(rect::Rectangle_v2) = rect.height

struct Square_v2 <: AbstractSquare
  length
end

width(sq::Square_v2) = sq.length
height(sq::Square_v2) = sq.length

Base.show_supertypes(Float64)

Base.show_supertypes(Int64)

function show_hierarchy(root, indent=0)
	println(repeat(" ", indent * 4), root)
	for subtype in subtypes(root)
		show_hierarchy(subtype, indent + 1)
	end
end

show_hierarchy(Number)

struct FibonacciIterator end

import Base.iterate

iterate(f::FibonacciIterator) = (1, (1, 1))

function iterate(f::FibonacciIterator, state)
	new_state = (state[2], state[1] + state[2])
	(new_state[1], new_state)
end

for f in FibonacciIterator()
	println(f)
	f > 10 && break
end

struct MySquares end

import Base.getindex, Base.firstindex

getindex(::MySquares, i) = i^2
firstindex(::MySquares) = 0

S = MySquares()
S[10]

S[begin]

getindex(S::MySquares, r::UnitRange) = [S[i] for i in r]

S[1:4]

struct MyRational <: Real
	num # numerator
	den # denominator
end

MyRational(2, 3)

function ⨸(num, den)
	MyRational(num, den)
end

2 ⨸ 3

?⨸

import Base.+

function +(r1::MyRational, r2::MyRational)
	(r1.num * r2.den + r1.den * r2.num) ⨸ (r1.den * r2.den)
end

2 ⨸ 3 + 3 ⨸ 5

import Base.show

function show(io::IO, r::MyRational)
	print(io, "$(r.num) ⨸ $(r.den)")
end

2 ⨸ 3 + 3 ⨸ 5

function show(io::IO, ::MIME"text/html", r::MyRational)
	print(io, "<sup><b>$(r.num)</b></sup>&frasl;<sub><b>$(r.den)</b></sub>")
end

2 ⨸ 3 + 3 ⨸ 5

import Base.*

function *(r::MyRational, i::Integer)
	(r.num * i) ⨸ r.den
end

2 ⨸ 3 * 5

function *(i::Integer, r::MyRational)
	r * i # this will call the previous method
end

5 * (2 ⨸ 3) # we need the parentheses since * and ⨸ have the same priority

import Base.convert

MyRational(x::Integer) = MyRational(x, 1)

convert(::Type{MyRational}, x::Integer) = MyRational(x)

convert(MyRational, 42)

a = [2 ⨸ 3] # the element type is MyRational
a[1] = 5    # convert(MyRational, 5) is called automatically
push!(a, 6) # convert(MyRational, 6) is called automatically
println(a)

function for_my_rationals_only(x::MyRational)
	println("It works:", x)
end

try
	for_my_rationals_only(42)
catch ex
	ex
end

promote(1, 2, 3, 4.0)

1 + 2 + 3 + 4.0

a = [1, 2, 3, 4.0]

promote_rule(Float64, Int64)

import Base.promote_rule

promote_rule(::Type{MyRational}, ::Type{T}) where {T <: Integer} = MyRational

promote(5, 2 ⨸ 3)

5 + 2 ⨸ 3

convert(::Type{T}, x::MyRational) where {T <: AbstractFloat} = T(x.num / x.den)

convert(Float64, 3 ⨸ 2)

promote_rule(::Type{MyRational}, ::Type{T}) where {T <: AbstractFloat} = T

promote(1 ⨸ 2, 4.0)

2.25 ^ (1 ⨸ 2)

struct MyRational2{T <: Integer}
	num::T
	den::T
end

MyRational2{BigInt}(2, 3)

MyRational2(2, 3)

function MyRational2(num::Integer, den::Integer)
	MyRational2(promote(num, den)...)
end

MyRational2(2, BigInt(3))

function for_any_my_rational2(x::MyRational2)
	println(x)
end

for_any_my_rational2(MyRational2{BigInt}(1, 2))
for_any_my_rational2(MyRational2{Int64}(1, 2))

function for_any_my_rational2(x::MyRational2{T}) where {T <: Integer}
	println(x)
end

@assert MyRational2{BigInt}(2, 3) isa MyRational2{BigInt}
@assert MyRational2{BigInt}(2, 3) isa MyRational2
@assert MyRational2 === (MyRational2{T} where {T <: Integer})
@assert MyRational2{BigInt} <: MyRational2
@assert MyRational2 isa UnionAll

dump(MyRational2)

open("test.txt", "w") do f
	write(f, "This is a test.\n")
	write(f, "I repeat, this is a test.\n")
end

open("test.txt") do f
	for line in eachline(f)
		println("[$line]")
	end
end

open("test.txt") do f
	s = read(f, String)
end

s = read("test.txt", String)

a = [1]
try
	push!(a, 2)
	#throw("Oops") # try uncommenting this line
	push!(a, 3)
catch ex
	println(ex)
	push!(a, 4)
finally
	push!(a, 5)
end
println(a)

choice = 1 # try changing this value (from 1 to 4)
try
	choice == 1 && open("/foo/bar/i_dont_exist.txt")
	choice == 2 && sqrt(-1)
	choice == 3 && push!(a, "Oops")
	println("Everything worked like a charm")
catch ex
	if ex isa SystemError
		println("Oops. System error #$(ex.errnum) ($(ex.prefix))")
	elseif ex isa DomainError
		println("Oh no, I could not compute sqrt(-1)")
	else
		println("I got an unexpected error: $ex")
	end
end

catch_exception = true
try
	println("Try something")
	#error("ERROR: Catch me!") # try uncommenting this line
	catch_exception = false
	#error("ERROR: Don't catch me!") # try uncommenting this line
	println("No error occurred")
catch ex
	if catch_exception
		println("I caught this exception: $ex")
	else
		throw(ex)
	end
finally
	println("The end")
end
println("After the end")

"Compute the square of number x"
square(x::Number) = x^2

@doc square

?square

"""
	cube(x::Number)

Compute the cube of `x`.

# Examples
```julia-repl
julia> cube(5)
125
julia> cube(im)
0 - 1im
```
"""
cube(x) = x^3

?cube

"""
	foo(x)

Compute the foo of the bar
"""
function foo end  # declares the foo function

# foo(x::Number) behaves normally, no need for a docstring
foo(x::Number) = "baz"

"""
	foo(x::String)

For strings, compute the qux of the bar instead.
"""
foo(x::String) = "qux"

?foo

macro addtosub(x)
  if x.head == :call && x.args[1] == :+ && length(x.args) == 3
	Expr(:call, :-, x.args[2], x.args[3])
  else
	x
  end
end

@addtosub 10 + 2

module ModA
	pi = 3.14
	square(x) = x^2

	module ModB
		e = 2.718
		cube(x) = x^3
	end

	module ModC
		root2 = √2
		relu(x) = max(0, x)
	end
end

Main.ModA.ModC.root2

ModA.ModC.root2

import Main.ModA.ModC.root2

root2

import .ModA.ModC.root2

root2

import .ModA.ModC

ModC.root2

import .ModA.ModC: root2, relu

import .ModA.ModC.root2, .ModA.ModC.relu

module ModD
	d = 1
	module ModE
		try
			println(d)
		catch ex
			println(ex)
		end
	end
	module ModF
		f = 2
		module ModG
			import ..f
			import ...d
			println(f)
			println(d)
		end
	end
end

module ModH
	h1 = 1
	h2 = 2
	export h1
end

import .ModH

println(ModH.h1)

try
	println(ModH.h2)
catch ex
	ex
end

ModH

ModH.h2

import .ModH.h2

ModH.h2

module ModG
	g1 = 1
	g2 = 2
	export g2
end

import .ModG: g1, g2

println(g1)
println(g2)

module ModH
	double(x) = x * 2
	triple(x) = x * 3
end

import .ModH: double
double(x::AbstractString) = repeat(x, 2)

ModH.triple(x::AbstractString) = repeat(x, 3)

println(double(2))
println(double("Two"))

println(ModH.triple(3))
println(ModH.triple("Three"))

module ModI
	quadruple(x) = x * 4
	export quadruple
end

import .ModI
ModI.quadruple(x::AbstractString) = repeat(x, 4) # OK
println(ModI.quadruple(4))
println(ModI.quadruple("Four"))

#quadruple(x::AbstractString) = repeat(x, 4) # uncomment to see the error

import .ModI: quadruple
x = quadruple

code_awesome = """
module Awesome
include("great.jl")
include("amazing/Fantastic.jl")
end
"""

code_great = """
great() = "This is great!"
"""

code_fantastic = """
module Fantastic
fantastic = true
end
"""

open(f->write(f, code_awesome), "Awesome.jl", "w")
open(f->write(f, code_great), "great.jl", "w")
mkdir("amazing")
open(f->write(f, code_fantastic), "amazing/Fantastic.jl", "w")

pushfirst!(LOAD_PATH, ".")

import Awesome
println(Awesome.great())
println("Is fantastic? ", Awesome.Fantastic.fantastic)

popfirst!(LOAD_PATH)

for q in 1:3
	println(q)
end

try
	println(q) # q is not available here
catch ex
	ex
end

z = 5
for i in 1:3
	w = 10
	println(i * w * z) # i and w are local, z is from the parent scope
end

for i in 1:3
	s = 0
	for j in 1:5
		s = j # variable s is from the parent scope
	end
	println(s)
end

for i in 1:3
	s = 0
	for j in 1:5
		local s = j # variable s is local now
	end
	println(s)
end

for i in 1:3
	global p
	p = i
end
p

s = 0
for i in 1:3
	s = i # implicitly global s: only in REPL Julia 1.5+ or IJulia
end
s

s, t = 1, 2 # globals

function foo()
   s = 10 * t # s is local, t is global
end

println(foo())
println(s)

t = 1

foo() = t # foo() captures t from the global scope

function bar()
	t = 5 # this is a new local variable
	println(foo()) # foo() still uses t from the global scope
end

bar()

function quz()
	global t
	t = 5 # we change the global t
	println(foo()) # and this affects foo()
end

quz()

function create_multiplier(n)
	function mul(x)
		x * n # variable n is captured from the parent scope
	end
end

mul2 = create_multiplier(2)
mul2(5)

function create_counter()
	c = 0
	inc() = c += 1 # this inner function modifies the c from the outer function
end

cnt = create_counter()
println(cnt())
println(cnt())

funcs = []
i = 1
while i ≤ 5
	push!(funcs, ()->i^2)
	global i += 1
end
for fn in funcs
	println(fn())
end

funcs = []
for i in 1:5
	push!(funcs, ()->i^2)
end
for fn in funcs
	println(fn())
end

funcs = []
i = 1
while i ≤ 5  # since we are in a while loop...
	global i
	local j = i # ...and j is created here, it's a new `j` at each iteration
	push!(funcs, ()->j^2)
	i += 1
end
for fn in funcs
	println(fn())
end

funcs = []
i = 0
while i < 5
	let i=i
		push!(funcs, ()->i^2)
	end
	global i += 1
end
for fn in funcs
	println(fn())
end

a = 1
let a=a+1, b=a
	println("a=$a, b=$b")
end

a = 1
foobar(a=a+1, b=a) = println("a=$a, b=$b")
foobar()
foobar(5)

a = 1
if true
	a = 2 # same `a` as above
end
a

a = 1
begin
	a = 2  # same `a` as above
end
a
