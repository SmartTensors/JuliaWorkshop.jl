import DelimitedFiles
import XLSX
import DataFrames

dir = @__DIR__
cd(dir)

X = rand(10,5)
DelimitedFiles.writedlm(joinpath(dir, "rand.csv"), X, ',')
Xn = DelimitedFiles.readdlm(joinpath(dir, "rand.csv"), ',')
@assert(X == Xn)
rm(joinpath(dir, "rand.csv"))

df = DataFrames.DataFrame(Name=["Cats", "Dogs", "Horses"], Value=[1.3, 2.1, 5.5])
XLSX.openxlsx(joinpath(dir, "test.xlsx"), mode="w") do xf
	XLSX.addsheet!(xf, "Animals")
	for (col, name) in enumerate(names(df))
		xf["Animals"][XLSX.CellRef(1, col)] = name
	end
	for row in 1:size(df, 1), col in 1:size(df, 2)
		xf["Animals"][XLSX.CellRef(row + 1, col)] = df[row, col]
	end
end

a = XLSX.readtable(joinpath(dir, "test.xlsx"), "Animals"; header=false, stop_in_empty_row=false, first_row=0)

rm(joinpath(dir, "test.xlsx"))