#!/usr/local/bin/ruby -w

require "yaml"

data =
{ "Workers"  => { "Brian" => { "Mon" => "any (prefers 8 AM to 5 PM)",
                               "Tue" => "any (prefers 8 AM to 5 PM)",
                               "Wed" => "not available",
                               "Thu" => "any (prefers 8 AM to 5 PM)",
                               "Fri" => "any (prefers 8 AM to 5 PM)",
                               "Sat" => "any",
                               "Sun" => "after 1 PM" },
                  "James" => { "Mon" => "before 3 PM (prefers before 12 PM)",
                               "Tue" => "any",
                               "Wed" => "any",
                               "Thu" => "12 PM to 3 PM",
                               "Fri" => "12 PM to 3 PM",
                               "Sat" => "not available",
                               "Sun" => "any (prefers before 5 PM)" } },
  "Schedule" => { "Mon" => "9 AM to 6 PM",
                  "Tue" => "9 AM to 6 PM",
                  "Wed" => "9 AM to 6 PM",
                  "Thu" => "9 AM to 8 PM",
                  "Fri" => "9 AM to 6 PM",
                  "Sat" => "9 AM to 10 PM",
                  "Sun" => "9 AM to 10 PM" } }.to_yaml
puts data