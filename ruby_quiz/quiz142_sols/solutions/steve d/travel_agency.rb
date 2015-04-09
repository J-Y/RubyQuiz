require 'grid'
require 'trip'

$LOAD_PATH << "./ruby-svg-1.0.3/lib"
require 'svg/svg'

class Range
  def rand
    Kernel.rand(self.end - self.begin) + self.begin
  end
end

class TravelAgency
  class << self
    def generate_trip(grid_size, generations)
      evolutions = []
      cnt = 0

      grid = Grid.new(grid_size)

      puts "generating trip on grid of size #{grid_size} using #{generations} generations"
      puts "shortest possible trip is: #{grid.min}"

      agency = TravelAgency.new(grid)
      shortest_trip = agency.shortest_trip(:generations => generations, :callback_proc => proc do |trip|
        evolutions << trip
        puts "generation #{(cnt += 1).to_s.ljust(4)} distance: #{trip.distance}"
      end)

      puts "inefficiency in trip: #{1.0 * (shortest_trip.distance - grid.min) / grid.min}"

      puts "creating svg animation of evolutions: trips.svg"
      File.open("trips.svg", "w") {|f| f.write agency.draw_svg(evolutions) }
    end
  end

  def initialize(grid)
    @grid = grid
  end

  def shortest_trip(options = {})
    callback_proc = options[:callback_proc]

    survived_variations = [@grid.points + [@grid.points.first]]
    callback_proc[Trip.new(survived_variations.first)]  if callback_proc

    (options[:generations] || 100).times do |generations|
      offspring_variations = survived_variations.dup

      30.times do
        survived_variations.each do |points|
          offspring_variations << exchange(points)
          offspring_variations << reverse(points)
        end
      end

      survived_variations = select(offspring_variations)

      callback_proc[Trip.new(survived_variations.first)]  if callback_proc 
    end

    Trip.new survived_variations.first
  end

  private

  def select(variations)
    ranked_by_dist = variations.sort_by {|pts| Trip.new(pts).distance }
    
    ranked_by_dist[0..15] + ranked_by_dist[-5..-1]
  end

  def exchange(points)
    split1 = (1..points.size-3).rand
    split2 = (split1+1..points.size-2).rand
    split3 = (split2+1..points.size-1).rand

    points[0..split1] + points[split1+1..split2] + points[split2+1..split3] + points[split3+1..-1]
  end

  def reverse(points)
    split1 = (1..points.size-2).rand
    split2 = (split1+1..points.size-1).rand

    points[0..split1] + points[split1+1..split2].reverse + points[split2+1..-1]
  end

  public

  def draw_svg(trips)
    scale = 10
    offset = 10
    adjust = proc {|n| n * scale + offset }

    size = adjust[@grid.n]

    svg = SVG.new('7in', '7in', "0 0 #{size} #{size}")

    animation_script = "";
    id = "g000"
    time = 0
    trips.each_with_index do |trip, iteration|
      group = SVG::Group.new do
        self.id = id.succ!.dup
        self.style = SVG::Style.new(:display => 'none')
      end

      animation_script << %Q{
        setTimeout(function(){ document.getElementById("#{group.id}").style.display = "block" }, #{time});
        setTimeout(function(){ document.getElementById("#{group.id}").style.display = "none" }, #{time += 100});
      }

      @grid.points.each do |point|
        group << SVG::Circle.new(adjust[point.x], adjust[point.y], 1) do
          self.style = SVG::Style.new(:fill => 'black')
        end
      end

      polyline_points = trip.points.inject([]) {|pts_array, pt| pts_array + [adjust[pt.x], adjust[pt.y]] }
      group << SVG::Polyline.new(SVG::Point[*polyline_points]) do
        self.style = SVG::Style.new(:fill => 'none', :stroke => 'red', :stroke_width => '0.5')
      end

      group << SVG::Text.new(5, 7, "iteration: #{iteration.to_s.rjust(4)}") do
        self.style = SVG::Style.new('font-size' => '4pt')
      end

      svg << group
    end

    animation_script << %Q{setTimeout(function(){ document.getElementById("#{id}").style.display = "block" }, #{time});}
    svg.scripts << SVG::ECMAScript.new(%Q{
      function animate() { #{animation_script} }
      window.onload = function() { setTimeout(animate, 1000); }
    })

    svg.to_s.gsub(%r{<svg}, '<svg xmlns:svg="http://www.w3.org/2000/svg" xmlns="http://www.w3.org/2000/svg"')
  end
end

if __FILE__ == $0
  grid_size = ARGV[0].to_i
  generations = ARGV[1].to_i

  TravelAgency.generate_trip(grid_size, generations)
end