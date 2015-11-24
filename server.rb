require "sinatra"
require "pg"
require 'pry'

configure :development do
  set :db_config, { dbname: "movies" }
end

configure :test do
  set :db_config, { dbname: "movies_test" }
end

def db_connection
  begin
    connection = PG.connect(Sinatra::Application.db_config)
    yield(connection)
  ensure
    connection.close
  end
end

get '/actors' do

  db_connection do |conn|
    @actors = conn.exec("SELECT name FROM actors ORDER BY actors.name;")
    # binding.pry
  end

erb :'actors/index'
end

get '/actors/:id' do

  db_connection do |conn|
    @actor = params[:id]
    @info = conn.exec("SELECT actors.name, movies.title, cast_members.character FROM actors
    JOIN cast_members
    ON actors.id = cast_members.actor_id
    JOIN movies
    ON movies.id = cast_members.movie_id
    WHERE actors.name = '#{@actor}'
    ORDER BY movies.title;")
  end

erb :'actors/show'
end

get '/movies' do

  db_connection do |conn|
    @movies = conn.exec(
    "SELECT movies.title, movies.year, movies.rating, genres.name AS genre, studios.name AS studio FROM movies
    JOIN genres
    ON movies.genre_id = genres.id
    JOIN studios
    ON movies.studio_id = studios.id
    ORDER BY movies.title
    ;")
  end

erb :'movies/index'
end

get '/movies/:id' do

  db_connection do |conn|
    @movie = params[:id]
    @info = conn.exec(
    "SELECT movies.title, movies.year, movies.rating, genres.name AS genre, studios.name AS studio, cast_members.character, actors.name AS actor FROM movies
    JOIN genres
    ON movies.genre_id = genres.id
    JOIN studios
    ON movies.studio_id = studios.id
    JOIN cast_members
    ON movies.id = cast_members.movie_id
    JOIN actors
    ON actors.id = cast_members.actor_id
    WHERE movies.title = '#{@movie}'
    ;")
  end

erb :'movies/show'
end
