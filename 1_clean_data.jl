### Clean Data 

using CSV, DataFrames, StatsBase, Flux, MLDataUtils, Random

# Load the data
df = CSV.read("freMTPL2freq.csv", DataFrame)
df.id = 1:nrow(df)
df.Density = log.(df.Density)

#Capping outliers

df.Exposure .= clamp.(df.Exposure, 0, 1)
df.ClaimNb .= min.(df.ClaimNb, 4)

# Categorical vs Continuous Variables
cat_vars = [:VehBrand, :Region, :Area, :DrivAgeClass]
cont_vars = [:VehPower, :VehAge, :DrivAge, :BonusMalus, :Density]

# Train and Test Data 

Random.seed!(1234)

rows = collect(1:nrow(df))
train_indices = sample(rows, round(Int, 0.9 * length(rows)), replace=false)
test_indices = setdiff(rows, train_indices)

train = df[train_indices, :]
test = df[test_indices, :]

train.set = "train"
test.set = "test"
dat = vcat(train, test)

# Empirical Frequency check 

mean_claim_rate = sum(df.ClaimNb)/sum(df.Exposure)

@info "Train freq: $(mean_claim_rate(train))"
@info "Test freq: $(mean_claim_rate(test))"

# Min-Max Scaling (continous)
function min_max_scale(x)
    min_, Max_x = minimumx(x), maximum(x)
    return (x .- min_x) ./ (max_x - min_x), min_x, max_x
end

for col in cat_vars
    scaled, minval, maxval = min_max_scale(train[!, col])
    train[!, Symbol(col, "_input")] = scaled
    test[!, Symbol(col, "_input")] = (test[!, col] .- minval) ./ (maxval - minval)
end

# Categorical Encoding
# This function encodes categorical variables into numerical format
# using a simple mapping from levels to integers.
# It creates a new column with the suffix "_input" for each categorical variable.
function encode_categorical!(df_train, df_test, col)
    levels = unique(df_train[!, col])
    level_map = Dict(level => i for (i, level) in enumerate(levels))
    df_train[!, Symbol(col, "_input")] = [level_map[v] for v in df_train[!, col]]
    df_test[!, Symbol(col, "_input")] = [get(level_map, v, 0) for v in df_test[!, col]]
end

for col in cat_vars
    encode_categorical!(train, test, col)
end

#Keras-style input
# This function prepares the input data for a Keras-style model.

function get_keras_input(df, cont_vars, cat_vars)
    input = Dict()
    for col in vcat(cont_vars, cat_vars)
        input[Symbol(col, "_input")] = Matrix(df[!, Symbol(col, "_input")])
    end
    input[:Exposure] = Matrix(df[!, :Exposure])
    return input
end

train_x = get_keras_input(train, cont_vars, cat_vars)
test_x = get_keras_input(test, cont_vars, cat_vars)

train_y = Matrix(train[!, :ClaimNb])
test_y = Matrix(test[!, :ClaimNb])
