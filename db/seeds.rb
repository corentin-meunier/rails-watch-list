# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
require "json"
require "open-uri"

puts "Cleaning database..."
Bookmark.destroy_all
Review.destroy_all
List.destroy_all
Movie.destroy_all

puts "Fetching top-rated movies from TMDB..."
url = "https://tmdb.lewagon.com/movie/top_rated"
response = URI.open(url).read
movies = JSON.parse(response)["results"]

puts "Creating movies..."
movies.first(10).each do |movie_data|
  Movie.create!(
    title: movie_data["title"],
    overview: movie_data["overview"],
    poster_url: "https://image.tmdb.org/t/p/original#{movie_data["poster_path"]}",
    rating: movie_data["vote_average"]
  )
end

puts "Creating lists..."
action_list = List.create!(name: "Action Classics", image_url: "https://source.unsplash.com/500x300/?action,movie")
drama_list = List.create!(name: "Drama", image_url: "https://source.unsplash.com/500x300/?drama,movie")

puts "Creating bookmarks..."
movies = Movie.all
[action_list, drama_list].each do |list|
  movies.sample(4).each do |movie|
    Bookmark.create!(
      list: list,
      movie: movie,
      comment: "Must watch #{movie.title}!"
    )
  end
end

puts "Creating reviews..."
Review.create!(list: action_list, content: "Best action movies I've ever seen!")
Review.create!(list: action_list, content: "Explosions and adrenaline, loved it.")
Review.create!(list: drama_list, content: "Cried a lot. Beautiful storytelling.")
Review.create!(list: drama_list, content: "Perfect for a rainy Sunday.")

puts "✅ Done seeding!"
