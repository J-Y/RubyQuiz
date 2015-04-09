require 'r2c_hacks'

class ProcStore # We have to have this because yaml calls allocate on Proc
  def initialize(&proc)
    @p = proc.to_ruby
  end

  def call(*args)
    eval(@p).call(*args)
  end
end
