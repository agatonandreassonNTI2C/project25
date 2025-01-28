require 'slim'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'
require 'bcrypt'



enable :sessions

get('/') do
  slim(:home)
end

get('/home') do
    slim :home
end

get('/books') do   


    db = SQLite3::Database.new('db/books.db')
    db.results_as_hash = true

    @result = db.execute("SELECT * FROM books")

    slim (:books)
end

post('/buy') do

    username = params[:username]
    password = params[:password]
    db = SQLite3::Database.new('db/todo_2021.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM users WHERE username = ?",username).first
    pwdigest = result["pwdigest"]
    id = result["id"]

get('/cart') do
    @cart = params[:cart]
    slim :cart
end

get('/rate') do
    slim :rate
end