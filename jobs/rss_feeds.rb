id = 'newsfeeds'

def send_data_and_reschedule(id)
  http = Net::HTTP.new 'query.yahooapis.com'
  query = URI::encode "select title, description, source, pubDate from rss where url='http://rss.news.yahoo.com/rss/topstories' limit 10&format=json"
  request = http.request Net::HTTP::Get.new("/v1/public/yql?q=#{query}")
  response = JSON.parse request.body
  results = response['query']['results']['item']

  if results
    items = Array.new
    results.each do |item|

      #puts 'item found with '+item['title']
      items.push({:label => item['title']+' '+item['pubDate'], :value => item['source']['content']})

    end
    send_event id, {:items => items}
  end

  SCHEDULER.in '5m' do
    send_data_and_reschedule(id)
  end
end

send_data_and_reschedule(id)