# Pascal's Triangle (Ruby Quiz #84)
# by Mustafa Yilmaz
#
# This is the second Ruby program I've ever written and it's not optimized (and probably not
# leveraging the power of Ruby), so don't expect to much ;-) The code should be self-explanatory,
# if you have any questions though don't hesitate to ask me.
#
# My approach is to create a PDF file using the PDF::Writer libraries in order to get the
# centering right. Furthermore, I'm computing the binomial coefficent as discussed before to
# approximate the width of the largest number in the triangle.
#
# One could improve the program by dynamically adjusting the used text size to scale the text
# depending on the size of the triangle to make use of the whole page size.
#
# You can download an example pdf file from http://www.mustafayilmaz.net/pascal.pdf
#

begin
 require 'pdf/writer'
rescue LoadError => le
 if le.message =~ %r{pdf/writer$}
   $LOAD_PATH.unshift("../lib")
   require 'pdf/writer'
 else
   raise
 end
end

class Integer
 def factorial
   self <= 1 ? 1 : self * (self-1).factorial
 end
end

class Binomial_Coefficient
 def self.compute(n, r)
   n.factorial / (r.factorial * (n-r).factorial)
 end
end

class Pascal
 def self.create_pdf(lines, font_size, filename)
   max_width = Binomial_Coefficient.compute(lines, lines / 2).to_s.length + 2
   pdf = PDF::Writer.new(:paper => "A4", :orientation => :landscape)
   pdf.select_font "Courier"
   pdf.text "Pascal's Triangle (Ruby Quiz #84)\n\n\n", :font_size => 10, :justification => :center
   previous_result = Array.[](0, 1, 0)
   s = "1".center(max_width)
   while lines > 0 do
     pdf.text "#{s}\n\n", :font_size => font_size, :justification => :center
     current_result = Array.new      previous_result[0..-2].each_index do |i|
       current_result << previous_result[i] + previous_result[i+1]
     end       s = String.new
     current_result.each_index do |i|
       s << current_result[i].to_s.center(max_width)
     end
     current_result = Array.[](0).concat(current_result) << 0
     previous_result = current_result
     lines -= 1
   end
   pdf.save_as(filename)
 end
end

Pascal.create_pdf(20, 8, "pascal.pdf")
