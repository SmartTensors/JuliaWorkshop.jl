import DelimitedFiles
import HDF5
import FileIO
import JLD2
import Plotly
import PlotlyJS
import Mads
import TensorDecompositions
import NTFk
import NMFk


#varnames_long = ["Dry dates", "Max evaporation", "Max precipitation", "Min stream flow", "Max stream flow", "Min soil moisture", "Max soil moisture", "Max snow water equivalent", "Min temperature", "Max temperature", "Max wind speed"]
#varnames = [:dryd, :evapx, :precx, :qn, :qx, :soilmn, :soilmx, :swex, :tn, :tx, :windx]
varnames_long = ["Min stream flow"]
varnames = [:qn]
wmodels = ["GFDL-ESM2G", "IPSL-CM5A-LR"]

indir = cwd()
indir = "/project/hydroclimate/tensor/h5files_extractedfrom_ESMs/"
dr, hr = DelimitedFiles.readdlm("data/CRB.csv", ','; header=true)
dn, hn = DelimitedFiles.readdlm("data/huc8id_name_unique.csv", ','; header=true)
dx = DelimitedFiles.readdlm("data/huc8_list.txt", ' ')
ii = indexin(dr[:,11], dn[:,1])
ii = indexin(dx, dn[:,1])
watersheds = dn[ii[ii .!= nothing], 3]

# Check if files are empty
for d in readdir(indir)
        @info("File $d")
        if splitext(d)[2] != ".h5"
                continue
        elseif occursin("062220", d) == false
                continue
        elseif occursin("5day", d) == false # only running the 5day data
                continue
        end
        case = splitext(d)[1]
        @info("Processing $case ...")
        (x1, x2) = occursin("future", case) ? (2070,2099) : (1970,1999)
        if occursin("sea", case)
                xaxis = x1:0.25:x2+0.75
        elseif occursin("mon", case)
                xaxis = x1:1/12:x2+11/12
        elseif occursin("ann", case)
                xaxis = x1:1:x2
        else
                xaxis = 1:1:73
        end
        hf = HDF5.h5open(indir*"$(d)")
        nkrange = 2:10
        nNMF = 10
        for n in names(hf)
                a = HDF5.read(hf, n)
                #for key in collect(keys(a))
                Threads.@threads for key in collect(keys(a))
                        indice = a[key]
                        if sum(indice) == 0
                                @warn("$case $n is empty!")
                                continue
                        end
                        if size(indice, 1) != length(watersheds) || size(indice, 2) !=  length(xaxis) || size(collect(keys(a)))[1] != length(varnames_long)
                                @warn("$case $n has wrong dimensions: $(size(a))!")
                                continue
                        end
                        wrange = vec(sum(indice; dims=2) .!= 0)
                        if sum(.!wrange) > 0
                                @warn("Watersheds $(sum(.!wrange)) are empty: $(watersheds[.!wrange]) $key")
                        end
                end
        end
        HDF5.close(hf)
end

