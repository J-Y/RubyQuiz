require 'RMagick'

# A few methods for creating images of names with RMagick.
module NameImage
  StarFile = './star_small.png'
  Colors = { :bg => 'black', :border_in => 'darkblue', :border_out => 'black',
             :text_stroke => 'darkblue', :text_fill => 'gold' }

  # Create a fancy animated ImageList.
  def NameImage.fancy name
    img = add_ripple(plain(name))
    img.border! 4, 4, Colors[:border_in]
    img.border! 4, 4, Colors[:border_out]
    img = add_stars img
    shake img
  end

  # Create a rather plain Image.
  def NameImage.plain name
    img = Magick::Image.new(1, 1) { self.background_color = Colors[:bg] }

    gc = Magick::Draw.new
    metrics = gc.get_multiline_type_metrics img, name
    img.resize! metrics.width * 4, metrics.height * 4

    gc.annotate(img, 0, 0, 0, 0, name) do |gc|
      gc.font_family = 'Verdana'
      gc.font_weight = Magick::LighterWeight
      gc.pointsize = 40
      gc.gravity = Magick::SouthEastGravity
      gc.stroke = Colors[:text_stroke]
      gc.fill = Colors[:text_fill]
    end

    img
  end

  # Create a new image consisting of img and a rippling reflection under it.
  def NameImage.add_ripple img
    img_list = Magick::ImageList.new
    xform = Magick::AffineMatrix.new 1.0, 0.0, Math::PI/4.0, 1.0, 0.0, 0.0
    img_list << img
    img_list << img.wet_floor(0.5, 0.7).affine_transform(xform).
                    rotate(90).wave(2, 10).rotate(-90)
    img_list.append true
  end

  # Create a new image consisting of img with stars on either side.
  def NameImage.add_stars img
    begin
      star = Magick::ImageList.new(StarFile).first
      img_list = Magick::ImageList.new
      img_list << star.copy
      img_list << img
      img_list << star
      img_list.append false
    rescue Magick::ImageMagickError
      $stderr.puts "Couldn't open #{StarFile}. Did you download it?"
      img
    end
  end

  # Create an animated ImageList of img shaking.
  def NameImage.shake img
    animation = Magick::ImageList.new

    20.times { animation << img.copy }
    0.3.step(0.6, 0.3) do |deg|
      animation << img.rotate(deg)
      animation << img.rotate(-deg)
    end
    animation << img.radial_blur(6)
    animation.delay = 5
    animation.iterations = 10000

    animation
  end
end
