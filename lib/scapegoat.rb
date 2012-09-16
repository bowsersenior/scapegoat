require 'rubygems'
require 'sinatra/base'
require 'sinatra/reloader'
require 'sqlite3'

$DB = SQLite3::Database.new "goat.$DB"

# Create a database
rows = $DB.execute <<-SQL
  create table if not exists numbers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name varchar(30),
    val int
  );
SQL

# Execute a few inserts
{
  "one" => 1,
  "two" => 2,
}.each do |pair|
  $DB.execute "insert into numbers(id, name, val) values ( NULL, ?, ? )", pair
end

class Scapegoat < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    content_type :text

    <<-EOS

    ______________________
   < Welcome to scapegoat >
    ----------------------
        \\
         \\  (__)
            (\\/)
     /-------\\/
    / |     ||
   /  ||----||
      ~~    ~~

EOS
  end

  # sqlmap.py -u "http://localhost:9292/sql-injection?number_id=1"  --dbms sqlite
  get '/sql-injection' do
    query = if params['number_id']
      "select * from numbers where id = #{params['number_id']}"
    elsif params['sql']
      params['sql']
    end

    result = $DB.execute(query) if query

    haml :sqlmap, :locals => {:result => result}
  end
end