class OneLiner
class << self
  def commaize(quiz)
    quiz.to_s.reverse.gsub(/(\d\d\d)(?=\d)(?!\d*\.)/, '\1,').reverse
  end

  def flatten_once(quiz)
    t=[];quiz.each{|x|(Array===x)?x.each{|y|t<<y}:t<<x};t
  end

  def shuffle(quiz)
    quiz.sort{rand(2)}
  end

  def get_class(quiz) #this one was really hard to figure out.
    name.split("::").inject(Object){|klass, name|klass.const_get(name)}
  end

  def wrap_text(quiz)
    quiz.gsub(/(.{1,40})( +|$\n?)|(.{1,40})/, "\\1\\3\n")
  end

  def find_anagrams(quiz)
    t=[];quiz[1..-1].each{|v|(v.scan(/./).sort==quiz[0].scan(/./).sort)?t<<v:nil};t
  end

  def binarize(quiz)
    s='';quiz.split.each{|v|v.each_byte{|x|s<<'%b'%x};s<<"\n"};s
  end

  def random_line(quiz)
    s='';quiz.readlines.each{|v|rand(2)==0?eval('s=v;break'):s=v};s
  end

  def wondrous_sequence(quiz)
    t=[quiz];until quiz==1;t<<(quiz=(quiz%2==0?quiz/2:quiz*3+1));end;t
  end

  def nested_hash(quiz)
    h={};t=h;quiz[0..-3].each{|v|t[v]={};t=t[v]};t.store(quiz[-2],quiz[-1]);h
  end
end
end
