module SqlDsl
   CT_DEFAULTS = {
       :type => 'MyISAM',
       :auto_increment => true,
       :auto_increment_value => 3,
       :auto_id => true
   }

   def ct( name, attributes={} )
       a = CT_DEFAULTS.merge(attributes)
       "CREATE TABLE `#{name}` (\n" +
       "#{"  `id` int(11) NOT NULL auto_increment,\n" if a[:auto_id]}" +
       (( a[:auto_id] ) ? yield : yield.sub( /,\n$/, "\n" ) ) +
       "#{"  PRIMARY KEY (`id`)\n" if a[:auto_id]}" +
       ") TYPE=#{a[:type]} #{"AUTO_INCREMENT=#{a[:auto_increment_value]}" if a[:auto_increment]} ;\n\n"
   end

   VC_DEFAULTS = {
       :size => 50,
       :null_allowed => false,
       :default => true,
       :default_value => ''
   }

   def vc( name, attributes={} )
       a = VC_DEFAULTS.merge(attributes)
       "  `#{name}` varchar(#{a[:size]}) " + not_null(a) + default(a) + ",\n"
   end

   TEXT_DEFAULTS = {
       :null_allowed => false
   }

   def text( name, attributes={} )
       a = TEXT_DEFAULTS.merge(attributes)
       "  `#{name}` text " + not_null(a) + ",\n"
   end

   ID_DEFAULTS = {
       :size => 11,
       :null_allowed => false,
       :default => true,
       :default_value => '0'
   }

   def id( name, attributes={} )
       a = ID_DEFAULTS.merge(attributes)
       "  `#{name}` int(#{a[:size]}) " + not_null(a) + default(a) + ",\n"
   end

   DATE_DEFAULTS = {
       :null_allowed => false,
       :default => true,
       :default_value => '0000-00-00'
   }

   def date( name, attributes={} )
       a = DATE_DEFAULTS.merge(attributes)
       "  `#{name}` date " + not_null(a) +  default(a) + ",\n"
   end

   def pk( name )
       "  PRIMARY KEY (`#{name}`),\n"
   end
     def key( name, value )
       "  KEY `#{name}` (`#{value}`),\n"
   end
     def not_null( a )
       "#{" NOT NULL" unless a[:null_allowed]}"
   end
     def default( a )
       "#{" default '#{a[:default_value]}'" if a[:default]}"
   end
     def auto_increment( a )
       "#{" auto_increment" if a[:auto_increment]}"
   end
end

include SqlDsl

print ct( 'authors' ) {
   vc( 'firstname' ) +
   vc( 'name' ) +
   vc( 'nickname' ) +
   vc( 'contact' ) +
   vc( 'password' ) +
   text( 'description' )
} +
ct( 'categories' ) {
   vc( 'name', :size=>20 ) +
   vc( 'description', :size=>70 )
} +
ct( 'categories_documents', :auto_id=>false, :primary_key=>false, :auto_increment=>false ) {
   id( 'category_id' ) +
   id( 'document_id' )
} +
ct( 'documents', :auto_id=>false, :auto_increment_value=>14 ) {
   id( 'id', :auto_increment=>true, :default=>false ) +
   vc( 'title' ) +
   text( 'description' ) +
   id( 'author_id' ) +
   date( 'date' ) +
   vc( 'filename' ) +
   pk( 'id' ) +
   key( 'document', 'title' )
}
