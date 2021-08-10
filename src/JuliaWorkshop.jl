module JuliaWorkshop

const dir = splitdir(splitdir(pathof(JuliaWorkshop))[1])[1]

"Test JuliaWorkshop"
function test()
	include(joinpath(dir, "test", "runtests.jl"))
end

include("Notebooks.jl")

end
