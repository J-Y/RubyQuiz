$CheerThreshold = 6   #decrease to get more random encouragement
$LongThreshold = 120  #minimum time to be considered a "long" run

class SpeechSynth
	def initialize
		@known = ["minutes left in this phase",
										"you are done, rest now.",
										"until the next activity",
										"OK, you can walk now",
										"seconds more to walk",
										"seconds more to run",
										"to go and there are",
										"OK, you can run now",
										"You are almost done",
										"are you ready, go!",
										"get ready to walk",
										"get ready to run",
										"short run left",
										"in this phase",
										"to exercise",
										"Keep it up!",
										"to exersize",
										"Way to go!",
										"of walking",
										"short runs",
										"minute and",
										"There are",
										"Good job!",
										"long runs",
										"of runing",
										"You have",
										"walk for",
										"long run",
										"minutes",
										"seconds",
										"to walk",
										"run for",
										"to run",
										"walks",
										"left",
										"only",
										"more",
										"for",
										"and",
										"60",
										"30",
										"15",
										"18",
										"55",
										"7",
										"6",
										"5",
										"9",
										"3",
										"2",
										"1",
										"8",
										"4"]
	end
	
	def playFile(fileName)
		puts "PLAY: '" +fileName + "'"
		#on linux this can be:
		#`play #{filename}`
	end
	
	def known(searchPhrase)
		@known.each do |phrase|
			return $~[1] if searchPhrase =~ /^(#{phrase}).*/i
		end
		puts "UNKNOWN PHRASE: #{searchPhrase}"
		return nil
	end
	
	def say(sentence)
		while sentence.length > 0	
			knownPhrase = known(sentence)
			if knownPhrase
				playFile(knownPhrase + ".ogg")
				sentence = sentence[knownPhrase.length+1..-1]
				sentence = "" if !sentence
			else
				sentence = ""
			end
			sentence.strip!
		end
	end
end

class Phase
attr_reader :action, :seconds
def initialize action, time
  @action = action.downcase
  @seconds = time.to_i
end
end

class Coach
def initialize filename
	 @synth = SpeechSynth.new
  File.open(filename) {|f|
    @rawdata = f.read.split("\n")
  }
  @duration = 0
  @runs = @longs = @walks = 0
  @encouragometer = 0
  @step = [30,15,10,5,5]
end

def coach
  build_timeline
  say summarize(2)
  say start_prompt
  @time = Time.now
  @target_time = @time
  while (phase = @phases.shift)
    update_summary phase
    narrate_phase phase
    if @phases.size > 0
      say transition(@phases[0].action)
      say summarize(rand(2))
    end
  end
  say finish_line
end

def narrate_phase phase
  say what_to_do_for(phase)
  @target_time += phase.seconds
  delta = (@target_time - Time.now).to_i
  stepidx = 0
  while (delta > 0)
    stepidx+=1 if delta < @step[stepidx]+1
    wait_time = delta%@step[stepidx]
    wait_time += @step[stepidx] if wait_time <= 0
    wait(wait_time)
    delta = (@target_time - Time.now).to_i
    encourage_maybe
    say whats_left(phase.action,delta) if delta > 0
  end
end

def update_summary phase
  @duration -= phase.seconds
  @runs -= 1 if phase.action == 'run'
  @longs -= 1 if phase.action == 'run' and phase.seconds >= $LongThreshold
  @walks -= 1 if phase.action == 'walk'
end


def build_timeline
  @phases = @rawdata.map {|command|
    p = Phase.new(*command.split)
    @duration += p.seconds
    @runs += 1 if p.action == 'run'
    @longs += 1 if p.action == 'run' and p.seconds >= $LongThreshold
    @walks += 1 if p.action == 'walk'
    p
  }
end

def say s
  @synth.say(s)
end

def wait n
  if $DEBUG
    puts "...waiting #{n} seconds..."
    @target_time -= n
  else
    $stdout.flush
    sleep(n)
  end
end

def encourage_maybe
  @encouragometer += rand(3)
  if (@encouragometer > $CheerThreshold)
    say cheer
    @encouragometer = 0
  end
end

def timesay secs
  secs = secs.to_i
  s = ""
  if secs > 60
    min = secs/60
    secs -= min*60
    s += "#{min} minute"
    s += 's' if min > 1
    s += ' and ' if secs > 0
  end
  if secs > 0
    s += "#{secs} second"
    s += 's' if secs > 1
  end
  s
end

# All the phrases should be below this line, not mixed up in the logic
def what_to_do_for phase
  s = "#{phase.action} for #{timesay(phase.seconds)} \n"
  #s += "You are almost done" if @phases.size == 1
  s
end
def whats_left act, time
  timestr = timesay(time)
  s = [
    "You have #{timestr} more to #{act}",
    "#{act} for #{timestr} more",
    "only #{timestr} left of #{act}ing",
    "You have #{timestr} more to #{act}",
    "#{timestr} left in this phase",
    "There are #{timestr} until the next activity"
  ]
  s[rand(s.size)]
end
def start_prompt
  "are you ready, go!"
end
def transition next_act
  s = ["OK, you can #{next_act} now",
       "get ready to #{next_act}"]
  s[rand(s.size)]
end
def finish_line
  "you are done, rest now."
end
def cheer
  c = ["Keep it up!", "Way to go!", "Good Job!"]
  c[rand(c.size)]
end
def summarize degree
  shorts = @runs - @longs
  s = "you have #{timesay(@duration)}"
  if degree > 0
    if degree > 1
      s+= " for "
    else
      s+= " to go and there are " if @runs > 0
    end
    s+="#{@longs} long run" if @longs > 0
    s+="s" if @longs > 1
    s+=" and" if @longs > 0 and shorts > 0 and degree <=1
    s+=" #{shorts} short run" if shorts > 0
    s+="s" if shorts > 1
    if degree >1
      s+=" and" if @longs+shorts > 0
      s+=" #{@walks} walk" if @walks > 0
      s+="s" if @walks > 1
    else
      s+=" left"
    end
  else
    s+= " left to exercise"
  end
  s
end
end

Coach.new(ARGV[0]||"week3.txt").coach
