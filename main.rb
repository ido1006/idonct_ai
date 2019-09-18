# coding: utf-8
require "./tweetBot.rb"
require "./textBuilder.rb"

def main()
  bot = TweetBot.new("idonct_ai")
  tweet_source = "kKanai_" 
  tweet_num = 500

  while 1 do
    bot.ffManage()
    sentence = generate_text(bot, tweet_source, tweet_num)
    bot.post(sentence)
    p "tweet -> " + sentence
    sleep(600)
  end
end 

main()
