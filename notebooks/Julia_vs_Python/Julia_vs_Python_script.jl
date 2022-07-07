function estimate_pi(n)
    s = 1.0
    for i in 1:n
        s += (isodd(i) ? -1 : 1) / (2i + 1)
    end
    4s # or return 4s
end

p = estimate_pi(100_000_000)
println("π ≈ $p")
println("Error is $(p - π)")

import PyCall

sys = PyCall.pyimport("sys")
sys.version

PyCall.py"""
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

@time estimate_pi(100_000_000);

import BenchmarkTools

BenchmarkTools.@benchmark estimate_pi(100_000_000)

BenchmarkTools.@btime estimate_pi(100_000_000)

PyCall.py"""
from timeit import timeit

duration = timeit("estimate_pi(100_000_000)", number=1, globals=globals())
"""

PyCall.py"duration"

PyCall.py"""
from numpy.linalg import inv
import numpy as np

a = np.array([[1., 2.], [3., 4.]])
ainv = inv(a)
"""

PyCall.py"ainv"

M = [1   2   3   4
     5   6   7   8
     9  10  11  12]

M = [1 2 3 4; 5 6 7 8; 9 10 11 12]

M[2:3, 3:4]

M'

A = rand(3, 2)

A \ M

M .+ rand(3)
M .+ rand(4)'
M .+ rand(3, 4)
M + rand(3, 4)

display(M)

square(x) = x^2

function square(x)
    x^2
end

map(x -> x^2, 1:4)

function my_for(func, collection)
    for i in collection
        func(i)
    end
end

my_for(1:4) do i
    println("The square of $i is $(i^2)")
end

"a b c" |> uppercase |> split

"a b c" |> uppercase |> split |> tokens->join(tokens, ", ")

[π/2, "hello", 4] .|> [sin, length, x->x^2]

f = exp ∘ sin ∘ sqrt
f(2.0) == exp(sin(sqrt(2.0)))

multdisp(a::Int64, b::Int64) = 1
multdisp(a::Int64, b::Float64) = 2
multdisp(a::Float64, b::Int64) = 3
multdisp(a::Float64, b::Float64) = 4

multdisp(10, 20) # try changing the arguments to get each possible output

multdisp(a::Any, b::Int64) = 5

multdisp(10, 20)

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