

for i = eachindex(a)
using Distributed
@distributed for i in 1:1:11

Threads.@threads for i in 1:1:11
        indice = a[string(varnames[i])]
        if sum(indice) == 0
                @warn("$case $n is empty!")
                continue
        end
        if size(indice, 1) != length(watersheds) || size(indice, 2) !=  length(xaxis) || length(a) != length(varnames_long)
                @warn("$case $n has wrong dimensions: $(size(a))!")
                continue
        end
        wrange = vec(sum(indice; dims=2) .!= 0)
        if sum(.!wrange) > 0
                @warn("Watersheds $(sum(.!wrange)) are empty: $(watersheds[.!wrange])")
        end
        # for i = 1:size(a, 1)
        # Mads.plotseries(permutedims(a[i, :, :]), "figures-$(case)/$(n)/watersheds/$(watersheds[i]).png"; title=watersheds[i], names=varnames_long, xaxis=xaxis)
        # end
        # for i = 1:size(a, 2)
        # Mads.plotseries(permutedims(a[:, i, :]), "figures-$(case)/$(n)/attributes/$(varnames_long[i]).png"; title=varnames_long[i], xaxis=xaxis)
        # end
        # if "Min stream flow" != varnames_long[i]
        # continue
        # end
        @info("Processing $(varnames_long[i]) ...")
        Xo = permutedims(indice)
        X = (Xo .- minimum(Xo)) / (maximum(Xo) - minimum(Xo))
        # Mads.plotseries(Xo, "figures-$(case)/$(n)/$(varnames_long[i])/data.png"; title=varnames_long[i], xaxis=xaxis)
        # Mads.plotseries(X, "figures-$(case)/$(n)/$(varnames_long[i])/data-normalized.png"; title=varnames_long[i], xaxis=xaxis)
        W, H, fitquality, robustness, aic, kopt = NMFk.execute(X, nkrange, nNMF; load=true, resultdir="results-$(case)/$(n)/$(varnames_long[i])")
        ka[i] = kopt
        @info("$(varnames_long[i]): optimal number of features: $kopt")
        # Mads.plotseries([fitquality[nkrange] ./ maximum(fitquality[nkrange]) robustness[nkrange]], "figures-$(case)/$(n)/$(varnames_long[i])/feature_selection.png";  title=varnames_long[i], ymin=0, xaxis=nkrange, xmin=nkrange[1], names=["Fit", "Robustness"])
        kaa[i] = NMFk.getks(nkrange, robustness[nkrange])
        @info("$(varnames_long[i]): plausible number of features: $(kaa[i])")
        for k in kaa[i]
                @info(k)
                if ispath("figures-$(case)/$(n)/$(varnames_long[i])/") == false
                        mkpath("figures-$(case)/$(n)/$(varnames_long[i])/")
                end
                if isfile("figures-$(case)/$(n)/$(varnames_long[i])/groups-$(k)-assignments.jld2")
                        watershed_groups = FileIO.load("figures-$(case)/$(n)/$(varnames_long[i])/groups-$(k)-assignments.jld2", "watershed_groups")
                else
                        watershed_groups = NMFk.robustkmeans(H[k], k).assignments
                        FileIO.save("figures-$(case)/$(n)/$(varnames_long[i])/groups-$(k)-assignments.jld2", "watershed_groups", watershed_groups)
                end
                if k == kopt
                        @info(watershed_groups)
                        wg[i] = watershed_groups
                end
        @info("Attribute vs number of features")
        display([varnames_long ka])
        @info("$case")
        @info("Model: $n")
        @info("Indice: $(varnames[i])")
        @info("groupse-$(k)-assignments")
        DelimitedFiles.writedlm("figures-$(case)/$(n)/$(varnames_long[i])/groups-$(k)-assignments.dat", [watersheds[wrange] watershed_groups[wrange]], ',')
        #DelimitedFiles.writedlm("figures-$(case)/$(n)/$(varnames_long[i])/groups-$(k)-assignments.dat", [watersheds watershed_groups], ',')
        for g in sort(unique(watershed_groups))
                @info("$(varnames_long[i]): group #$(g) out of $(k):")
                display(watersheds[wrange][watershed_groups[wrange] .== g])
        # Mads.plotseries(Xo[:,watershed_groups .== g], "figures-$(case)/$(n)/$(varnames_long[i])/group_$(k)_$(g).png"; title="$(varnames_long[i]): group #$(g) out of $(k)", name="", xaxis=xaxis)
        end
end
