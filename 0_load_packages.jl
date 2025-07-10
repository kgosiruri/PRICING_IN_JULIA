#List of Packages

packages = [
    "DataFrames",
    "CSV",
    "Plots",
    "MLDataUtils",
    "StatsBase",
    "StatsPlots",
    "Flux",
    "TensorFlow",
    "StringManipulation",
    "Random",
    "Dates"
]

#Function loading and installing packages
import Pkg

function install_and_load_packages(pkgs)
    for pkg in pkgs
        # Try loading the package, and install it if it fails
        #Julia quite tricky when using ai to predict code as 
        #it is a dynamic language and constantly changing
        try
            @eval using $(Symbol(pkg))
        catch 
            Pkg.add(pkg)
            @eval using $(Symbol(pkg))
        end
    end
    
end

# Call the function to install and load packages

install_and_load_packages(packages)

