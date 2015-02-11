id = 'fourtytwo'

facts = [
    %q[The Buddhist goddess of mercy, Guanyin, is sometimes depicted as having 42 arms.],
    %q[In Shakespeare's Romeo And Juliet, Juliet takes a potion to feign death for 'two and forty hours'.],
    %q[The Beast in the Book Of Revelation, chapter 13 was permitted to rule the Earth for 42 months.],
    %q[There are 42 dots on a pair of dice.],
    %q[two standard packs of cards have 42 eyes (one each for the jacks of spades and hearts, and the king of diamonds; two for the other court cards).],
    %q[When you see a rainbow, the angle between the ground and a line to the top of the rainbow is always 42 degrees.],
    %q[Forty-two per cent of the London Underground is under ground.],
    %q[Forty-two men served as US presidents before Barack Obama. He is called the 44th president as Grover Cleveland served two non-consecutive terms, so was both 22nd and 24th president.],
    %q[The official MCC laws of cricket contain a total of 42 laws.],
    %q[When he was 42, Douglas Adams played guitar on stage with Pink Floyd at Earl's Court.]
]


SCHEDULER.every '30s' do
  #fact = facts.sample

  uri = URI.parse('http://numbersapi.com/42')
  response = Net::HTTP.get_response(uri)

  send_event id, {
                   :title => '42 Facts',
                   :text => response.body
               }
end