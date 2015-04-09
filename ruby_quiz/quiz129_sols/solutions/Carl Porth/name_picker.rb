#!/usr/bin/env ruby -wKU

require "rubygems"
require "camping"
require "RMagick"

module Enumerable
  def rand
    entries[Kernel.rand(entries.size)]
  end
end

Camping.goes :NamePicker

module NamePicker::Controllers
  class Index < R '/'
    def get
      render :index
    end
  end
  
  class Stylesheet < R '/style.css'
    def get
      @headers['Content-Type'] = 'text/css'
      File.read(__FILE__).gsub(/.*__END__/m, '')
    end
  end
  
  class StaticImage < R '/images/(.*)'
    def get(static_name)
      @headers['Content-Type'] = "image/jpg"
      @headers['X-Sendfile'] = "#{current_dir}/images/#{static_name}"
    end
  end
  
  class PickedNameImage < R '/picked_names/(.*?)\.gif'
    def get(name)
      make_image(name)
      @headers['Content-Type'] = "image/gif"
      @headers['X-Sendfile'] = "#{current_dir}/picked_names/#{name}.gif"
    end
  end
  
  class Page < R '/(\w+)'
    def get(page_name)
      render page_name
    end
  end
end

module NamePicker::Views
  def layout
    html do
      head do
        title "LOLPIXNAMES"
        link :href=> R(Stylesheet), :rel=>'stylesheet', :type=>'text/css'
      end      
      body { self << yield }
    end
  end
  
  def index
    p { img :src => R(StaticImage, "icanpixname.jpg") }
    p { a "PIX A NAME", :href => '/pick_name' }
  end
  
  def pick_name
    all_names = open('names').readlines.map do |e|
      e.gsub(/[^a-zA-Z 0-9]/,'')
    end.reject { |e| e.empty? }
    
    picked_names = Dir["picked_names/*.gif"].map do |e|
      e.sub(/picked_names\/(.*?)\.gif$/,'\\1')
    end
    
    unpicked_names = all_names - picked_names
    name = unpicked_names.rand
    
    p do
      img :src => R(StaticImage, "ipixedname.jpg")
      br
      img :src => "picked_names/#{name}.gif"
    end
    p { a "I CAN PIX YR NAME AGAIN", :href => '/pick_name' }
    p { a "KTHXBYE", :href => '/credits' }
  end
  
  def credits
    h1 "CREDITZ"
    ul do
      li "http://flickr.com/photos/mag3737/296800129/"
      li "http://flickr.com/photos/brian-fitzgerald/608882248/"
      li "http://www.ocf.berkeley.edu/~gordeon/fonts.html"
    end
    p "Carl Porth: badcarl@gmail.com"
  end
end

module NamePicker::Helpers
  def make_image(text)
    gif = Magick::ImageList.new
    
    decode_name(text.upcase).each do |frame_text|
      frame = Magick::Image.new(30*frame_text.size, 52) do
        self.background_color = 'black'
      end

      Magick::Draw.new.annotate(frame, 0,0,0,0, frame_text) do
        self.font         = 'Impact.ttf'
        self.pointsize    = 50
        self.fill         = 'white'
        self.stroke       = 'black'
        self.stroke_width = 2
        self.gravity      = Magick::CenterGravity
      end

      gif << frame
    end
    
    gif.delay = 15
    gif.iterations = 1
    
    gif.write("picked_names/#{text}.gif")
  end
  
  def encode_name(name, indexes=[])
    return [] if name.size == indexes.size + 1
    
    new_index = ((0...name.size).to_a - indexes).rand
    random_words(name, indexes) + encode_name(name, indexes << new_index)
  end
  
  def random_words(word, indexes_to_replace, number_of_words=indexes_to_replace.size)
    (0..number_of_words).to_a.map do
      new_word = word.dup
      indexes_to_replace.each { |i| new_word[i] = ("A".."Z").rand }
      new_word
    end
  end
  
  def decode_name(name)
    encode_name(name).reverse
  end
  
  def current_dir
    File.expand_path(File.dirname(__FILE__))
  end
end
__END__

body {
  background-color:black;
  text-align:center;
  font-size:30px;              
  font-family:impact;
  color:red;
  letter-spacing:3px;
}
a { color:red }
p { margin:80px }