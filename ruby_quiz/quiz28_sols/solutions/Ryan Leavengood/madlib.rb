def do_madlib(madlib_file, output_pdf, underline)
   substitutions = {}
   # Put paragraphs all on one line (there has got to be a better way!)
   madlib = IO.readlines(madlib_file).join('').split(/\n\n/).collect{|l|l.gsub(/\n/,' ')}.join("\n\n")
   madlib_result = madlib.gsub(/\(\([^)]*\)\)/) do |match|
      match.gsub!(/\(|\)/,'') # Bye bye parens
      if substitutions[match]
         substitution = substitutions[match]
      else
         if match =~ /(.*):(.*)/
            key = $1
            match = $2
         end
         print "Please enter #{match}: "
         substitution = $stdin.gets.chomp
         if key
            substitutions[key] = substitution
         end
      end
      if output_pdf and underline
         "<u>#{substitution}</u>"
      else
         substitution
      end
   end
   if output_pdf
      filename = madlib_file+".pdf"
      print "Outputting PDF file #{filename}..."
      require 'pdf/ezwriter'
      pdf = PDF::EZWriter.new
      pdf.select_font("pdf/fonts/Helvetica")
      pdf.ez_text(madlib_result, 14)
      File.open(filename, File::RDWR|File::CREAT|File::TRUNC) do |file|
         file.print(pdf.ez_output)
      end
      puts "done."
   else
      puts "\n                            Your MadLib:\n\n"
      madlib_result.split("\n").each do |paragraph|
         # Lazy man's wrapping
         puts paragraph.gsub(/.{72}[^ ]* /){|l|"#{l}\n"}
      end
   end
end

if $0 == __FILE__
   if ARGV.length < 1
      puts "Usage: #$0 [-pdf] [-u] <madlib file>"
      puts "  -pdf      Output a PDF file."
      puts "  -u        Underline the replaced words in the PDF output file."
      exit(1)
   end
   output_pdf = false
   underline = false
   filename = nil
   while ARGV.length > 0
      arg = ARGV.shift
      case arg
         when '-pdf': output_pdf = true
         when '-u': underline = true
         else filename = arg
      end
   end
   if filename
      if test(?e, filename)
         do_madlib(filename, output_pdf, underline)
      else
         puts "Provided madlib file does not exist!"
      end
   else
      puts "No madlib filename provided!"
   end
end
