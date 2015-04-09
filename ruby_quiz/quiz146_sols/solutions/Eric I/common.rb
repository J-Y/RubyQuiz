# This is a solution to Ruby Quiz #146 (see http://www.rubyquiz.com/)
# by LearnRuby.com and released under the Creative Commons
# Attribution-Share Alike 3.0 United States License.  This source code can
# also be found at:
#   http://learnruby.com/examples/ruby-quiz-146.shtml

# This file contains some constants used by both the traffic_analyzer
# and traffic_grapher.

MillisecondsPerSecond = 1000
MillisecondsPerMinute = MillisecondsPerSecond * 60
MillisecondsPerHour = MillisecondsPerMinute * 60
MillisecondsPerDay = MillisecondsPerHour * 24

AverageWheelBase = 100  # in inches
AverageCarLength = 175  # in inches

InchesPerMillisecondToMilesPerHour = 1/12.0 * 1/5280.0 * 1000 * 60 * 60

# when divided by milliseconds and assuming wheels 100 inches apart,
# gives approximate speed in mph
SpeedFactor = AverageWheelBase * InchesPerMillisecondToMilesPerHour

SameTiresLimit = 10  # max. number of milliseconds for one tire hitting A & B
