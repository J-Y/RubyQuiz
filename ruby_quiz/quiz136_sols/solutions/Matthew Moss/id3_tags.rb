class ID3

   @@recLen = 0

   def ID3.field(name, len, flags=[])
      class_eval(%Q[
         def #{name}
            @data[#{@@recLen}, #{len}].strip
         end
      ])

      unless flags.include?(:readonly)
         class_eval(%Q[
            def #{name}=(val)
               # need to pad val to len
               @data[#{@@recLen}, #{len}] = val.ljust(#{len}, "\000")
            end
         ])
      end
      @@recLen += len
   end

   # --------------------------------------------------------------
   #     name, length,       flags
   field :sig,      3,  [:readonly]
   field :song,    30
   field :album,   30
   field :artist,  30
   field :year,     4
   field :comment, 30
   field :genre,    1

   TAG_SIG  = "TAG"
   TAG_SIZE = @@recLen
   raise "ID3 tag size not 128!" unless TAG_SIZE == 128

   # --------------------------------------------------------------

   def ID3.createFromBuffer(buffer)
      ID3.new(buffer)
   end

   def ID3.createFromFile(fname)
      size = File.size?(fname)
      raise "Missing or empty file" unless size
      raise "Invalid file" if size < TAG_SIZE

      # Read the tag and pass to createFromBuffer
      open(fname, "rb") do |f|
         f.seek(-TAG_SIZE, IO::SEEK_END)
         createFromBuffer(f.read(TAG_SIZE))
      end
   end

   # --------------------------------------------------------------

   def initialize(data)
      @data = data

      raise "Wrong buffer size" unless @data.size == TAG_SIZE
      raise "ID3 tag not found" unless self.sig == TAG_SIG
   end

end


id = ID3.createFromFile("maple-leaf-rag.mp3")
puts id.song
