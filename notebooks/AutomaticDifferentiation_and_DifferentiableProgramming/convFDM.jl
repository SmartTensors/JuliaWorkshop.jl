### A Pluto.jl notebook ###
# v0.14.7

using Markdown
using InteractiveUtils

# ╔═╡ 63d72dc4-6a68-48a8-8535-681a83d041f2
using Plots

# ╔═╡ 83131cf8-472e-4c04-b938-4431c57de855
using NNlib # directly invoking NN primitives used by Flux - maybe use this always instead, if Flux has higher overhead (compilation, performance)

# ╔═╡ e9e432c7-042b-448d-a35b-df4760fcc54d
using DSP #signal processing pkg for standard conv operations

# ╔═╡ ca2b45bb-6dab-4f0a-bcc2-07a70830ec29
using BenchmarkTools

# ╔═╡ d0494c03-750c-4e5f-a056-f54c450cc274
using Flux

# ╔═╡ 51969182-173f-4e33-a9b3-8d99b2067103
begin
	#define grid
	M = 10;
	N = 10;
	Δx = 0.5;
	Δy = 0.5;
	xl = Int64(M/Δx + 1);
	yl = Int64(N/Δy + 1);
	xx = collect(0:Δx:M);
	yy = collect(0:Δy:N);
	xgrid = repeat(xx,1,xl);
	ygrid = repeat(yy,1,yl);
end

# ╔═╡ ba9bb0f1-17c9-4896-a1c7-2887c198c1c2
begin
	#ϕ = randn(xl,yl)
	ϕ = abs.(sin.(randn(xl,yl) * xgrid) + cos.(randn(xl,yl) * ygrid)) +0.25*randn(xl,yl);
	#modified ϕ with extra channel and batch dimensions for conv layer
	ϕconv = Float32.(reshape(ϕ,(xl,yl,1,1)));
	#conv ϕ with extra padding for first order derivative at the bdry.
	p1 = contourf(ϕ, title="data")
end

# ╔═╡ f43e53cb-7c05-4dc7-b970-a4a146d48790
ϕ

# ╔═╡ a2f3e642-925d-4054-bd46-376253298dc3
begin
	ϕconvPadded = Array{Float64}(undef,xl+2,yl+2)
	ϕconvPadded[2:end-1,2:end-1] = copy(ϕ)
	#rows
	ϕconvPadded[1,2:end-1] = ϕconvPadded[2,2:end-1]
	ϕconvPadded[end,2:end-1] = ϕconvPadded[end-1,2:end-1]
	#columns
	ϕconvPadded[2:end-1,1] = ϕconvPadded[2:end-1,2]
	ϕconvPadded[2:end,end] = ϕconvPadded[2:end,end-1]
	ϕconvPadded = Float32.(reshape(ϕconvPadded,(xl+2,yl+2,1,1)));
end

# ╔═╡ 36a982fd-0825-49f4-b042-fecd8e08f7f9
md""" ## Computing ``\partial`` derivatives with Convolutional Layers """

# ╔═╡ 3bad8683-3365-48e6-84b3-30e5e8e1e94b
md"## ∂ϕ/∂x2 Derivative with FDM method"

# ╔═╡ 26db2d50-0e73-4ed3-8239-45a6ea850ca1
begin
	#2nd derivative with FDM Central Difference
	∂x2 = Array{Float64}(undef,xl,yl);

	for i=2:xl-1
		∂x2[i,:] = (ϕ[i+1,:] - 2*ϕ[i,:] + ϕ[i-1,:]) ./ (Δx^2);
	end
	∂x2[1,:] = (ϕ[2,:] - ϕ[1,:]) ./ (Δx^2);
	∂x2[end,:] = (ϕ[end,:] - ϕ[end-1,:]) ./ (Δx^2);
end

# ╔═╡ be18f7f6-d02e-411d-bf45-62b3d3d97aad
∂x2

# ╔═╡ 41bcf658-0c7e-49d0-9392-17b2f9101093
(ϕ[3,1] - 2*ϕ[2,1] + ϕ[1,1])/(Δx^2)

