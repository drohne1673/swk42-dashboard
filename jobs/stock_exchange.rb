title = 'stockexchange'

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

      data_open.push({:x => date, :y => item['Open']})
      data_high.push({:x => date, :y => item['High']})
      data_low.push({:x => date, :y => item['Low']})
      data_close.push({:x => date, :y => item['Close']})

      #puts "added line with #{date} and open "+ item['Open']
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

    send_event title, {
                        :series => series
                    }
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