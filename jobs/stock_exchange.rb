title = 'stockexchange'

SCHEDULER.every '5m' do
  http = Net::HTTP.new 'query.yahooapis.com'
  query = URI::encode "select * from yahoo.finance.historicaldata where symbol = 'UTDI.DE' and startDate = '2014-09-11' and endDate = '2015-02-10'&format=json"
  request = http.request Net::HTTP::Get.new("/v1/public/yql?q=#{query}")
  response = JSON.parse request.body
  results = response['query']['results']['quote']

  if results
    items = Array.new
    results.each do |item|

      puts 'item found with '+item['title']
      items.push({:label => item['title'], :value => item['source']['content']})

    end
    send_event title, {
                        :items => items
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