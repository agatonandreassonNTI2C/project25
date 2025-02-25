require 'slim'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'
require 'bcrypt'



enable :sessions
db = SQLite3::Database.new('db/library.db')
db.results_as_hash = true

get('/') do
  slim(:home)
end

get('/home') do
    slim (:home)
end

get('/books') do   


    #db = SQLite3::Database.new('db/library.db')
    #db.results_as_hash = true

    @result = db.execute("SELECT * FROM books")

    slim (:books)
end

post('/register') do
    slim(:register)
end

post('/users/new') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
  
    if (password == password_confirm)
  
      password_digest = BCrypt::Password.create(password)
      db = SQLite3::Database.new('db/library.db')
      db.execute('INSERT INTO users (username,pwdigest) VALUES (?,?)',[username,password_digest])
      redirect('/')
  
    else
      "Lösenord mathcade inte"
    end
end
  
get('/showlogin') do
    slim(:login)
end
  
post('/login') do
    username = params[:username]
    password = params[:password]
    db = SQLite3::Database.new('db/library.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM users WHERE username = ?",username).first
    pwdigest = result["pwdigest"]
    id = result["id"]
  
    if BCrypt::Password.new(pwdigest) == password
      session[:id] = id
      redirect('/home')
    else
      "FEL LÖSEN"
    end
  
end



post('/loan') do

    username = params[:username]
    password = params[:password]
    username = "Agaton.Andreasson@gmail.com"
    userinfo = db.execute("SELECT * FROM users WHERE username = ?",username).first
    #pwdigest = result["pwdigest"]
    userid = userinfo["id"]

    bookid=2

   if (!userid) 
    #    if password==pwdigest
    #        pwd_digest=BCrypt::Password.create(password)
    #        db.execute(”INSERT INTO users(username,pwdigest) VALUES(?,?)”,username,pwdigest)
    #        redirect(’/welcome’)
    #    else
    #        redirect(’/error’) #Lösenord matchar ej
    #    end
    db.execute("INSERT INTO loan (bookid, userid) VALUES (?, ?)" ,bookid, username).first
    
   end

end

get('/library') do

    db = SQLite3::Database.new('db/library.db')
    db.results_as_hash = true

    @library = db.execute("SELECT * FROM books")



    slim :library
end

get('/rate') do
    slim :rate
end

post('/delete') do
    

end