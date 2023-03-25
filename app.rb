require_relative "./my_user_model.rb"
require 'sinatra'
require 'erb'
require 'json'

set :views, "./views"
set :port, 8080
set :bind, '0.0.0.0'
enable :sessions

def user_json(user)
    user_hash = {:firstname => user.firstname, :lastname => user.lastname, :age => user.age, :email => user.email}
    user_hash.to_json
end

get "/" do
    @users = User.all
    @users.each do |row|
        User.new(row)
    end
    erb :index
end


#returns all users (without their passwords).
get "/users" do
    @users = User.all.to_json
end

#receives firstname, lastname, age, password and email. creates a user and stores in the database. returns the user created (without password).
## $>curl -X POST -i http://web-XXXXXXXXX.docode.qwasar.io/users -d "firstname=value1" -d "lastname=value2" -d "age=value3" -d "password=value4" -d "email=value5"
# 
post "/users" do

    user_info  = {:firstname => params[:firstname], :lastname => params[:lastname], :age => params[:age], :password => params[:password], :email => params[:email]}
    user = User.create(user_info)
    user_json(user)
    
end

#receives email and password. adds a session containing the user_id in order to be logged in and returns the user created (without password).
post "/sign_in" do
      
        if session[:user_id]
          return "You are already signed in!"
        end

        user = User.sign_in(params["email"], params["password"])
  
        if user
            session[:user_id] = user.id
            user_json(user)
        else
            status 401  
            "Invalid credentials"
        end
     

end

#user is logged in. 
#receives a new password, updates it. returns the user created (without password).
put "/users" do
    if session[:user_id]
        value = params[:password]
        user_id = session[:user_id]
        user = User.update(user_id,"password", value)
        user_json(user)
    else
        "You are not logged in!"   
    end


end


#user is logged in
#signs out the current user. returns nothing (code 204 in HTTP)
delete "/sign_out" do
    
    if session[:user_id]
        session[:user_id] = nil
        status 204
      else
        "You weren't signed in!"
      end
    
 end

#user is logged in
#signs out the current user and destroys user's record. returns nothing 
delete "/users" do
    
    
    if session[:user_id]
        
        changes = User.destroy(session[:user_id])
        if  changes > 0
            session[:user_id] = nil   
            status 204
        else
            "Unsuccessful attempt"
        end
    else
        "You are not logged in!"
    end
   
   
end
