#require 'RMagick'
#include Magick

def get_image_and_send
  #Get all images from a specific directory
  images = Dir['assets/images/*.gif']

  imageNameAbsolute = images.sample
  #Get just the fileName, the widget does not need the server filePath
  imageName = imageNameAbsolute.gsub(/assets\/images\//, '')

  send_event 'funny_images', {:image => "/#{imageName}"}

  schedule_image 30
end

def schedule_image (timeInSeconds)
  SCHEDULER.in timeInSeconds.to_s+'s' do
    get_image_and_send
  end
end

schedule_image 30