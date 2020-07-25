module STABLE

## %% Load packages
using Dieter
import Dieter: parse_file, parse_nodes!, parse_base_technologies!, parse_storages!, parse_load!, parse_availibility!
import Dieter: initialise_set_relation_data!, parse_set_relations!,parse_arcs!, calc_base_parameters!, parse_extensions!
import Dieter: dvalmatch, dkeymatch, split_df_tuple

using JuMP
# import MathOptInterface
# import CPLEX

using DataFrames
using DataFramesMeta
import DBInterface
import SQLite
import CSV
import TimeSeries
import Dates
import Serialization
# using Tables
# import XLSX

import OrderedCollections: OrderedDict

include("structures.jl")
include("util.jl")
include("datamodels.jl")

end