# ╔═╡ bc0eb5c6-e8ff-4634-9f4b-ce70539a4123
size(∂x2)

# ╔═╡ 807b5377-818e-4cef-bca4-7897f7ac111a
md"## ∂ϕ/∂x2 Derivative with Conv layers"

# ╔═╡ cbee6d42-5e75-4d81-9109-b28f1e558a00
md"Method 1: Init with random weights"

# ╔═╡ a42aaac0-7c7c-4d00-aef4-292dbb1402cd
md"Method 2: Init Conv with explicit weights for FDM kernel ∂ϕ/∂x2"

# ╔═╡ f0180912-007c-4a2d-815b-f8d58746d0b8
begin
	#centralDiff2ndFDM = [0.0 0.0 0.0;0.0 0.0 0.0;0.0 0.0 0.0] ./ (Δx^2);
	averageFactor = (1.0/1.0) #very important when not using FDM. Compute this automatically.
	centralDiff2ndFDM∂x = averageFactor * [0 1.0 0;0 -2.0 0;0 1.0 0] ./ (Δx^2);
	centralDiff2ndFDM∂x = Float32.(reshape(centralDiff2ndFDM∂x,(3,3,1,1)))
end

# ╔═╡ 791b0b8b-5a49-47d9-af64-82ef9829f966
#weight = rand(3,3,1,1);
#weight = copy(ps1[1]); #using method 1 weights for testing
weight∂x = centralDiff2ndFDM∂x #using 2nd order Central Difference Kernel

# ╔═╡ 32beebcf-bcdd-4810-bfeb-dd1f8e392fcb
bias∂x = zeros(1)
#bias = [0.0]

# ╔═╡ a01a1347-15d3-4d97-a2e5-ebe95a93d1b3
convLayer∂x2 = Flux.Conv(weight∂x,bias∂x,identity; pad=1)

# ╔═╡ cb77ccdc-ef2e-4b7f-80a9-d1f2a1ff5755
begin
	ps2 = Flux.params(convLayer∂x2);
	size(ps2[1]);
end

# ╔═╡ bcd57e86-4bc8-4092-a7db-5749cea8928c
conv∂x2 = convLayer∂x2(ϕconv)

# ╔═╡ 67cc0e9d-c7db-4438-ad4d-044f28063d4f
∂x2

# ╔═╡ 7d90fdfe-59d0-47b6-b32a-c596bddfa1b2
md"Method 3: Pad input + Init Conv with explicit weights for FDM kernel ∂ϕ/∂x2"

# ╔═╡ ba598c7b-4e79-4dba-bdf9-60d2b16c152f
convLayer∂x2pad = Flux.Conv(weight∂x,bias∂x,identity; pad=0)

# ╔═╡ 73e6d5c2-f136-4fd9-97ff-ab6cb316d626
conv∂x2padded = convLayer∂x2pad(ϕconvPadded)

# ╔═╡ fa90ccb1-e4c0-4e52-9114-262e00434a79
begin
	lastRowCorrectionMatrix∂x = ones(xl,yl); # to fix negative value error in last row.
	lastRowCorrectionMatrix∂x[end,:] .= -1.0;
	lastRowCorrectionMatrix∂x = reshape(lastRowCorrectionMatrix∂x,(xl,yl,1,1));
end

# ╔═╡ bcabd75a-21ae-4884-bdbe-c58c39ef48b4
conv∂x2paddedCorrected = conv∂x2padded .* lastRowCorrectionMatrix∂x

# ╔═╡ 5262ce42-c2a8-445f-825f-2e74b7947860
p2 = contourf(∂x2, title="FDM ∂x2")
#p2 = contourf(∂x2[10:15,10:15], title="FDM ∂x2")

# ╔═╡ cdba4d77-da25-477f-af0d-2839479e99db
p3 = contourf(conv∂x2paddedCorrected[:,:,1,1], title="Conv ∂x2")
#p3 = contourf(conv∂x2[10:15,10:15,1,1], title="Conv ∂x2")

