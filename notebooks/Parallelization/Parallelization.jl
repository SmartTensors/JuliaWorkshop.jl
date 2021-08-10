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

ch = fibonacci(10)
for i in 1:10
    println(take!(ch))
end

try
    take!(ch)
catch ex
    ex
end

function fibonacci(n)
  function generator_func(ch, n)
    a, b = 1, 1
    for i in 1:n
        put!(ch, a)
        a, b = b, a + b
    end
  end
  ch = Channel()
  task = @task generator_func(ch, n) # creates a task without starting it
  bind(ch, task) # the channel will be closed when the task ends
  schedule(task) # start running the task asynchronously
  ch
end

ch = fibonacci(10)
while isopen(ch)
  value = take!(ch)
  println(value)
end

if haskey(ENV, "JULIA_NUM_THREADS")
	@info "Number of threads:", ENV["JULIA_NUM_THREADS"]
else
	@warn "No treads; restart julia as `julia -t 8`"
end

Base.Threads.nthreads()

@Base.Threads.threads for i in 1:10
    println("thread #", Base.Threads.threadid(), " is starting task #$i")
    sleep(rand()) # pretend we're actually working
    println("thread #", Base.Threads.threadid(), " is finished")
end

import BenchmarkTools

function parallel_estimate_pi(n)
  s = zeros(Threads.nthreads())
  nt = n ÷ Threads.nthreads()
  @Threads.threads for t in 1:Threads.nthreads()
      for i in (1:nt) .+ nt*(t - 1)
        @inbounds s[t] += (isodd(i) ? -1 : 1) / (2i + 1)
      end
  end
  return 4.0 * (1.0 + sum(s))
end

@BenchmarkTools.btime parallel_estimate_pi(100_000_000)

function estimate_pi(n)
    s = 1.0
    for i in 1:n
        s += (isodd(i) ? -1 : 1) / (2i + 1)
    end
    return 4s
end

@BenchmarkTools.btime estimate_pi(100_000_000)

function parallel_estimate_pi2(n)
    4.0 * mapreduce(i -> (isodd(i) ? -1 : 1) / (2i + 1), +, 0:n)
end

@BenchmarkTools.btime parallel_estimate_pi2(100_000_000)

task = Threads.@spawn begin
    println("Thread starting")
    sleep(1)
    println("Thread stopping")
    return 42
end

println("Hello!")

println("The result is: ", fetch(task))

ch = Channel()
task1 = Threads.@spawn begin
    for i in 1:5
        sleep(rand())
        put!(ch, i^2)
    end
    println("Finished sending!")
    close(ch)
end

task2 = Threads.@spawn begin
    foreach(v->println("Received $v"), ch)
    println("Finished receiving!")
end

wait(task2)

import Distributed
Distributed.addprocs(4)
Distributed.workers() # array of worker process ids

Distributed.myid()

@Distributed.everywhere println("Hi! I'm worker $(Distributed.myid())")

@Distributed.spawnat 3 println("Hi! I'm worker $(Distributed.myid())")

@Distributed.spawnat :any println("Hi! I'm worker $(Distributed.myid())")

result = @Distributed.spawnat 3 1+2+3+4
fetch(result)

using PyCall

result = @Distributed.spawnat 4 (np = pyimport("numpy"); np.log(10))

try
    fetch(result)
catch ex
    ex
end

@Distributed.everywhere using PyCall

result = @Distributed.spawnat 4 (np = pyimport("numpy"); np.log(10))

fetch(result)

import PyCall

result = @Distributed.spawnat 4 (np = PyCall.pyimport("numpy"); np.log(10))

fetch(result)

@Distributed.everywhere addtwo(n) = n + 2

result = @Distributed.spawnat 4 addtwo(40)

fetch(result)

M = @Distributed.spawnat 2 rand(5)

result = @Distributed.spawnat 3 fetch(M) .* 10.0

fetch(result)
