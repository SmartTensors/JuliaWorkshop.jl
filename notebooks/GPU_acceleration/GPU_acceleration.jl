;nvidia-smi

import BenchmarkTools

M = rand(2^11, 2^11)

function benchmark_matmul_cpu(M)
    M * M
    return nothing
end

benchmark_matmul_cpu(M) # warm up

@BenchmarkTools.btime benchmark_matmul_cpu($M)
@BenchmarkTools.benchmark benchmark_matmul_cpu($M)

import CUDA

M_on_gpu = CUDA.cu(M) # Copy the data to the GPU and create a CuArray

M_on_gpu = CUDA.CURAND.rand(size(M)) # or create a new random matrix directly on the GPU

function benchmark_matmul_gpu(M)
    CUDA.@sync M * M
    return nothing
end

benchmark_matmul_gpu(M_on_gpu) # warm up

@BenchmarkTools.btime benchmark_matmul_gpu($M_on_gpu)
@BenchmarkTools.benchmark benchmark_matmul_gpu($M_on_gpu)

CUDA.memory_status()

GC.gc()
CUDA.reclaim()

function benchmark_without_fusion(M)
    P = M .* M
    CUDA.@sync P .+ M
    return
end

benchmark_without_fusion(M_on_gpu) # warm up

@BenchmarkTools.btime benchmark_without_fusion($M_on_gpu)

function benchmark_with_fusion(M)
    CUDA.@sync M .* M .+ M
    return
end

benchmark_with_fusion(M_on_gpu) # warm up

@BenchmarkTools.btime benchmark_with_fusion($M_on_gpu)

function worker_gpu_add!(u, v)
    index = (CUDA.blockIdx().x - 1) * CUDA.blockDim().x + CUDA.threadIdx().x
    index ≤ length(u) && (@inbounds u[index] += v[index])
    return
end

function gpu_add!(u, v)
    numblocks = ceil(Int, length(u) / 256)
    CUDA.@cuda threads=256 blocks=numblocks worker_gpu_add!(u, v)
    return u
end

u = rand(2^20)
v = rand(2^20)

u_on_gpu = CUDA.cu(u)
v_on_gpu = CUDA.cu(v)

u .+= v

gpu_add!(u_on_gpu, v_on_gpu)

@assert Array(u_on_gpu) ≈ u

function benchmark_custom_assign_add!(u, v)
    CUDA.@sync gpu_add!(u, v)
    return nothing
end

benchmark_custom_assign_add!(u_on_gpu, v_on_gpu) # warm up

@BenchmarkTools.btime benchmark_custom_assign_add!($u_on_gpu, $v_on_gpu)

function benchmark_assign_add!(u, v)
    CUDA.@sync u .+= v
    return nothing
end

benchmark_assign_add!(u_on_gpu, v_on_gpu) # warm up

@BenchmarkTools.btime benchmark_assign_add!($u_on_gpu, $v_on_gpu)

function worker_gpu_add!(u, v)
    index = (CUDA.blockIdx().x - 1) * CUDA.blockDim().x + CUDA.threadIdx().x
    stride = CUDA.blockDim().x * CUDA.gridDim().x
    for i = index:stride:length(u)
        @inbounds u[i] += v[i]
    end
    return nothing
end
