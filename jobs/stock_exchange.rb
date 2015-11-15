require 'net/http'
require 'json'

#Id of the widget
id = 'stockexchange'

company_symbol = 'UTDI.DE' #united internet

current_series = {'series' => []}

def update_stockdata(company_symbol)
  date = Date.today
  formatted_time_now = date.strftime("%Y-%m-%d")
  #6 months ago
  start_time = date - 180 #days ago
  formatted_time_start = start_time.strftime("%Y-%m-%d")

  query = URI::encode "select * from yahoo.finance.historicaldata where symbol = '"+company_symbol+"' and startDate = '#{formatted_time_start}' and endDate = '#{formatted_time_now}'&env=store://datatables.org/alltableswithkeys&format=json"

  http = Net::HTTP.new 'query.yahooapis.com'
  response = http.request Net::HTTP::Get.new("/v1/public/yql?q=#{query}")


  jsonBody = JSON.parse response.body
  results = jsonBody['query']['results']['quote']

  if results
    data_open = Array.new
    data_high = Array.new
    data_low = Array.new
    data_close = Array.new

    results.each do |item|
      date = Time.parse(item['Date']).to_i

      data_open << {
          'x' => date,
          'y' => Float(item['Open'])
      }

      data_high << {
          'x' => date,
          'y' => Float(item['High'])
      }

      data_low << {
          'x' => date,
          'y' => Float(item['Low'])
      }

      close_value = Float(item['Close'])
      data_close << {
          'x' => date,
          'y' => close_value
      }

      #puts "added line with #{date} and open #{close_value}"
    end

    return [
        {
            :name => 'Open',
            :data => data_open
        }, {
            :name => 'High',
            :data => data_high
        }, {
            :name => 'Low',
            :data => data_low
        }, {
            :name => 'Close',
            :data => data_close
        }
    ]
  end
end

def update_series(current_series, company_symbol)
  current_series['series'] =update_stockdata(company_symbol)
end

SCHEDULER.every '4h' do
  update_series(current_series, company_symbol)
end
update_series(current_series, company_symbol)

def send_graph_and_reschedule(id, current_series)
  send_event id, {:series => current_series['series']}
  SCHEDULER.in '1m' do
    send_graph_and_reschedule(id, current_series)
  end
end

send_graph_and_reschedule(id, current_series)