
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
      TGScenarioIdentifier::String    # Bridge to pre-populated scenarios.
      TGScenarioNumber::String        # Bridge to pre-populated scenarios.
      WeatherYear::Integer        # Historical year as basis for renewable traces
      TraceYear::Integer          # Which year to use from the ReferenceYear trace dataset
      BatteryImproveYear::Integer # Projected year of improved battery response speed
      # GridFollowFraction::Float64 # Fraction of installed renewables that have grid following inverters in BatteryImproveYear
      MinimumRenewShare::Integer  # Default value on the minimum yearly renewables requirement for the whole of system.
      TechCostScenario::String    # Scenario identifier for the technology cost data
      FuelCostScenario::String    # Scenario identifier for the fuel cost data
      VPPbatteryScenario          # Scenario identifier for the virtual power plant battery uptake data.
      HydrogenScenario            # Scenario identifier for hydrogen uptake.
      HydrogenGasPeaker::Integer  # Scenario identifier for allowing hydrogen gas peaking plant.
      FixExistingCap::Bool        # Flag to indicate whether to fix the variables for existing capacity to the given values if true.
      NewGasAllowed::Bool         # Flag to indicate whether new gas plant capacity is built if true.
      NewDistillateAllowed::Bool  # Flag to indicate whether new liquid distillate technology capacity is built if true.
      NoNewFossilFuelsYear::Integer # Projected year at which no new fossil-fuel technologies are built.
      TxScenario::Array{String}   # List of committed transmission upgrades.
end

## %% Instance Structure

mutable struct STABLEinstance
      InstanceScenario::STABLEscenario
      InstanceIdentifier::String
      InstanceYear::Integer # The year (projected or historical) to simulate within the given Scenario.
end
# e.g # STinst.Flags["FixExistingCapFlag"] = true, NoNewGas, NoNewDistillateAllowed

## %% Run Settings Structure for specific configuration of runs

mutable struct STABLErunSettings
      RunSettingsIdentifier::String # 
      Flags::OrderedDict{String,Bool}  #
      Parameters::OrderedDict{String,Any}
end

## Transmission parameters:
# Tx_Loss_Factor::Float64  # Transmission loss factor multiplier on demand e.g. 1.06 represents 6% losses. 
# Tx_Lifetime::Integer       # Transmission economic lifetime. Units: years
# Tx_Cost_Scaling::Float64   # Transmission cost scaling factor
# Tx_Exp_UB_Factor::Float64   # Factor for setting upper bound on size of transmission expansion as multiple of existing capacity
## Synchronous condensers parameters:
# SynCon_Parameters: Lifetime::Integer # Synchronous condenser plant economic lifetime. Units: years
# SynCon_Parameters: CapCost::Float64  # Cost of synchronous condenser type. Units: $/MW

# Expected Flags:
#   Flag H2::Bool  # :h2 - include H2 technology constraints if true.
#   Flag EV::Bool  # :ev - include EV technology constraints if true.
#   Flag HeatLoads::Bool # :heat - include Building Heat Load constraints if true.
#   Flag FixExistingCap::Bool  # FixExistingCapFlag - Fix the variables for existing capacity to the given values if true
#   Flag NewGasAllowed::Bool   # NoNewGas -  New gas technology built if true.
#   Flag NewDistillateAllowed::Bool   # NoNewDistillateAllowed - New liquid distillate technology built if true.

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

