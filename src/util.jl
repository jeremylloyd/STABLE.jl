
function sayhi()
    string = "Hello from STABLE."
    println(string)
    return string
end

"Copy and sort a dictionary by value"
function sortbyvals(d::Dict)
    return sort!(OrderedDict(d),byvalue=true,rev=true)
end

"Display the data from the input files"
function display_input(InputDict)
    for sc in keys(InputDict)
        println("\n$(sc):")
        for k in keys(InputDict[sc])
            println("$(k) => $(InputDict[sc][k])")
        end
    end
    return nothing
end

function getRunInstance(run_instances_dc::OrderedDict,run_year::Integer)
    if !(run_year in keys(run_instances_dc))
        error("The run instance year $run_year is not in the provided Instances.")
    end

    RunInstance = run_instances_dc[run_year]
    return RunInstance
end


function InitGlobalSettings()
    return STABLEglobalSettings(8760,2,0.06,1)
end

function InitGlobalSettings(dc::OrderedDict)
    return STABLEglobalSettings(
            dc["Hours"],
            dc["Timestep"],
            dc["DiscountRate"],
            dc["CostScaling"]
            )
end
# InitGlobalSettings(dc::OrderedDict) = InitGlobalSettings(Dict(dc))

function InitScenarios(scen_input_dc::OrderedDict,ScenarioSettings::STABLEglobalSettings)
    Scenarios_Dict = OrderedDict{String,STABLEscenario}()
    for k in keys(scen_input_dc)
        scen_dc = scen_input_dc[k]
        Scenarios_Dict[k] = 
            STABLEscenario(
                ScenarioSettings,
                scen_dc["ScenarioIdentifier"],
                scen_dc["ScenarioName"],
                scen_dc["ScenarioNumber"],
                scen_dc["WeatherYear"],
                scen_dc["TraceYear"],
                scen_dc["MinimumRenewShare"],
                scen_dc["TechCostScenario"],
                scen_dc["FuelCostScenario"],
                scen_dc["VPPbatteryScenario"],
                scen_dc["HydrogenScenario"]
            )
    end
    return Scenarios_Dict
end

function InitInstances(inst_input_dc::OrderedDict,Scenarios_Dict::OrderedDict{String,STABLEscenario})
    Instances_Dict = OrderedDict{String,OrderedDict{Integer,STABLEinstance}}()
    for inst_id in keys(inst_input_dc)
        inst_dc = inst_input_dc[inst_id]
        if !(inst_dc["ScenarioIdentifier"] in keys(Scenarios_Dict))
            error("Scenario $(inst_id) not found in the given Scenario Dict")
        end
        Instances_Dict[inst_id] = OrderedDict{Integer,STABLEinstance}()
        for year in inst_dc["InstanceYears"]
            Instances_Dict[inst_id][year] = 
                STABLEinstance(
                    Scenarios_Dict[inst_dc["ScenarioIdentifier"]], # STABLEscenario
                    inst_id, # InstanceIdentifier
                    year     # InstanceYear
                )
        end
    end
    return Instances_Dict
end

function InitRunSettings(runsettings_input_dc::OrderedDict,ResultsPath::String)
    RunSettingsDict = OrderedDict{String,STABLErunSettings}()
    for k in keys(runsettings_input_dc)
        runsettings_dc = runsettings_input_dc[k]
        RunSettingsDict[k] = 
            STABLErunSettings(
                String(k),   # RunSettingsIdentifier
                ResultsPath, # ResultsPath
                runsettings_dc["Flags"],
                runsettings_dc["Parameters"]
            )
    end
    return RunSettingsDict
end
