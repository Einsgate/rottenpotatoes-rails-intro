class Movie < ActiveRecord::Base
    def self.with_ratings(ratings)
        ratings = ratings.map { |s| "'#{s}'" }.join(', ')
        where("rating in (#{ratings})") 
    end
end
