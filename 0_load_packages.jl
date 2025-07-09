#List of Packages

packages = [
    "DataFrames",
    "CSV",
    "Plots",
    "StatsPlots",
    "Flux",
    "TensorFlow",
    "StringManipulation",
    "Dates"
]

#?Function loading and installing packages

function install_and_load_packages(packages)
    for package in packages
        if !haskey(Pkg.installed(), package)
            Pkg.add(package)
        end
        using Symbol(package)
    end
end
# Call the function to load packages

install_and_load_packages(packages)
