require 'slim'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'
require 'bcrypt'



enable :sessions
db = SQLite3::Database.new('db/library.db')
db.results_as_hash = true
id = 0

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
      session[:username] = username
      redirect('/home')
    else
      "FEL LÖSEN"
    end
  
end



post('/loan') do

    username = params[:username]
    password = params[:password]
    bookid = params[:bookid]
    username = "Agaton"
    userinfo = db.execute("SELECT * FROM users WHERE username = ?",username).first
    #pwdigest = result["pwdigest"]
    puts "bookid"
    puts bookid
    puts "userid"
    puts id


   if (id > 0) 
    #    if password==pwdigest
    #        pwd_digest=BCrypt::Password.create(password)
    #        db.execute(”INSERT INTO users(username,pwdigest) VALUES(?,?)”,username,pwdigest)
    #        redirect(’/welcome’)
    #    else
    #        redirect(’/error’) #Lösenord matchar ej
    #    end
    db.execute("INSERT INTO loan (bookid, userid) VALUES (?, ?)", [bookid, id])
    
   end

   redirect('/books')

end

get('/library') do

    

    db = SQLite3::Database.new('db/library.db')
    db.results_as_hash = true

    name = session[:username]

    userloans = db.execute("SELECT * FROM books WHERE id IN (SELECT bookid FROM loan WHERE userid = #{session[:id]})")
    puts userloans

    # loantable = db.execute("SELECT * FROM loan")

    users = db.execute("SELECT * FROM users")
    slim :library, locals:{users:users, userloans:userloans}
end

get('/rate') do
    slim :rate
end

post('/delete') do
    

end