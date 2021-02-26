
function sayhi()
    string = "Hello from STABLE."
    println(string)
    return string
end

"Copy and sort a dictionary by value"
function sortbykeys(d::Dict)
    return sort!(OrderedDict(d),byvalue=false)
end

"Copy and sort a dictionary by value"
function sortbyvals(d::Dict;rev=true)
    return sort!(OrderedDict(d),byvalue=true,rev=rev)
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

"Get a Run instance for a given year from a set of Instances"
function getRunInstance(run_instances_dc::OrderedDict,run_year::Integer)
    if !(run_year in keys(run_instances_dc))
        error("The run instance year $run_year is not in the provided Instances.")
    end

    RunInstance = run_instances_dc[run_year]
    return RunInstance
end

"Flattens all STABLE configuration settings into a Dieter settings `Dict`"
function create_Dieter_settings(ST_run::STABLErun)
    dtr_settings = Dict{Symbol,Any}()

    hoursInYear = Dieter.hoursInYear

    instance = ST_run.RunInstance
    scenario = instance.InstanceScenario
    global_settings = scenario.ScenarioSettings
    run_settings = ST_run.RunSettings
    
    dtr_settings[:hours] = global_settings.Hours
    dtr_settings[:timestep] = global_settings.Timestep
    dtr_settings[:interest] = global_settings.DiscountRate
    dtr_settings[:cost_scaling] = global_settings.CostScaling

    dtr_settings[:periods] = round(Int,hoursInYear*(2/global_settings.Timestep))

    dtr_settings[:scen] = scenario.ScenarioIdentifier
    dtr_settings[:scen_name] = scenario.ScenarioName
    dtr_settings[:scen_number] = scenario.ScenarioNumber
    dtr_settings[:weather_year] = scenario.WeatherYear
    dtr_settings[:trace_year] = scenario.TraceYear
    dtr_settings[:min_res] = scenario.MinimumRenewShare
    dtr_settings[:min_res_system] = scenario.MinimumRenewShare
    dtr_settings[:tech_cost_scen] = scenario.TechCostScenario
    dtr_settings[:fuel_cost_scen] = scenario.FuelCostScenario
    dtr_settings[:vpp_scen] = scenario.VPPbatteryScenario
    dtr_settings[:h2_scen] = scenario.HydrogenScenario
    dtr_settings[:tx_scen] = scenario.TxScenario

    dtr_settings[:inst_id] = instance.InstanceIdentifier
    dtr_settings[:inst_year] = instance.InstanceYear

    # dtr_settings[:scen] changed to dtr_settings[:run_id]
    dtr_settings[:run_id] = ST_run.RunIdentifier
    dtr_settings[:run_time_start] = ST_run.RunTimestampStart
    dtr_settings[:run_time_finish] = ST_run.RunTimestampFinish
    dtr_settings[:run_status] = ST_run.RunStatus
    dtr_settings[:run_note] = ST_run.RunNote
    dtr_settings[:results_id] = ST_run.ResultsIdentifier
    dtr_settings[:results_dir] = ST_run.ResultsPath

    dtr_settings[:ev_flag] = run_settings.Flags["EV"]
    if dtr_settings[:ev_flag] == false
        dtr_settings[:ev] = missing
    else
        dtr_settings[:ev] = dtr_settings[:ev_flag]
    end

    dtr_settings[:heat_flag] = run_settings.Flags["HeatLoads"]
    if dtr_settings[:heat_flag] == false
        dtr_settings[:heat] = missing
    else
        dtr_settings[:heat] = dtr_settings[:heat_flag]
    end
    
    dtr_settings[:h2_flag] = run_settings.Flags["H2"]  # 0 (`false`) means H2 not included, positive number means H2 included
    if dtr_settings[:h2_scen] > 0   # Overwrite h2_flag settting by using the Scenario setting (may revise in future)
        dtr_settings[:h2_flag] = true
    else
        dtr_settings[:h2_flag] = false
    end
    if dtr_settings[:h2_flag]
        # If h2_scen is 1, we just consider a single scenario of P2G H2 demand. So a setting of 1 means G2P and GasStorages are not included.
        dtr_settings[:h2] = dtr_settings[:h2_scen]
    else
        dtr_settings[:h2] = missing
    end
    
    dtr_settings[:NewGasAllowed_flag] = run_settings.Flags["NewGasAllowed"]
    dtr_settings[:NewDistillate_flag] = run_settings.Flags["NewDistillate"]
    dtr_settings[:FixExistingCap_flag] = run_settings.Flags["FixExistingCap"]
    
    dtr_settings[:capacity_factor_ae] = run_settings.Parameters["AE_Capacity_Factor"]
    dtr_settings[:capacity_factor_recipH2_ub] = run_settings.Parameters["RecipH2_Capacity_Factor_UB"]
    dtr_settings[:lifetime_recipH2] = run_settings.Parameters["RecipH2_Timing"]
    
    dtr_settings[:loss_factor_tx] = run_settings.Parameters["Tx_Loss_Factor"]
    dtr_settings[:lifetime_Tx] = run_settings.Parameters["Tx_Lifetime"]
    dtr_settings[:scaling_Tx] = run_settings.Parameters["Tx_Cost_Scaling"]
    dtr_settings[:tx_exp_upper_bound] = run_settings.Parameters["Tx_Exp_UB_Factor"]
    
    dtr_settings[:cost_syncon] = run_settings.Parameters["SynCon_CapCost"]
    dtr_settings[:lifetime_syncon] = run_settings.Parameters["SynCon_Lifetime"]

    dtr_settings[:capacity_syncon_SA] = run_settings.Parameters["SynCon_SA_Capacity"]
    dtr_settings[:timing_syncon_SA] = run_settings.Parameters["SynCon_SA_Timing"]
    
    dtr_settings[:timing_central_west] = run_settings.Parameters["Central_West_Timing"]

    # # Legacy:
    # dtr_settings[:coal_adjust] = 1;
    # dtr_settings[:peak_factor] = 2.5;
    # dtr_settings[:carbon_budget] = 1000*CarbonBudgetDict[ScenarioName,ScenarioYear]

    return dtr_settings
end

# Functions to construct STABLE configuration data structures:

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
                scen_dc["HydrogenScenario"],
                scen_dc["TxScenario"]
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

        if !isempty(inst_dc["InstanceYears"])
            CreateYears = inst_dc["InstanceYears"]
        else
            start_year = inst_dc["InstancesStart"]
            end_year = inst_dc["InstancesEnd"]
            year_step = inst_dc["InstancesStep"]
            CreateYears = collect((start_year):(year_step):(end_year))
        end
            
        for year in CreateYears
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

function InitRunSettings(runsettings_input_dc::OrderedDict)
    RunSettingsDict = OrderedDict{String,STABLErunSettings}()
    for k in keys(runsettings_input_dc)
        runsettings_dc = runsettings_input_dc[k]
        RunSettingsDict[k] = 
            STABLErunSettings(
                String(k),   # RunSettingsIdentifier
                runsettings_dc["Flags"],
                runsettings_dc["Parameters"]
            )
    end
    return RunSettingsDict
end