# Run NMFk on Indice Data
for d in readdir(indir)
        if splitext(d)[2] != ".h5"
                continue
        elseif occursin("062220", d) == false
                continue
        end
        case = splitext(d)[1]
        # if case != "future_mon"
        # continue
        # end
        @info("Processing $case ...")
        (x1, x2) = occursin("future", case) ? (2070,2099) : (1970,1999)
        xaxis = 1:1:73
        #if occursin("sea", case)
        #        xaxis = x1:0.25:x2+0.75
        #elseif occursin("mon", case)
        #        xaxis = x1:1/12:x2+11/12
        #elseif occursin("ann", case)
        #        xaxis = x1:1:x2
        #else
        #        xaxis = 1:1:73
        #end
        if !occursin("5day", case)
                continue
        end
        hf = HDF5.h5open(indir*"$(d)")
        nkrange = 2:6
        nNMF = 10
        for n in names(hf)
                # if n != "GFDL-ESM2M"
                # continue
                # end
                a = HDF5.read(hf, n)
                # for i = 1:length(a)
                ka = Vector{Int64}(undef, length(a))
                kaa = Vector{Vector{Int64}}(undef, length(a))
                wg = Vector{Vector{Int64}}(undef, length(a))
                Threads.@threads for i in 1:1:length(a)
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
                                @info("groups-$(k)-assignments")
                                @info([watersheds[wrange] watershed_groups[wrange]])
                                DelimitedFiles.writedlm("figures-$(case)/$(n)/$(varnames_long[i])/groups-$(k)-assignments.dat", [watersheds[wrange] watershed_groups[wrange]], ',')
                                # if isfile("figures-historical_ann/$(n)/$(varnames_long[i])/groups-$(k)-assignments.dat")
                                #        old_group = DelimitedFiles.readdlm("figures-historical_ann/$(n)/$(varnames_long[i])/groups-$(k)-assignments.dat", ',')
                                #        new_group = [watersheds[wrange] watershed_groups[wrange]]
                                #        old_group=old_group[sortperm(old_group[:,1]),:]
                                #        new_group = new_group[sortperm(new_group[:,1]),:]
                                #        if old_group != new_group
                                #                @warn("Old Group does not match new Group!")
                                #        else
                                #                @info("Old Group Matches New Group!!!")
                                #        end
                                #end
                                #DelimitedFiles.writedlm("figures-$(case)/$(n)/$(varnames_long[i])/groups-$(k)-assignments.dat", [watersheds watershed_groups], ',')
                                for g in sort(unique(watershed_groups))
                                        @info("$(varnames_long[i]): group #$(g) out of $(k):")
                                        display(watersheds[wrange][watershed_groups[wrange] .== g])
                                        # Mads.plotseries(Xo[:,watershed_groups .== g], "figures-$(case)/$(n)/$(varnames_long[i])/group_$(k)_$(g).png"; title="$(varnames_long[i]): group #$(g) out of $(k)", name="", xaxis=xaxis)
                                end
                        end
                end
                DelimitedFiles.writedlm("figures-$(case)/$(n)/number_of_features_optimal.dat", [varnames_long ka], ',')
                DelimitedFiles.writedlm("figures-$(case)/$(n)/number_of_features_plausible.dat", [varnames_long kaa], ',')
                s = NMFk.sankey(wg, varnames_long)
                PlotlyJS.savehtml(s, "figures-$(case)/$(n)/sankey-watersheds.html", :remote)
        end
        HDF5.close(hf)
end


for d in readdir(indir)
        if splitext(d)[2] != ".h5"
                continue
        elseif occursin("062220", d) == false
                continue
        end
        case = splitext(d)[1]
        # if case != "future_mon"
        # continue
        # end
        if !isdir("results-$(case)")
                continue
        end
        @info("Processing $case ...")
        nkrange = 2:20
        nNMF = 10
        # for n in wmodels
        Threads.@threads for n in wmodels
                if !isdir("results-$(case)/$(n)")
                        continue
                end
                @info("Processing $n ...")
                # if n != "GFDL-ESM2M"
                # continue
                # end
                ka = Vector{Int64}(undef, length(varnames_long))
                kaa = Vector{Vector{Int64}}(undef, length(varnames_long))
                wg = Vector{Vector{Int64}}(undef, length(varnames_long))
                wgf = falses(length(varnames_long))
                for i = 1:length(varnames_long)
                        # if "Min stream flow" != varnames_long[i]
                        # continue
                        # end
                        @info("Processing $(varnames_long[i]) ...")
                        W, H, fitquality, robustness, aic, kopt = NMFk.load(nkrange, nNMF; resultdir="results-$(case)/$(n)/$(varnames_long[i])")
                        ka[i] = kopt
                        @info("$(varnames_long[i]): optimal number of features: $kopt")
                        kaa[i] = NMFk.getks(nkrange, robustness[nkrange])
                        @info("$(varnames_long[i]): plausible number of features: $(kaa[i])")
                        for k in 3
                                if isfile("figures-$(case)/$(n)/$(varnames_long[i])/groups-$(k)-assignments.jld2")
                                        watershed_groups = FileIO.load("figures-$(case)/$(n)/$(varnames_long[i])/groups-$(k)-assignments.jld2", "watershed_groups")
                                else
                                        watershed_groups = NMFk.robustkmeans(H[k], k).assignments
                                        FileIO.save("figures-$(case)/$(n)/$(varnames_long[i])/groups-$(k)-assignments.jld2", "watershed_groups", watershed_groups)
                                end
                                if k == kopt
                                        wg[i] = watershed_groups
                                        wgf[i] = true
                                end
                        end
                end
                if all(wgf)
                        s = NMFk.sankey(wg, varnames_long)
                        PlotlyJS.savehtml(s, "figures-$(case)/$(n)/sankey-watersheds.html", :remote)
                end
        end
