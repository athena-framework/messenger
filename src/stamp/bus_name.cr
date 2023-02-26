require "./non_sendable_interface"
require "./stamp"

record Athena::Messenger::Stamp::BusName < Athena::Messenger::Stamp, bus_name : String
