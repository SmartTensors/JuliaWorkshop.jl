function draw_face(x, y, width=3, height=4)
    println("x=$x, y=$y, width=$width, height=$height")
end

draw_face(10, 20, 30)

try
    draw_face(10, 20, width=30)
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
    println("provided options are $(options...))")
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

using Dates
c = City("Auckland", "New Zealand", year(now()) - 1840)

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

multdisp("10", 20)

ambiguity(a::Int64, b) = 1
ambiguity(a, b::Int64) = 2

try
    ambiguity(10, 20)
catch ex
    ex
end

ambiguity(a::Int64, b::Int64) = 3
ambiguity(10, 20)

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

macro addtosub(x)
  if x.head == :call && x.args[1] == :+ && length(x.args) == 3
    Expr(:call, :-, x.args[2], x.args[3])
  else
    x
  end
end

@addtosub 10 + 2
