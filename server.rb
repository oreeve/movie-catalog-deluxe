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
    @actors = conn.exec("SELECT * FROM actors ORDER BY actors.name;")
    # binding.pry
  end

erb :'actors/index'
end

get '/actors/:id' do

  db_connection do |conn|
    @actor = params[:id]
    @info = conn.exec("SELECT actors.id, actors.name, movies.title, movies.id AS movie_id, cast_members.character FROM actors
    LEFT JOIN cast_members
    ON actors.id = cast_members.actor_id
    LEFT JOIN movies
    ON movies.id = cast_members.movie_id
    WHERE actors.id = '#{@actor}'
    ORDER BY movies.title;")
  end

erb :'actors/show'
end

get '/movies' do

  db_connection do |conn|
    @movies = conn.exec(
    "SELECT movies.id, movies.title, movies.year, movies.rating, genres.name AS genre, studios.name AS studio FROM movies
    LEFT JOIN genres
    ON movies.genre_id = genres.id
    LEFT JOIN studios
    ON movies.studio_id = studios.id
    ORDER BY movies.title
    ;")
  end

erb :'movies/index'
  # binding.pry
end

get '/movies/:id' do

  db_connection do |conn|
    @movie = params[:id]
    @info1 = conn.exec(
    "SELECT movies.id, movies.title, movies.year, movies.rating, genres.name AS genre, studios.name AS studio, cast_members.character, actors.name AS actor, actors.id AS actor_id FROM movies
    LEFT JOIN genres
    ON movies.genre_id = genres.id
    LEFT JOIN studios
    ON movies.studio_id = studios.id
    LEFT JOIN cast_members
    ON movies.id = cast_members.movie_id
    LEFT JOIN actors
    ON actors.id = cast_members.actor_id
    WHERE movies.id = '#{@movie}'
    ;")
  end

erb :'movies/show'
end
