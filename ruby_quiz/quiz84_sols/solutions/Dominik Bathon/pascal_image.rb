# pascal_mod_pgm.rb

def pascal_rows_mod(rows, mod)
    row = [1]
    rows.times do
        yield row
        row = [1] + (0...row.size-1).map do |i|
            (row[i] + row[i + 1]) % mod
        end + [1]
    end
end

if $0 == __FILE__
    rows = ARGV.shift.to_i
    mod = (ARGV.shift || 2).to_i
    row_w = rows * 2 - 1
    File.open("pas_#{rows}_#{mod.to_s.rjust(3, "0")}.pgm", "w") do |f|
        f.puts "P5 #{row_w} #{rows} 1"
        pascal_rows_mod(rows, mod) do |row|
            f.print(row.map do |x|
                x == 0 ? "\1" : "\0"
            end.join("\1").center(row_w, "\1"))
        end
    end
end