end

for d in readdir(indir)
        if splitext(d)[2] != ".h5"
                continue
        elseif occursin("062220", d) == false
                continue
        end
        case = splitext(d)[1]
        # if case != "future_mon"
        # continue
        # end
        if !isdir("results-$(case)")
                continue
        end
        @info("Processing $case ...")
        nkrange = 2:20
        nNMF = 10
        for i = 1:length(varnames_long)
                # if "Min stream flow" != varnames_long[i]
                # continue
                # end
                @info("Processing $(varnames_long[i]) ...")
                ka = Vector{Int64}(undef, length(wmodels))
                kaa = Vector{Vector{Int64}}(undef, length(wmodels))
                wg = Vector{Vector{Int64}}(undef, length(wmodels))
                wgf = falses(length(wmodels))
                for (j, n) in enumerate(wmodels)
                        if !isdir("results-$(case)/$(n)")
                                continue
                        end
                        @info("Processing $n ...")
                        # if n != "GFDL-ESM2M"
                        # continue
                        # end
                        W, H, fitquality, robustness, aic, = NMFk.load(nkrange, nNMF; resultdir="results-$(case)/$(n)/$(varnames_long[i])")
                        kopt = NMFk.getk(nkrange, robustness[nkrange])
                        ka[j] = kopt
                        @info("$(varnames_long[i]): optimal number of features: $kopt")
                        kaa[j] = NMFk.getks(nkrange, robustness[nkrange])
                        @info("$(varnames_long[i]): plausible number of features: $(kaa[j])")
                        for k in kaa[j]
                                if isfile("figures-$(case)/$(n)/$(varnames_long[i])/groups-$(k)-assignments.jld2")
                                        watershed_groups = FileIO.load("figures-$(case)/$(n)/$(varnames_long[i])/groups-$(k)-assignments.jld2", "watershed_groups")
                                else
                                        watershed_groups = NMFk.robustkmeans(H[k], k).assignments
                                        FileIO.save("figures-$(case)/$(n)/$(varnames_long[i])/groups-$(k)-assignments.jld2", "watershed_groups", watershed_groups)
                                end
                                if k == kopt
                                        wg[j] = watershed_groups
                                        wgf[j] = true
                                end
                        end
                end
                if all(wgf)
                        s = NMFk.sankey(wg, wmodels)
                        PlotlyJS.savehtml(s, "figures-$(case)/sankey-$(varnames_long[i]).html", :remote)
                end
        end
end


# ------------------------------------------------------- Process Future - Historical Difference ---------------------------------------- #

