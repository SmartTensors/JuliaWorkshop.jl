import SVR
import Mads


x = sort(rand(40) * 5)
y_true = sin.(x);

Mads.plotseries(x; title="Input")

Mads.plotseries(y_true; title="True output")

Mads.plotseries([y_true SVR.fit(y_true, permutedims(x); kernel_type=SVR.RBF)]; title="RBF", names=["Truth", "Prediction"])

Mads.plotseries([y_true SVR.fit(y_true, permutedims(x); kernel_type=SVR.LINEAR)]; title="LINEAR", names=["Truth", "Prediction"])

Mads.plotseries([y_true SVR.fit(y_true, permutedims(x); kernel_type=SVR.POLY)]; title="POLY", names=["Truth", "Prediction"])

t = collect(0:0.1:10)
y = rand(100, 3)
x = y[:,1] .* t' .^ 0.5 + y[:,2] .* t' .+ y[:,3];

Mads.plotseries(x'; xmax=101)

pmodel = SVR.train(x, permutedims(y); tol=0.001, epsilon=0.1);

y_predict = [0.75, 0.1, 0.2]
x_true = y_predict[1] .* t' .^ 0.5 + y_predict[2] .* t' .+ y_predict[3]
x_predict = [SVR.predict(pmodel[i], y_predict)[1] for i = 1:length(t)];

Mads.plotseries([x_true' x_predict]; names=["True", "Prediction"], xmax=101)
