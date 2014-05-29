require 'rmagick'

file = ARGV[0]
output_path = ARGV[1] || './output.png'
frame_path = ARGV[2] || "#{File.dirname(__FILE__)}/frame.png"
margin_left = (ARGV[3] || 66).to_i
margin_right = (ARGV[4] || 238).to_i


raise "no file given" unless (file || '').length > 0


original = Magick::ImageList.new  
original.from_blob(File.read(file))

if original.rows == 1136 and original.columns == 640

  image = Magick::ImageList.new  
  image.from_blob(File.read(frame_path))

  # Merge them!
  image.composite!(original, margin_left, margin_right, Magick::OverCompositeOp)

  # Export them
  File.write(output_path, image.to_blob)
  puts "Finished output to #{output_path}"
else
  puts "This screenshot has the wrong size! This script did nothing. The image needs to be 1136x640px"
end