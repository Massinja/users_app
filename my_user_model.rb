require 'bundler/setup'
require 'sqlite3'
require 'json'

class Dbconnect
    def initialize

        @db = SQLite3::Database.new("db.sql")
        @db.results_as_hash = true
        sql = "CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY,
            firstname VARCHAR(255) NOT NULL,
            lastname VARCHAR(255) NOT NULL,
            age INTEGER NOT NULL,
            password VARCHAR(255) NOT NULL,
            email VARCHAR(255) NOT NULL UNIQUE);" 
        
        @db.execute(sql)

    rescue SQLite3::Exception => e
        puts "EXCEPTION OCCURRED: #{e}"

        return @db
    end
    
    def run_sql(method, sql_str, inputs)
        
        prep = @db.prepare(sql_str)
        resultset = prep.execute(inputs)
                   
        case method
            when :all
            user = @db.execute("SELECT id, firstname, lastname, age, email FROM users;")

            when :create
                id = @db.last_insert_row_id()
                user = @db.execute("SELECT id, firstname, lastname, age, email FROM users WHERE id = ?", id)[0]
                        
            when :find, :sign_in
                user = resultset.next_hash
       
            when :update, :destroy
                user = @db.changes
                
        end      

        resultset.close         
        @db.close
        return user

        rescue SQLite3::Exception => e
            puts "EXCEPTION OCCURRED: #{e}"    

    end

    def field_check(table_name, attribute)

        fields = @db.execute "SELECT name FROM PRAGMA_TABLE_INFO(?)", table_name
        @db.close
        fields.each do |column|
            if column["name"] == attribute
                return true
            end
        end

        return false

    end

end 
    
class User
    attr_accessor  :id, :firstname, :lastname, :age, :password, :email
    
    def initialize(array)
        @id        = array["id"]
        @firstname = array["firstname"]
        @lastname  = array["lastname"]
        @age       = array["age"]
        @password  = array["password"]
        @email     = array["email"]
    end

    def self.create(user_info)
        
        query = "INSERT INTO users (firstname, lastname, age, password, email) VALUES (?,?,?,?,?)"
        inputs = [user_info[:firstname], user_info[:lastname], user_info[:age], user_info[:password], user_info[:email]]
        method = :create 
      
        inputs.each do |val|
            if val.class == NilClass || val == ""
                return "Check your parameters"
            end
        end
      
        user = Dbconnect.new.run_sql(method, query, inputs)
  
        if !user 
            return "User creation failed!"
        end
        
        User.new(user)
           
    end

    def self.find(user_id)

        query = "SELECT id, firstname, lastname, age, email FROM users WHERE id = ?"
        inputs = user_id
        method = :find
        user = Dbconnect.new.run_sql(method, query, inputs)
        
        if !user
            return "No user found"
        end
     
        User.new(user)
                           
    end

    def self.sign_in(email, password)

        query = "SELECT id, firstname, lastname, age, email, password FROM users WHERE email = ? AND password = ?"
        inputs = [email, password]
        method = :sign_in
        user = Dbconnect.new.run_sql(method, query, inputs)
      
        if !user
            return user
        end
      
        User.new(user)
        
    end

    def self.all

        query = "SELECT id, firstname, lastname, age, email FROM users WHERE 1 = ?"
        inputs = "1"
        method = :all
        users = Dbconnect.new.run_sql(method, query, inputs)
        
    end

    def self.update(user_id, attribute, value)
    
        table_name = 'users'
        if !Dbconnect.new.field_check(table_name, attribute.to_s)
            return ["No #{attribute} field found."]
        end

        query = "UPDATE users SET #{attribute.to_s}=? WHERE id=?"
        inputs = [value, user_id]
        method = :update
     
        num = Dbconnect.new.run_sql(method, query, inputs)
        if num == 1
            return User.find(user_id)
        else
            return "something is wrong"
        end

    end

    def self.destroy(user_id)

        query = "DELETE FROM users WHERE id = ?"
        inputs = user_id
        method = :destroy
        user = Dbconnect.new.run_sql(method, query, inputs)
  
    end

end

#puts User.create({:firstname => "princess", :lastname =>"Nye", :age => 3, :password => "password", :email =>"email"})
