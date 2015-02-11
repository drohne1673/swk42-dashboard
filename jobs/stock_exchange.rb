require 'net/http'
require 'json'

#Id of the widget
id = 'stockexchange'

company_symbol = 'UTDI.DE'

SCHEDULER.every '30s' do

  http = Net::HTTP.new 'query.yahooapis.com'
  query = URI::encode "select * from yahoo.finance.historicaldata where symbol = '"+company_symbol+"' and startDate = '2014-09-11' and endDate = '2015-02-11'&env=store://datatables.org/alltableswithkeys&format=json"
  request = http.request Net::HTTP::Get.new("/v1/public/yql?q=#{query}")
  response = JSON.parse request.body
  results = response['query']['results']['quote']

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


    series = [
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

    send_event id, {:series => series}
  end
end

#"results": {
#    "quote": [
#    {
#        "Symbol": "UTDI.DE",
#    "Date": "2015-02-10",
#    "Open": "39.21",
#    "High": "40.50",
#    "Low": "39.18",
#    "Close": "40.06",
#    "Volume": "546200",
#    "Adj_Close": "40.06"
#},
#    {
#        "Symbol": "UTDI.DE",