for d in readdir(indir)
        if splitext(d)[2] != ".h5"
                continue
        elseif occursin("062220", d) == false
                continue
        elseif occursin("historical", d) == true
                continue
        end
        case = splitext(d)[1]
        # if case != "future_mon"
        # continue
        # end
        @info("Processing $case ...")
        (x1, x2) = occursin("future", case) ? (2070,2099) : (1970,1999)
        if occursin("sea", case)
                xaxis = x1:0.25:x2+0.75
        elseif occursin("mon", case)
                xaxis = x1:1/12:x2+11/12
        elseif occursin("ann", case)
                xaxis = x1:1:x2
        else
                xaxis = 1:1:73
        end
        if !occursin("5day", case)
                continue
        end
        case = replace(case, "future"=>"change")
        hf = HDF5.h5open(indir*"$(d)")
        d2 = replace(d, "future"=>"historical")
        hf2 = HDF5.h5open(indir*"$(d2)")
        nkrange = 2:6
        nNMF = 10
        for n in names(hf)
                # if n != "GFDL-ESM2M"
                # continue
                # end
                a = HDF5.read(hf, n)
                a2 = HDF5.read(hf2, n)
                # for i = 1:length(a)
                ka = Vector{Int64}(undef, length(a))
                kaa = Vector{Vector{Int64}}(undef, length(a))
                wg = Vector{Vector{Int64}}(undef, length(a))
                Threads.@threads for i in 1:1:length(a)
                        indice = a[string(varnames[i])]
                        indice2 = a2[string(varnames[i])]
                        indice = indice - indice2
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
                                @info("groups-$(k)-assignments")
                                @info([watersheds[wrange] watershed_groups[wrange]])
                                DelimitedFiles.writedlm("figures-$(case)/$(n)/$(varnames_long[i])/groups-$(k)-assignments.dat", [watersheds[wrange] watershed_groups[wrange]], ',')
                                # if isfile("figures-historical_ann/$(n)/$(varnames_long[i])/groups-$(k)-assignments.dat")
                                #        old_group = DelimitedFiles.readdlm("figures-historical_ann/$(n)/$(varnames_long[i])/groups-$(k)-assignments.dat", ',')
                                #        new_group = [watersheds[wrange] watershed_groups[wrange]]
                                #        old_group=old_group[sortperm(old_group[:,1]),:]
                                #        new_group = new_group[sortperm(new_group[:,1]),:]
                                #        if old_group != new_group
                                #                @warn("Old Group does not match new Group!")
                                #        else
                                #                @info("Old Group Matches New Group!!!")
                                #        end
                                #end
                                #DelimitedFiles.writedlm("figures-$(case)/$(n)/$(varnames_long[i])/groups-$(k)-assignments.dat", [watersheds watershed_groups], ',')
                                for g in sort(unique(watershed_groups))
                                        @info("$(varnames_long[i]): group #$(g) out of $(k):")
                                        display(watersheds[wrange][watershed_groups[wrange] .== g])
                                        # Mads.plotseries(Xo[:,watershed_groups .== g], "figures-$(case)/$(n)/$(varnames_long[i])/group_$(k)_$(g).png"; title="$(varnames_long[i]): group #$(g) out of $(k)", name="", xaxis=xaxis)
                                end
                        end
                end
                DelimitedFiles.writedlm("figures-$(case)/$(n)/number_of_features_optimal.dat", [varnames_long ka], ',')
                DelimitedFiles.writedlm("figures-$(case)/$(n)/number_of_features_plausible.dat", [varnames_long kaa], ',')
                s = NMFk.sankey(wg, varnames_long)
                PlotlyJS.savehtml(s, "figures-$(case)/$(n)/sankey-watersheds.html", :remote)
        end
        HDF5.close(hf)
end


# ------------------------------------------------------ Run Joint Indice Scenario  ----------------------------------------- #