# ╔═╡ 4e68eb98-e5ba-4790-b758-10c347e0fa69
#check error
l2error = sum(conv∂x2paddedCorrected[:,:,1,1] - ∂x2)
#l2error = sum(conv∂x2[3:15,3:15,1,1] - ∂x2[3:15,3:15])

# ╔═╡ 80b97ac4-6525-412a-b05c-88ff6ed1851f
begin
	errorfield = (conv∂x2paddedCorrected[:,:,1,1] - ∂x2)
	p4 = contourf(errorfield[:,:,1,1], title="Error Field")
end

# ╔═╡ 1599e52b-dc56-4543-bc93-becc46957076


# ╔═╡ 333ec7f7-0ccc-4e4b-87d6-7d8460938491
md"Need to either a) Really understand details of flux conv implementation to get the FDM kernel apply correctly, or b) Implement Conv operation from scratch with Toeplitz matrices to achieve desired behavior. Then check if Chainrules and Zygote can accumulate gradients thru it"

# ╔═╡ f47c5676-2fb7-4a47-b694-b5ffc1888f9f
out = NNlib.conv(ϕconvPadded,weight∂x)

# ╔═╡ 8e23dbc4-bf0d-4562-b328-f0a6d259aa4a
outDSP = DSP.conv(ϕconvPadded,weight∂x) #has implicit padding

# ╔═╡ 6dd25743-bb29-4fff-a400-1a7fee991e93
∂x2

# ╔═╡ 8f40b148-61ad-49c0-b790-b9425b0a7830
md"## ∂ϕ/∂y2 Derivative with FDM method"

# ╔═╡ d0776e7f-f263-4ae0-aae9-1b7de3c043a9
begin
	#2nd derivative with FDM Central Difference
	∂y2 = Array{Float64}(undef,xl,yl);

	for j=2:yl-1
		∂y2[:,j] = (ϕ[:,j+1] - 2*ϕ[:,j] + ϕ[:,j-1]) ./ (Δy^2);
	end
	∂y2[:,1] = (ϕ[:,2] - ϕ[:,1]) ./ (Δy^2);
	∂y2[:,end] = (ϕ[:,end] - ϕ[:,end-1]) ./ (Δy^2);
end

# ╔═╡ e5c80788-3052-4492-80f1-7a49da4d530a
md"## ∂ϕ/∂y2 Derivative with Conv layers"

# ╔═╡ 2fc0b439-e032-485d-8fc0-a18edf509c40
begin
	centralDiff2ndFDM∂y = averageFactor * [0 0 0;1 -2.0 1;0 0 0] ./ (Δy^2);
	centralDiff2ndFDM∂y = Float32.(reshape(centralDiff2ndFDM∂y,(3,3,1,1)))
end

# ╔═╡ 020ca51e-7962-4b44-9d20-2d67f3db5155
weight∂y = centralDiff2ndFDM∂y #using 2nd order Central Difference Kernel

# ╔═╡ 8aaadd4c-975c-4d6a-8f5e-6d757f28a16b
bias∂y = zeros(1)

# ╔═╡ 360832b4-6c2f-4d85-aac4-9148162900cf
convLayer∂y2 = Flux.Conv(weight∂y,bias∂y,identity; pad=0)

# ╔═╡ ad5123ea-983c-4328-a8ad-2b47e35e06d7
conv∂y2 = convLayer∂y2(ϕconvPadded)

# ╔═╡ ea355191-be55-46fb-a5ff-8095678d06fb
∂y2

# ╔═╡ 496f76cb-5b15-4899-b2ef-1511bbe649b9
begin
	lastRowCorrectionMatrix∂y = ones(xl,yl); # to fix negative value error in last row.
	lastRowCorrectionMatrix∂y[:,end] .= -1.0;
	lastRowCorrectionMatrix∂y = reshape(lastRowCorrectionMatrix∂y,(xl,yl,1,1));
end

# ╔═╡ 61b37dcd-9c69-400e-96b5-eeedeb86f513
conv∂y2Corrected = conv∂y2 .* lastRowCorrectionMatrix∂y

