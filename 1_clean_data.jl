### Clean Data 

using CSV, DataFrames, StatsBase, Flux, MLDataUtils, Random

# Load the data
df = CSV.read("freMTPL2freq.csv", DataFrame)
df.id = 1:nrow(df)
df.Density = log.(df.Density)

#Capping outliers

df.Exposure .= clamp.(df.Exposure, 0, 1)
df.ClaimNb .= clamp.(df.ClaimNb, 4)

# Categorical vs Continuous Variables
cat_vars = [:VehBrand, :Region, Area, :DrivAgeClass]
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