for d in readdir(indir)
        if splitext(d)[2] != ".h5"
                continue
        elseif occursin("062220", d) == false
                continue
        end
        case = splitext(d)[1]
        # if case != "future_mon"
        # continue
        # end
        @info("Processing $case ...")
        (x1, x2) = occursin("future", case) ? (2070,2099) : (1970,1999)
        if occursin("sea", case)
                xaxis = x1:0.25:x2+0.75
        elseif occursin("mon", case)
                xaxis = x1:1/12:x2+11/12
        elseif occursin("ann", case)
                xaxis = x1:1:x2
        else
                xaxis = 1:1:73
        end
        if !occursin("5day", case)
                continue
        end
        if occursin("future", case)
                case = replace(case, "future"=>"future-joint")
        elseif occursin("historical", case)
                case = replace(case, "historical"=>"historical-joint")
        end
        hf = HDF5.h5open(indir*"$(d)")
        nkrange = 2:6
        nNMF = 10
        for n in names(hf)
                # if n != "GFDL-ESM2M"
                # continue
                # end
                a = HDF5.read(hf, n)
                # for i = 1:length(a)
                ka = Vector{Int64}(undef, length(a))
                kaa = Vector{Vector{Int64}}(undef, length(a))
                wg = Vector{Vector{Int64}}(undef, length(a))
                indice = cat(values(a)..., dims=3)
                if sum(indice) == 0
                        @warn("$case $n is empty!")
                        continue
                end
                if size(indice, 1) != length(watersheds) || size(indice, 2) !=  length(xaxis) || length(a) != length(varnames_long)
                        @warn("$case $n has wrong dimensions: $(size(a))!")
                        continue
                end
                wrange = vec(sum(indice; dims=(2,3)) .!= 0)
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
                @info("Processing Joint ...")
                @info(size(indice))
                @info(ndims(indice))
                Xo = permutedims(indice, [2,1,3])
                X = (Xo .- minimum(Xo)) / (maximum(Xo) - minimum(Xo))
                # Mads.plotseries(Xo, "figures-$(case)/$(n)/$(varnames_long[i])/data.png"; title=varnames_long[i], xaxis=xaxis)
                # Mads.plotseries(X, "figures-$(case)/$(n)/$(varnames_long[i])/data-normalized.png"; title=varnames_long[i], xaxis=xaxis)
                W, H, fitquality, robustness, aic, kopt = NMFk.execute(X, nkrange, nNMF; load=true, resultdir="results-$(case)/$(n)/joint")
                ka = kopt
                @info("joint: optimal number of features: $(kopt)")
                # Mads.plotseries([fitquality[nkrange] ./ maximum(fitquality[nkrange]) robustness[nkrange]], "figures-$(case)/$(n)/$(varnames_long[i])/feature_selection.png";  title=varnames_long[i], ymin=0, xaxis=nkrange, xmin=nkrange[1], names=["Fit", "Robustness"])
                kaa = NMFk.getks(nkrange, robustness[nkrange])
                @info("joint: plausible number of features: $(kaa)")
                for k in kaa
                        @info(k)
                        if ispath("figures-$(case)/$(n)/joint/") == false
                                mkpath("figures-$(case)/$(n)/joint)/")
                        end
                        if isfile("figures-$(case)/$(n)/joint/groups-$(k)-assignments.jld2")
                                watershed_groups = FileIO.load("figures-$(case)/$(n)/joint/groups-$(k)-assignments.jld2", "watershed_groups")
                        else
                                watershed_groups = NMFk.robustkmeans(H[k], k).assignments
                                FileIO.save("figures-$(case)/$(n)/joint/groups-$(k)-assignments.jld2", "watershed_groups", watershed_groups)
                        end
                        if k == kopt
                                @info(watershed_groups)
                                wg = watershed_groups
                        end
                        @info("Attribute vs number of features")
                        display([varnames_long ka])
                        @info("$case")
                        @info("Model: $n")
                        @info("Indice: joint")
                        @info("groups-$(k)-assignments")
                        @info([watersheds[wrange] watershed_groups[wrange]])
                        DelimitedFiles.writedlm("figures-$(case)/$(n)/joint/groups-$(k)-assignments.dat", [watersheds[wrange] watershed_groups[wrange]], ',')
                        # if isfile("figures-historical_ann/$(n)/$(varnames_long[i])/groups-$(k)-assignments.dat")
                        #        old_group = DelimitedFiles.readdlm("figures-historical_ann/$(n)/$(varnames_long[i])/groups-$(k)-assignments.dat", ',')
                        #        new_group = [watersheds[wrange] watershed_groups[wrange]]
                        #        old_group=old_group[sortperm(old_group[:,1]),:]
                        #        new_group = new_group[sortperm(new_group[:,1]),:]
                        #        if old_group != new_group
                        #                @warn("Old Group does not match new Group!")
                        #        else
                        #                @info("Old Group Matches New Group!!!")
                        #        end
                        #end
                        #DelimitedFiles.writedlm("figures-$(case)/$(n)/$(varnames_long[i])/groups-$(k)-assignments.dat", [watersheds watershed_groups], ',')
                        for g in sort(unique(watershed_groups))
                                @info("Joint: group #$(g) out of $(k):")
                                display(watersheds[wrange][watershed_groups[wrange] .== g])
                                # Mads.plotseries(Xo[:,watershed_groups .== g], "figures-$(case)/$(n)/$(varnames_long[i])/group_$(k)_$(g).png"; title="$(varnames_long[i]): group #$(g) out of $(k)", name="", xaxis=xaxis)
                        end
                end
                DelimitedFiles.writedlm("figures-$(case)/$(n)/number_of_features_optimal.dat", [varnames_long ka], ',')
                DelimitedFiles.writedlm("figures-$(case)/$(n)/number_of_features_plausible.dat", [varnames_long kaa], ',')
                s = NMFk.sankey(wg, varnames_long)
                PlotlyJS.savehtml(s, "figures-$(case)/$(n)/sankey-watersheds.html", :remote)
        end
        HDF5.close(hf)
end
