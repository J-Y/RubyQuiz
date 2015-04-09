class Array
  def random
    self[ rand( self.length ) ]
  end
end

class String
  def variation( values={} )
    out = self.dup
    while out.gsub!( /\(([^())?]+)\)(\?)?/ ){
      ( $2 && ( rand > 0.5 ) ) ? '' : $1.split( '|' ).random
    }; end
    out.gsub!( /:(#{values.keys.join('|')})\b/ ){ values[$1.intern] }
    out.gsub!( /\s{2,}/, ' ' )
    out
  end
end
