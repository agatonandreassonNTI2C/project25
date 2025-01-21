require 'slim'
require 'sinatra'
require 'sinatra/reloader'



get ('/') do
    redirect('/home')
end

post ('/') do
    redirect('/home')
end

get('/home') do
    slim :home
end

get('/books') do
    @book = {title: "Hunger Games", author: 5, price: 25}
    slim :books
end


get('/cart') do
    @cart = params[:cart]
    slim :cart
end

get('/rate') do
    slim :rate
end