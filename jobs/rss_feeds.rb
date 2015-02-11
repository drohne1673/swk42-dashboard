title = 'newsfeeds'

SCHEDULER.every '5m' do
  http = Net::HTTP.new 'query.yahooapis.com'
  query = URI::encode "select title, description, source from rss where url='http://rss.news.yahoo.com/rss/topstories' limit 10&format=json"
  request = http.request Net::HTTP::Get.new("/v1/public/yql?q=#{query}")
  response = JSON.parse request.body
  results = response['query']['results']['item']

  if results
    items = Array.new
    results.each do |item|

      #puts 'item found with '+item['title']
      items.push({:label => item['title'], :value => item['source']['content']})

    end
    send_event title, {:items => items}
  end
end