# ╔═╡ Cell order:
# ╠═63d72dc4-6a68-48a8-8535-681a83d041f2
# ╠═83131cf8-472e-4c04-b938-4431c57de855
# ╠═e9e432c7-042b-448d-a35b-df4760fcc54d
# ╠═ca2b45bb-6dab-4f0a-bcc2-07a70830ec29
# ╠═d0494c03-750c-4e5f-a056-f54c450cc274
# ╠═51969182-173f-4e33-a9b3-8d99b2067103
# ╠═ba9bb0f1-17c9-4896-a1c7-2887c198c1c2
# ╠═f43e53cb-7c05-4dc7-b970-a4a146d48790
# ╠═a2f3e642-925d-4054-bd46-376253298dc3
# ╟─36a982fd-0825-49f4-b042-fecd8e08f7f9
# ╠═3bad8683-3365-48e6-84b3-30e5e8e1e94b
# ╠═26db2d50-0e73-4ed3-8239-45a6ea850ca1
# ╠═be18f7f6-d02e-411d-bf45-62b3d3d97aad
# ╠═41bcf658-0c7e-49d0-9392-17b2f9101093
# ╠═bc0eb5c6-e8ff-4634-9f4b-ce70539a4123
# ╠═807b5377-818e-4cef-bca4-7897f7ac111a
# ╟─cbee6d42-5e75-4d81-9109-b28f1e558a00
# ╟─a42aaac0-7c7c-4d00-aef4-292dbb1402cd
# ╠═f0180912-007c-4a2d-815b-f8d58746d0b8
# ╠═791b0b8b-5a49-47d9-af64-82ef9829f966
# ╠═32beebcf-bcdd-4810-bfeb-dd1f8e392fcb
# ╠═a01a1347-15d3-4d97-a2e5-ebe95a93d1b3
# ╠═cb77ccdc-ef2e-4b7f-80a9-d1f2a1ff5755
# ╠═bcd57e86-4bc8-4092-a7db-5749cea8928c
# ╠═67cc0e9d-c7db-4438-ad4d-044f28063d4f
# ╟─7d90fdfe-59d0-47b6-b32a-c596bddfa1b2
# ╠═ba598c7b-4e79-4dba-bdf9-60d2b16c152f
# ╠═73e6d5c2-f136-4fd9-97ff-ab6cb316d626
# ╠═fa90ccb1-e4c0-4e52-9114-262e00434a79
# ╠═bcabd75a-21ae-4884-bdbe-c58c39ef48b4
# ╠═5262ce42-c2a8-445f-825f-2e74b7947860
# ╠═cdba4d77-da25-477f-af0d-2839479e99db
# ╠═4e68eb98-e5ba-4790-b758-10c347e0fa69
# ╠═80b97ac4-6525-412a-b05c-88ff6ed1851f
# ╠═1599e52b-dc56-4543-bc93-becc46957076
# ╟─333ec7f7-0ccc-4e4b-87d6-7d8460938491
# ╠═f47c5676-2fb7-4a47-b694-b5ffc1888f9f
# ╠═8e23dbc4-bf0d-4562-b328-f0a6d259aa4a
# ╠═6dd25743-bb29-4fff-a400-1a7fee991e93
# ╟─8f40b148-61ad-49c0-b790-b9425b0a7830
# ╠═d0776e7f-f263-4ae0-aae9-1b7de3c043a9
# ╟─e5c80788-3052-4492-80f1-7a49da4d530a
# ╠═2fc0b439-e032-485d-8fc0-a18edf509c40
# ╠═020ca51e-7962-4b44-9d20-2d67f3db5155
# ╠═8aaadd4c-975c-4d6a-8f5e-6d757f28a16b
# ╠═360832b4-6c2f-4d85-aac4-9148162900cf
# ╠═ad5123ea-983c-4328-a8ad-2b47e35e06d7
# ╠═ea355191-be55-46fb-a5ff-8095678d06fb
# ╠═496f76cb-5b15-4899-b2ef-1511bbe649b9
# ╠═61b37dcd-9c69-400e-96b5-eeedeb86f513
