require "net/http"
require "json"

# Where On Earth Identifiers for locations: http://woeid.rosselliot.co.nz

job_mapping = {
    'kliAde' => {:woeid => 1099805, :city => 'Adelaide'},
    'kliBer' => {:woeid => 638242, :city => 'Berlin'},
    'kliZurich' => {:woeid => 784794, :city => 'Zürich'},
    'kliVienna' => {:woeid => 12591694, :city => 'Wien'},
    'kliKA' => {:woeid => 12597063, :city => 'Karlsruhe'},
    'kliLon' => {:woeid => 44418, :city => 'London'}
}

# Units for temperature:
# f: Fahrenheit
# c: Celsius
format = "c"

job_mapping.each do |title, weather_project|
  SCHEDULER.every '15m', :first_in => 0 do |job|
    http = Net::HTTP.new 'query.yahooapis.com'
    query = URI::encode "select * from weather.forecast WHERE woeid=#{weather_project[:woeid]} and u='#{format}'&format=json"
    request = http.request Net::HTTP::Get.new("/v1/public/yql?q=#{query}")
    response = JSON.parse request.body
    results = response['query']['results']

    if results
      condition = results['channel']['item']['condition']
      location = results['channel']['location']
      send_event title, {
                          :location => location['city'],
                          :temperature => condition['temp'],
                          :code => climate_constants(condition['code']),
                          :format => format,
                          :date => condition['date']
                      }
    end
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
