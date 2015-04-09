class SerializableProc

  def initialize( block )
    @block = block
    # Test if block is valid.
    to_proc
  end

  def to_proc
    # Raises exception if block isn't valid, e.g. SyntaxError.
    eval "Proc.new{ #{@block} }"
  end

  def method_missing( *args )
    to_proc.send( *args )
  end

end


if $0 == __FILE__

  require 'yaml'
  require 'pstore'

  code = SerializableProc.new %q{ |a,b| [b,a] }

  # Marshal
  File.open('proc.marshalled', 'w') { |file| Marshal.dump(code, file) }
  code = File.open('proc.marshalled') { |file| Marshal.load(file) }

  p code.call( 1, 2 )

  # PStore
  store = PStore.new('proc.pstore')
  store.transaction do
    store['proc'] = code
  end
  store.transaction do
    code = store['proc']
  end

  p code.call( 1, 2 )

  # YAML
  File.open('proc.yaml', 'w') { |file| YAML.dump(code, file) }
  code = File.open('proc.yaml') { |file| YAML.load(file) }

  p code.call( 1, 2 )

  p code.arity

end
