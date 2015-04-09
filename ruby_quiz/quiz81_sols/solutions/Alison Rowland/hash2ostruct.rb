require 'yaml'
require 'ostruct'
require 'rubygems'
require 'facet/hash/to_ostruct_recurse'

ostruct = YAML.load(File.open("example.yaml")).to_ostruct_recurse
