class ApplicationController < ActionController::Base
  $twitter_client = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
    config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
    config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
    config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
  end

  $tm = TextMood.new(language: 'en', normalize_score: true)

  def home_screen
  end

  def search
    num_comparison_tweets = 5.0
    options = { count: num_comparison_tweets, include_rts: false }
    # popular twitter accounts
    usernames = ['barackobama', 'katyperry', 'rihanna', 'taylorswift13', 'jtimberlake', 'kimkardashian']
    @comparison_hash = {}
    usernames.each do |user|
      sentiment_score = 0
      timeline = $twitter_client.user_timeline(user, options)
      timeline.each do |t|
        text = ''
        status = $twitter_client.status(t, tweet_mode: 'extended')
        if status.truncated? && status.attrs[:extended_tweet]
          text = status.attrs[:extended_tweet][:full_text]
        else
          text = status.attrs[:text] || status.attrs[:full_text]
        end
        # sentiment analysis
        sentiment_score += $tm.analyze(text)
      end
      @comparison_hash[user] = sentiment_score / num_comparison_tweets
    end

    options = { count: 50, include_rts: false }
    @username = params[:username]
    begin
    timeline = $twitter_client.user_timeline(@username, options)
    rescue
      redirect_to '/home_screen/notFound'
      return
    end
    time_hash = {}
    retweet_hash = {}
    @retweet_time_hash = {}
    @popularity_time_hash = {}
    @sentiment_score = 0

    @tweets_content_file = File.join(File.expand_path('.'), 'tweet_data/tweet_content.txt')
    File.open(@tweets_content_file, 'w') {}

    timeline.each do |t|
      # generating phrases
      text = ''
      status = $twitter_client.status(t, tweet_mode: 'extended')
      if status.truncated? && status.attrs[:extended_tweet]
        text = status.attrs[:extended_tweet][:full_text]
      else
        text = status.attrs[:text] || status.attrs[:full_text]
      end
      #sentiment analysis
      @sentiment_score += $tm.analyze(text)
      File.open(@tweets_content_file, 'a') { |f|
        f.puts text[0...text.rindex(' ')]
      }

      popularity = t.favorite_count
      retweets = t.retweet_count

      time = t.created_at.utc + (60*60*7)
      time_key = time.hour

      if time_hash.include? time_key
        time_hash[time_key].append(popularity)
        retweet_hash[time_key].append(retweets)
      else
        time_hash[time_key] = [popularity]
        retweet_hash[time_key] = [retweets]
      end
    end

    @sentiment_score = @sentiment_score / 50.0
    @comparison_hash = @comparison_hash.sort_by { |_, b| -b }

    time_hash.each do |time, popularities|
      average = popularities.inject(0, :+) / popularities.length
      @popularity_time_hash[time] = average
    end

    retweet_hash.each do |time, retweets|
      average = retweets.inject(0, :+) / retweets.length
      @retweet_time_hash[time] = average
    end

    @popularity_time_hash.sort_by{|a, b| -b}
    @retweet_time_hash.sort_by{|a, b| -b}

    @sentences = generate_sentence
    if @sentences.nil?
      redirect_to '/home_screen/notFound'
      return
    end

    # followers
    followers = $twitter_client.user(@username).followers_count
    @follower_time_hash = { '0': followers, '11': followers, '23': followers }
    @follower_time_hash = @follower_time_hash.sort_by { |k, _| k }
  end

  def generate_sentence
    text = File.read(@tweets_content_file)
    generator = MarkovChains::Generator.new(text, 2)
    begin
    generator.get_sentences(2)
    rescue TypeError
      return nil
    end
  end
end
