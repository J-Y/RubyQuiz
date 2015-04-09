require 'strscan'

class Regexp
  # Create a list of all values matching the regex.
  # Currently only supports groupings and '|'
  def generate
    regex = self.inspect
    regex = regex.slice(1, regex.size - 2) # Remove leading/trailing '/''
    s = StringScanner.new(regex)

    # Build a list containing each grouping, and blocks in between
    groups = []
    result = ''
    while (result = s.scan_until(/\(|\)/)) != nil
      result = result.sub("(", "") # Does not support '\' escape chars

      if result.size > 0
        if result[-1].chr == ")"
          groups << result.split("|")
          groups[-1][-1] = groups[-1][-1].sub(")", "")
        else
          groups << [result]
        end
      end
    end

    # Create all combinations of those groups and return them
    find_list_combinations(groups)
  end

  # Return an array of all combinations of values in given list of lists
  def find_list_combinations(lists)
    lists.reverse!
    results = lists.pop
    list = lists.pop

    while list != nil
      new_results = []
      for result in results
        for item in list
          new_result = Array.new([result])
          new_result << item
          new_results << new_result
        end
      end

      results = new_results
      list = lists.pop
    end

    new_results.map{|list| list.flatten.join }
  end
end
