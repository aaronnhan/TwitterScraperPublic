class ApplicationController < ActionController::Base
	def home_screen
	end
	def search
		@tweets = Tweet.all
	end
end
