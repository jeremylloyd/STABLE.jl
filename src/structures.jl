
## %% Global Settings Structure (to be set by modeller)

mutable struct STABLEsettings
      Hours::Integer       # The number of hours.
      Timestep::Integer    # Time interval size as multiple of 30 minutes.
      DiscountRate::Float64    # 
      # ReferenceYear::Integer # Year of data set to use for renewable traces
      CostScaling::Float64 
end

## %% Scenario Structure

mutable struct STABLEscenario
      ScenarioSettings::STABLEsettings
      ScenarioName::String
      ScenarioIdentifier::String
      WeatherYear::Integer # Historical year as basis for renewable traces
      TraceYear::Integer # Which year to use from the ReferenceYear trace dataset
      MinimumRenewShare::Integer
end

## %% Instance Structure

mutable struct STABLEinstance
      InstanceScenario::STABLEscenario
      InstanceYear::Integer
      # ScenarioNumber::Integer
      Flag_H2::Bool  # :h2 - include H2 technology if true.
      Flag_EV::Bool  # :ev - include EV technology if true.
      Flag_HeatLoads::Bool # :heat - include Building Heat Load if true.
      Flag_NewGasAllowed::Bool   # NoNewGas - No new gas technology built if false
      Flag_NewDistillate::Bool   # NoNewDistillate
      Flag_FixExistingCap::Bool  # FixExistingCapFlag
end
# e.g # STinst.Flags["FixExistingCapFlag"] = true, NoNewGas, NoNewDistillate

# Run Structure

mutable struct STABLErun
      RunInstance::STABLEinstance
      RunTimestampStart::String  # run_timestamp
      RunTimestampFinish::String 
      RunStatus::String
      RunNote::String    # A text annotation in order to aid identification of runs
end
# Construct from STrun::STABLErun the RunDescriptor::String # scenario_timestamp

# Examples of Tests:
# @assert STBL_scen.ScenarioName in Allowed_Scenarios
# @assert ScenarioName in Allowed_Scenarios
