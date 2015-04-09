#~ FOLDS=%w{T R B L}
FOLDS=%w{B L T R}

def fold(foldstring, rows=16, columns=16)
    raise "Incorrect dimensions for foldstring" unless 2 ** foldstring.size == rows * columns
    layers = [Array.new(rows) {|x|
        Array.new(columns) {|y|
            x * columns + y + 1
        }
    }]
    
    current_rotation = 0
    foldstring.split(//).each {|fold_char|
        rotation = FOLDS.index(fold_char)
        raise "Invalid fold char '#{fold_char}'" unless rotation
        #rotate so we always to a bottom to top fold, less thinking on array transforms that way.
        ((rotation - current_rotation)%4).times{layers.map! {|layer| layer.transpose.reverse }}
        current_rotation = rotation
        raise "Invalid fold at this time" unless layers[0].size > 1
        layers = layers.map {|layer|
            layer[(layer.size/2)..-1].reverse
        }.reverse + layers.map {|layer|
            layer[0...(layer.size/2)]
        } 
    }
    #don't need to rotate back, as we'll be 1x1 on each layer
    #(current_rotation%4).times {layers.map! {|layer| layer.reverse.transpose }}
    self
    raise "Not folded enough" unless layers[0].size == 1 && layers[0][0].size == 1
    layers.flatten
end

def unfold(array)
    folds = []
    layers = array.map {|x| [[x]]}
    while(layers.size > 1)
        if(layers.first.first.last == layers.last.first.last + 1)
            fold = 'R'
        elsif(layers.first.first.first  == layers.last.first.first  - 1)
            fold = 'L'
        elsif(layers.first.first.first  < layers.last.first.first )
            fold = 'T'
        else
            fold = 'B'
        end
        folds.unshift(fold)
        rotation = FOLDS.index(fold)
        #rotate so we always undo a top to bottom fold.
        rotation.times{layers.map! {|layer| layer.transpose.reverse }}
        (1..layers.size/2).each {|i|
            layers[-i].concat(layers.shift.reverse)
        }
        (rotation).times {layers.map! {|layer| layer.reverse.transpose }}
    end
    layers.flatten.each_with_index {|a,i|
        raise "Invalid array" unless a == i+1
    }
    folds.join
end

['TLTRTLBL','TLBTRLBL','RLTRTLBT'].each {|x|
    p "-----------"
    p x
    array = fold(x)
    p array
    unfolded = unfold(array)
    p unfolded
    raise "Didn't match" unless unfolded == x
}