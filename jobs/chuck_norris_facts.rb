require 'net/http'
require 'json'

#The Internet Chuck Norris Database,
server = 'http://api.icndb.com'

#Id of the widget
id = 'chuck'

#Proxy details if you need them - see below
proxy_host = 'XXXXXXX'
proxy_port = 8080
proxy_user = 'XXXXXXX'
proxy_pass = 'XXXXXXX'

SCHEDULER.every '30s', :first_in => 0 do |job|

  uri = URI("#{server}/jokes/random?firstName=Chuck&lastName=Norris&limitTo=[nerdy]")
  res = Net::HTTP.get(uri)

  #This is for when there is a proxy
  #res = Net::HTTP::Proxy(proxy_host, proxy_port, proxy_user, proxy_pass).get(uri)

  j = JSON[res]

  #Get the joke
  joke = j['value']['joke']

  #Send the joke to the text widget
  send_event id, {
                   :title => 'Chuck Norris Facts',
                   :text => "#{joke}"
               }

end
