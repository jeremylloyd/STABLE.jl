
## %% Global Settings Structure (to be set by modeller)

mutable struct STABLEglobalSettings
      Hours::Integer       # The number of hours.
      Timestep::Integer    # Time interval size as multiple of 30 minutes.
      DiscountRate::Float64    # The annual interest rate used to compute the net present value.
      # ReferenceYear::Integer # Year of data set to use for renewable traces
      CostScaling::Float64 
end

## %% Scenario Structure

mutable struct STABLEscenario
      ScenarioSettings::STABLEglobalSettings
      ScenarioIdentifier::String
      ScenarioName::String
      ScenarioNumber::Integer     # Number identifier for data input/lookup.
      WeatherYear::Integer        # Historical year as basis for renewable traces
      TraceYear::Integer          # Which year to use from the ReferenceYear trace dataset
      MinimumRenewShare::Integer  # Default floor value on the minimum yearly renewables requirement for all regions.
      TechCostScenario::String    # Scenario identifier for the technology cost data
      FuelCostScenario::String    # Scenario identifier for the fuel cost data
      VPPbatteryScenario          # Scenario identifier for the virtual power plant battery uptake data.
      HydrogenScenario            # Scenario identifier for hydrogen uptake.
end

## %% Instance Structure

mutable struct STABLEinstance
      InstanceScenario::STABLEscenario
      InstanceIdentifier::String
      InstanceYear::Integer # The year (projected or historical) to simulate within the given Scenario.
end
# e.g # STinst.Flags["FixExistingCapFlag"] = true, NoNewGas, NoNewDistillate

## %% Run Settings Structure for specific configuration of runs

mutable struct STABLErunSettings
      RunSettingsIdentifier::String # 
      Flags::OrderedDict{String,Bool}  #
      Parameters::OrderedDict{String,Any}
end

# Transmission parameters:
# SynCon_CapCost::Float64  # Cost of synchronous condenser with flywheel
# SynCon_Lifetime::Integer # Synchronous condenser plant economic lifetime
# Tx_Lifetime::Integer       # Transmission economic lifetime
# Tx_Cost_Scaling::Float64   # Transmission cost scaling factor
# Tx_Exp_UB_Factor::Float64   # Factor for setting upper bound on size of transmission expansion as multiple of existing capacity

# Expected Flags:
#   Flag H2::Bool  # :h2 - include H2 technology constraints if true.
#   Flag EV::Bool  # :ev - include EV technology constraints if true.
#   Flag HeatLoads::Bool # :heat - include Building Heat Load constraints if true.
#   Flag NewGasAllowed::Bool   # NoNewGas -  New gas technology built if true.
#   Flag NewDistillate::Bool   # NoNewDistillate - New liquid distillate technology built if true.
#   Flag FixExistingCap::Bool  # FixExistingCapFlag - Fix the variables for existing capacity to the given values if true

# Run Structure

mutable struct STABLErun
      RunInstance::STABLEinstance
      RunSettings::STABLErunSettings
      RunIdentifier::String
      RunTimestampStart::String  # run_timestamp
      RunTimestampFinish::String 
      RunStatus::String
      RunNote::String    # A text annotation in order to aid identification of runs
      ResultsIdentifier::String  # Identifier for Results (e.g. filenames)
      ResultsPath::String        # The path to directory where Results will be written - resultsdir
end
# Construct from STrun::STABLErun the RunDescriptor::String # scenario_timestamp

# Examples of Tests:
# @assert STBL_scen.ScenarioName in Allowed_Scenarios
# @assert ScenarioName in Allowed_Scenarios

