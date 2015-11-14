require "net/http"
require "json"

# Where On Earth Identifiers for locations: http://woeid.rosselliot.co.nz

job_mapping = {
    'kliAde' => {:woeid => 1099805, :city => 'Adelaide'},
    'kliBer' => {:woeid => 638242, :city => 'Berlin'},
    'kliBu' => {:woeid => 868274, :city => 'Bucharest'},
    'kliCebu' => {:woeid => 1199079, :city => 'Cebu'},
    'kliChester' => {:woeid => 23417972, :city => 'Chesterbrook'},
    'kliGlou' => {:woeid => 21248, :city => 'Gloucester'},
    'kliKA' => {:woeid => 12597063, :city => 'Karlsruhe'},
    'kliLogrono' => {:woeid => 765455, :city => 'Logrono'},
    'kliLon' => {:woeid => 44418, :city => 'London'}
}

current_weather = {}

def get_weather_from_location(woe_id)
  # Units for temperature:
  # f: Fahrenheit, c: Celsius
  format = 'c'

  query = URI::encode "select * from weather.forecast WHERE woeid=#{woe_id} and u='#{format}'&format=json"

  http = Net::HTTP.new 'query.yahooapis.com'
  response = http.request Net::HTTP::Get.new("/v1/public/yql?q=#{query}")

  jsonBody = JSON.parse response.body
  results = jsonBody['query']['results']

  if results
    condition = results['channel']['item']['condition']
    location = results['channel']['location']

    return {
        :location => location['city'],
        :temperature => condition['temp'],
        :code => climate_constants(condition['code']),
        :format => format,
        :date => condition['date']
    }
  end

end

def climate_constants(weather_code)
  case weather_code.to_i
    when 0
      'tornado'
    when 1
      'tornado'
    when 2
      'tornado'
    when 3
      'lightning'
    when 4
      'lightning'
    when 5
      'snow'
    when 6
      'sleet'
    when 7
      'snow'
    when 8
      'drizzle'
    when 9
      'drizzle'
    when 10
      'sleet'
    when 11
      'rain'
    when 12
      'rain'
    when 13
      'snow'
    when 14
      'snow'
    when 15
      'snow'
    when 16
      'snow'
    when 17
      'hail'
    when 18
      'sleet'
    when 19
      'haze'
    when 20
      'fog'
    when 21
      'haze'
    when 22
      'haze'
    when 23
      'wind'
    when 24
      'wind'
    when 25
      'thermometer low'
    when 26
      'cloud'
    when 27
      'cloud moon'
    when 28
      'cloud sun'
    when 29
      'cloud moon'
    when 30
      'cloud sun'
    when 31
      'moon'
    when 32
      'sun'
    when 33
      'moon'
    when 34
      'sun'
    when 35
      'hail'
    when 36
      'thermometer full'
    when 37
      'lightning'
    when 38
      'lightning'
    when 39
      'lightning'
    when 40
      'rain'
    when 41
      'snow'
    when 42
      'snow'
    when 43
      'snow'
    when 44
      'cloud'
    when 45
      'lightning'
    when 46
      'snow'
    when 47
      'lightning'
  end
end

def update_weather_data(current_weather, job_mapping)
  job_mapping.each do |title, weather_project|
    current_weather[title] = get_weather_from_location(weather_project[:woeid])
  end
end

#schedule the weather update
SCHEDULER.every '30m' do
  #Every long term get the current weather
  update_weather_data(current_weather, job_mapping)
end
#on startup get fill it right away
update_weather_data(current_weather, job_mapping)

def send_weather_and_reschedule(last_location, current_weather)
  title = current_weather.keys[last_location]
  send_event 'klimate', current_weather[title]
  last_location = last_location+1
  if (last_location > current_weather.keys.length-1)
    last_location = 0
  end
  SCHEDULER.in '3s' do
    send_weather_and_reschedule(last_location, current_weather)
  end
end

send_weather_and_reschedule(0, current_weather)
