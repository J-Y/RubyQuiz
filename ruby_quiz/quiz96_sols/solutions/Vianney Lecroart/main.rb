class Array
  def rnd_elem
    at(rand(size)) unless empty?
  end
end

class Employee
  
  def Employee.generate_name
    first_name = ["Mary", "Patricia", "Linda", "Sharon", "Lisa", "Carol", "Karen", "Jessica"]
    last_name = ["Doe", "Jobs", "Wills", "Smith", "Jonhson", "Wiliams", "Jones", "Brown", "Davis", "Miller" , "Martin", "Thomas", "Moore" ]
    "#{first_name.rnd_elem} #{last_name.rnd_elem}"
  end

  def initialize
    @level = rand(5)
    @name = Employee.generate_name
  end
  
  def  to_s
     ["Clueless", "Noob", "Average", "Skilled", "Cowboy"].at(@level) + " #{name} #{@name}"
  end

end

class Manager < Employee
  def name
    "manager"
  end
end

class Coder < Employee

  def name
    "coder"
  end
  
  def iterate(project)
    res = methods.find_all { |m| m[0,5] == "work_" }.rnd_elem
    puts "#{self} #{method(res).call(project)} on #{project}"
  end
  
  def work_feature(project)
    project.nb_features += 1
    "adds a feature" + add_bug(project)
  end
  
  def work_find_bug(project)
    bug = project.bugs.rnd_elem
    if !bug
      work_feature(project)
    else
      fix_level = rand(@level)
      if fix_level >= bug.complexity
        "manages to fix #{bug}"
        project.bugs.delete bug
      else
        "attempts to fix #{bug} and fails"
      end
    end
  end
  
  def add_bug(project)
    comp = rand(5)
    if comp > @level
      project.bugs << Bug.new(comp)
      project.nb_bugs +=1
      " and adds #{project.bugs.last}"
    else
      ""
    end
  end
  
end

class Bug
  attr_reader :complexity
  attr_reader :bid

  @@sbid = 1

  def to_s
    "the "+["very simple", "simple", "average", "hard", "hardcore"].at(complexity)+" bug "+bid.to_s
  end

  def initialize(complexity)
    @complexity = complexity
    @bid = @@sbid
    @@sbid += 1
  end
end

class Project
  
  attr_accessor :bugs
  attr_accessor :nb_bugs
  attr_accessor :nb_features
  
  def initialize(name = nil)
    @name = if name then name else Project.generate_name end
    @bugs = Array.new
    @nb_bugs = 0
    @nb_features = 0
  end
  
  def Project.generate_name
    adj = ["Super", "Mega", "Turbo", "Ultimate"]
    noun = ["Racer", "Fighter", "Puzzle", "Adventure"]
    compl = ["of Doom", "from Hell", "Deluxe", "Unlimited"]
    "#{adj.rnd_elem} #{noun.rnd_elem} #{compl.rnd_elem}"
  end
  
  def to_s
    "the #{@name} project"
  end
  
  def summarize
    "Summary: Project #{@name} has #{@nb_features} features and #{@bugs.size} bugs left out of #{@nb_bugs}"
  end
end

class Company
  
  attr_accessor :projects

  def recruit(employee)
    @employees << employee.new
  end

  def initialize()
    @employees = Array.new
    @projects = Array.new
  end

  def employees(type = nil)
    @employees.find_all { |e| !type or e.kind_of? type }
  end

  def random_employee(type = nil)
    subset = employees(type)
    subset[rand(subset.size)]
  end
  
  def summarize
    status = ["ships!", "is cancelled!"].rnd_elem
    puts "**************************"
    @projects.each { |p| puts "#{p.summarize} #{status}" }
  end
end

####################################

puts "** Game Company Simulator **"

company = Company.new

3.times do company.projects << Project.new end

10.times do company.recruit(Coder) end

10.times do company.employees(Coder).each {|e| e.iterate(company.projects.rnd_elem)} end

company.summarize

puts "** Company goes bankrupt **"