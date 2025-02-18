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

post('/loan') do

    username = params[:username]
    password = params[:password]
    db = SQLite3::Database.new('db/user.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM users WHERE username = ?",username).first
    pwdigest = result["pwdigest"]
    id = result["id"]



#    if result.empty?
#        if password==pwdigest
#            pwd_digest=BCrypt::Password.create(password)
#            db.execute(”INSERT INTO users(username,pwdigest) VALUES(?,?)”,username,pwdigest)
#            redirect(’/welcome’)
#        else
#            redirect(’/error’) #Lösenord matchar ej
#        end
#    end

end

get('/library') do

    db = SQLite3::Database.new('db/books.db')
    db.results_as_hash = true

    @library = db.execute("SELECT * FROM books")



    slim :library
end

get('/rate') do
    slim :rate
end

post('/delete') do
    

end