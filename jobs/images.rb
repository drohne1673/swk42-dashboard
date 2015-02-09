require 'RMagick'
include Magick

def get_image_and_send
  #Get all images from a specific directory
  images = Dir['assets/images/*.gif']

  imageNameAbsolute = images.sample
  #Get just the fileName, the widget does not need the server filePath
  imageName = imageNameAbsolute.gsub(/assets\/images\//, '')

  imageList = Magick::ImageList.new("#{imageNameAbsolute}")

  #delay between images
  #ticks per second, default 100
  #puts "Image to show: #{imageName} with images #{imageList.length} delay #{imageList.delay} and ticks per second #{imageList.ticks_per_second} and iterations of #{imageList.iterations}"
  imageDuration = Float(imageList.length) * Float(imageList.delay) / Float(imageList.ticks_per_second)
  if (imageDuration!=0)
    imageDuration = imageDuration * 2.0
  end
  if (imageDuration > 30 || imageDuration ==0)
    imageDuration = 30
  end
  puts 'The gif will be shown for ' + imageDuration.to_s + ' seconds'
  send_event 'funny_images', {:image => "/#{imageName}"}

  schedule_image imageDuration
end

def schedule_image (timeInSeconds)
  SCHEDULER.in timeInSeconds.to_s+'s' do
    get_image_and_send
  end
end

schedule_image 30