require 'slim'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/flash'

require_relative 'model/model.rb'
also_reload 'model/model.rb'



enable :sessions




db = SQLite3::Database.new('db/library.db')
db.results_as_hash = true
id = 0


# Visar home.slim

get('/') do
  slim(:home)
end

# Visar home.slim

get('/home') do
    slim (:home)
end

# Visar books.slim och alla böcker i public biblioteket
#Hämtar böckerna från book tabellen i databasen
#Skicka localId för att hålla koll på adminanvändaren

get('/books') do   

    @result = get_all_books()

    puts "session id"
    puts session[:id]

    localId = session[:id]

    puts id

    if localId == 11 then
      localId = 11
    else
      localId = 0
    end
    slim :books, locals:{id:localId}
end

#Visar slim sidan där användare kan registrera sig

post('/register') do
    slim(:register)
end

#Håller koll på logik för om användare kan registrera sig
#Skapar en ny användare
#Sparar användarnamn och password_digest i users tabellen i databasen

post('/users/new') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
  
    if (password == password_confirm)
  
      password_digest = BCrypt::Password.create(password)
      create_user(username,password_digest)
      redirect('/')
  
    else
      redirect('/')
    end
end

#Visar inloggningssidan
  
get('/showlogin') do
    slim(:login)
end

#Hanterar logik för om anävndare kan logga in
#Jämför lösenord från users tabellen i databasen
  
post('/login') do
    username = params[:username]
    password = params[:password]
    user = get_user_by_username(username)
    pwdigest = user["pwdigest"]
    id = user["id"]

    
  
    if BCrypt::Password.new(pwdigest) == password
      session[:id] = id
      session[:username] = username
      redirect('/home')
    else
      flash[:password_error] = "Fel Lösenord."
    end
  
end

#Logik för användare som trycker på knappen för att låna böcker
#Tar information från users och books tabellerna till loan tabellen.
#

post('/loan') do

    username = params[:username]
    password = params[:password]
    bookid = params[:bookid]
    username = "Agaton"
    userinfo = get_user_by_username(username)
    id = session[:id]
    puts "bookid"
    puts bookid
    puts "userid"
    puts id


   if (id > 0) 
    create_user_book(bookid, id)    
   end

   redirect('/books')

end

#Visar användares personliga bibliotek
#Hanterar lånade böcker från loan tabellen och skriver ut följande böcker från book tabellen

get('/library') do

    

    db = SQLite3::Database.new('db/library.db')
    db.results_as_hash = true

    name = session[:username]

    userloans = get_user_books(session[:id]) 
    puts userloans

    users = db.execute("SELECT * FROM users")
    slim :library, locals:{users:users, userloans:userloans}
end

#Logik för en delete knapp i användares personliga bibliotek. 
#Tar bort rader från loan tabellen

post('/delete') do

    puts "userid"
    puts "#{session[:id]}"
    puts "bookid"
    puts "#{params[:bookId]}"


    delete_user_book(session[:id], params[:bookId])  
    redirect('/library')
end

#Skapar en delete knapp för admin användaren i public biblioteket
#Tar bort böcker från book tabellen


post('/books/delete') do

  puts "userid"
  puts "#{session[:id]}"
  puts "bookid"
  puts "#{params[:bookid]}"

  delete_book(params[:bookid])


  redirect('/books')

end