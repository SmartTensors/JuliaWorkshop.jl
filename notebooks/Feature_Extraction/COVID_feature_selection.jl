import XLSX
import NMFk
import SVR
import Statistics
import LinearAlgebra
import Dates
import Mads


ev, eh = XLSX.readtable("Data/CountyData (09-02-2020).xlsx", "Export"; header=true, stop_in_empty_row=false)
ncounties = length(ev[1])
weight = ev[6] ./ maximum(ev[6])
statecounty = ev[3] .* " " .* ev[4]
fips = parse.(Int64, ev[5])
fips[indexin(46102, fips)[1]] = 46113
skipvar = 5
varnames = NMFk.replace.(String.(eh[skipvar+1:end]), "denomin-ational" => "denominational", "busin-esses" => "businesses", "partici-pation" => "participation", "Retire-ment" => "Retirement", "Agri-culture" => "Agriculture", r" +" => " ", "\t" => " ")
nvar = length(varnames)
M = Array{Float32}(undef, ncounties, nvar)
for i in 1:nvar
	@show varnames[i]
	try
		M[:, i] = NMFk.processdata(ev[i+skipvar]; nanstring="x")
	catch
		display(ev[i+skipvar][2:end])
	end
end
varid = parse.(Int64, map(i->split(i, ' ')[2], varnames))

#NMFk.plotscatter(M[:,indexin(466, varid)[1]], M[:,indexin(325, varid)[1]])

xindex = [collect(1:1); collect(10:nvar)]
yindex = 2:9
xvar = varnames[xindex]
yvar = varnames[yindex]
X = M[:, xindex]
Y = M[:, yindex]
r2 = NMFk.r2matrix(X, Y)
for i = 1:length(yvar)
	@show yvar[i]
	is = sortperm(r2[:,i]; rev=true)
	display([xvar r2][is,[1,i+1]])
end

Mn, nmin, nmax = NMFk.normalizematrix_col!(M)
Mn_COVID = Mn
Mn_COVID[:,3:18] = Mn_COVID[:,3:18]*10

nkrange = 2:7
NMFk.execute(Mn_COVID, nkrange; resultdir="results-nmfk-COVID", casefilename="nmfk-n-$(join(size(Mn), '_'))", load=true)
W, H, fitquality, robustness, aic = NMFk.load(nkrange; resultdir="results-nmfk-COVID", casefilename="nmfk-n-$(join(size(Mn), '_'))")
NMFk.clusterresults(NMFk.getks(nkrange, robustness[nkrange]), W, H, statecounty, varnames; Wcasefilename="counties", Hcasefilename="attr", resultdir="results-n-covid", figuredir="figures-n-covid", Wplotlabel=false, Hplotlabel=false, biplotlabel=:none, biplotcolor=:W)

NMFk.execute(Mn_COVID, nkrange; weight=weight, resultdir="results-nmfk-COVID", casefilename="nmfk-nw-$(join(size(Mn), '_'))", load=true)
W, H, fitquality, robustness, aic = NMFk.load(nkrange; resultdir="results-nmfk-COVID", casefilename="nmfk-nw-$(join(size(Mn), '_'))")
NMFk.clusterresults(NMFk.getks(nkrange, robustness[nkrange]), W, H, statecounty, varnames; Wcasefilename="counties", Hcasefilename="attr", resultdir="results-nw-covid", figuredir="figures-nw-covid", Wplotlabel=false, Hplotlabel=false, biplotlabel=:none, biplotcolor=:W)

for k in NMFk.getks(nkrange, robustness[nkrange])
	Wa, _, _ = NMFk.normalizematrix_col!(W[k])
	NMFk.plotmap(Wa, fips, 2; titletext="Signal", title=false, figuredir="maps-nw-covid", casefilename="signals$k")
	Wclusterlabelsnew, Wsignalmapnew, Hclusterlabels, Hclustermap = NMFk.signalorder(W[k], H[k]; resultdir="results-nw-covid")
	NMFk.plotmap(Wsignalmapnew, fips; figuredir="maps-nw-covid", casefilename="signals$k")
	NMFk.plotmap(Wclusterlabelsnew, fips; figuredir="maps-nw-covid", casefilename="signals$k-labeled")
end

Mnl = log10.(Mn)
Mnl[isinf.(Mnl)] .= -8
Mnln, nlnmin, nlnmax = NMFk.normalizematrix_col!(Mnl)
Mn_COVID = Mnln
Mn_COVID[:,3:18] = Mn_COVID[:,3:18]*10

NMFk.execute(Mnln, nkrange; resultdir="results-nmfk-COVID", casefilename="nmfk-nln-$(join(size(Mnln), '_'))", load=true)
W, H, fitquality, robustness, aic = NMFk.load(nkrange; resultdir="results-nmfk-covid", casefilename="nmfk-nln-$(join(size(Mn), '_'))")
NMFk.clusterresults(NMFk.getks(nkrange, robustness[nkrange]), W, H, statecounty, varnames; Wcasefilename="counties", Hcasefilename="attr", resultdir="results-nln-covid", figuredir="figures-nln-covid", Wplotlabel=false, Hplotlabel=false, biplotlabel=:none, biplotcolor=:W)

NMFk.execute(Mnln, nkrange; weight=weight, resultdir="results-nmfk-COVID", casefilename="nmfk-nlnw-$(join(size(Mnln), '_'))", load=true)
W, H, fitquality, robustness, aic = NMFk.load(nkrange; resultdir="results-nmfk-covid", casefilename="nmfk-nlnw-$(join(size(Mn), '_'))")
NMFk.clusterresults(NMFk.getks(nkrange, robustness[nkrange]), W, H, statecounty, string.(varid); Wcasefilename="counties", Hcasefilename="attr", resultdir="results-nlnw-covid", figuredir="figures-nlnw-covid", Wplotlabel=false, Hplotlabel=true, biplotlabel=:none, biplotcolor=:W)
NMFk.clusterresults(NMFk.getks(nkrange, robustness[nkrange]), W, H, statecounty, varnames; Wcasefilename="counties", Hcasefilename="attr", resultdir="results-nlnw-covid", figuredir="figures-nlnw-covid", Wplotlabel=false, Hplotlabel=false, biplotlabel=:none, biplotcolor=:W)

for k in NMFk.getks(nkrange, robustness[nkrange])
	Wa, _, _ = NMFk.normalizematrix_col!(W[k])
	NMFk.plotmap(Wa, fips, 2; titletext="Signal", title=false, figuredir="maps-nlnw-covid", casefilename="signals$k")
	Wclusterlabelsnew, Wsignalmapnew, Hclusterlabels, Hclustermap = NMFk.signalorder(W[k], H[k]; resultdir="results-nlnw-covid")
	NMFk.plotmap(Wsignalmapnew, fips; figuredir="maps-nlnw-covid", casefilename="signals$k")
	NMFk.plotmap(Wclusterlabelsnew, fips; figuredir="maps-nlnw-covid", casefilename="signals$k-labeled")
end
