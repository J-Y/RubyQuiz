# This is a solution to Ruby Quiz #146 (see http://www.rubyquiz.com/)
# by LearnRuby.com and released under the Creative Commons
# Attribution-Share Alike 3.0 United States License.  This source code can
# also be found at:
#   http://learnruby.com/examples/ruby-quiz-146.shtml

# This file creates a domain-specific language to allow easy graphing
# using the scruffy graphing library.

require 'rubygems'
require 'enumerator'
require 'common'

# use the scruffy gem or use my own modified version?
$LOAD_PATH << 'scruffy-0.2.2/lib' if false
require 'scruffy'

#
# This code helps figure out how to what to set the maximum value on
# the vertical scale and how many divisions to make.
#

Log10 = Math.log(10)  # since it's used so often, make it a constant
Bin_Label_Limit = 10

$maxes = [
  [1.25, 6], [1.5, 6], [2, 5], [2.5, 6], [3, 7], [4, 5], [5, 6],
  [6, 7], [7.5, 6], [8, 5], [10, 6]]
  
$maxes.map! { |v, s| [Math.log(v) / Log10, s] }

# Given a maximum graphed value returns a two-element array, with the
# first element being the maximum value on the vertical scale and the
# second element being the number of divisions the vertical axis
# should be diveded into
def graph_max(max, logorithmic = false)
  if logorithmic
    [max.ceil, max.ceil + 1]
  else
    log_10 = Math.log(max) / Log10
    log_10_full = log_10.to_i
    log_10_frac = log_10 - log_10_full

    if log_10_frac == 0.0
      [(10 ** log_10).round, 5]
    else
      max_log, steps = $maxes.find { |log, steps| log_10_frac <= log }
      [(10 ** (log_10_full + max_log)).round, steps]
    end
  end
end

class LogorithmicFormatter < Scruffy::Formatters::Base
  def format(target, idx, options)
    (10 ** target).round
  end
end

########################################

module Grapher

  # @@filters = @@series = @@bins = @@combiner = nil

  def graph(name, records, filename = nil)
    @@filters = []
    @@series = []
    @@bins = nil
    @@combiner = nil
    yield
    render(name, records, filename)
  end
  
  def filter(filter)
    @@filters << filter
  end

  def series(series)
    if series.kind_of? Array
      @@series += series
    else
      @@series << series
    end
  end

  def bins(bins)
    raise "cannot set bins twice" unless @@bins.nil?
    @@bins = bins
  end
    
  def combiner(combiner)
    raise "cannot set combiner twice" unless @@combiner.nil?
    @@combiner = combiner
  end

  def render(name, records, filename)
    filename ||= name + '.png'

    graph = Scruffy::Graph.new(:title => name)

    @@filters.each do |filter|
      records = records.select(&filter.block)
    end

    zero_filler = Array.new(@@bins.size, 0)
    empty_filler = Array.new(@@bins.size, '')
    data_collector = []

    @@series.each_with_index do |a_series, i|
      series_records = records.select(&a_series.block)

      data = @@bins.map do |bin|
        bin_records = series_records.select(&bin.block)
        @@combiner.call(bin_records)
      end

      series_filler = Array.new(@@series.size, zero_filler)
      series_filler[i] = data

      graph.add(:bar, a_series.name, series_filler.transpose.flatten)

      data_collector << data  # keep track of all data, so graph vertical
    end

    bin_labels = @@bins.map { |bin| bin.name }
    if bin_labels.size > Bin_Label_Limit
      modulus = (bin_labels.size / Bin_Label_Limit.to_f).round
      (0...bin_labels.size).each do |i|
        bin_labels[i] = '' unless i % modulus == 0
      end
    end
    bin_filler = Array.new(@@series.size, empty_filler)
    bin_filler[(@@series.size - 1) / 2] = bin_labels

    graph.point_markers = bin_filler.transpose.flatten

    max = graph_max(data_collector.flatten.max, false)
      
    graph.render(:width => 1500,
                 :min_value => 0,
                 :max_value => max[0],
                 :markers => max[1],
                 :to => filename,
                 :as => 'PNG')

    puts "wrote %s" % filename
  end
end


# A filter is just a name and a block of code that returns true when
# something passes through the filter and false when it does not
class Filter
  attr_reader :name, :block

  def initialize(name, &block)
    @name = name
    @block = block
  end
end


# A value filter is a filter that checks a field within a record
# against a single value or a range of values, using the === operator.
class ValueFilter < Filter
  def initialize(name, range, field)
    super(name) { |record| range === record.send(field) }
  end
end


# Some starting filters and sequences
NoFilter = Filter.new('') { true }
OneSequence = [NoFilter]


# include the Grapher module in any file that requires it to make the
# domain specific language active there
include Grapher
