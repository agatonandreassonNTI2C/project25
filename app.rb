require 'slim'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'



enable :sessions

get('/') do
  slim(:register)
end

get('/showlogin') do
  slim(:login)
end

post('/login') do
  username = params[:username]
  password = params[:password]
  db = SQLite3::Database.new('db/todo_2021.db')
  db.results_as_hash = true
  result = db.execute("SELECT * FROM users WHERE username = ?",username).first
  pwdigest = result["pwdigest"]
  id = result["id"]

  if BCrypt::Password.new(pwdigest) == password
    session[:id] = id
    redirect('/todos')
  else
    "FEL LÖSEN"
  end

end

get('/todos') do 
  id = session[:id].to_i
  db = SQLite3::Database.new('db/todo_2021.db')
  db.results_as_hash = true
  result = db.execute("SELECT * FROM todos WHERE user_id = ?",id)
  slim(:"todos/index",locals:{todos:result})
end

post('/users/new') do
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]

  if (password == password_confirm)

    password_digest = BCrypt::Password.create(password)


    db = SQLite3::Database.new('db/user.db')

    db.execute('INSERT INTO user (username,password) VALUES (?,?)',[username,password_digest])

    redirect('/')

  else
    "Lösenord mathcade inte"
  end
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