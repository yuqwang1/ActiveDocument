# ActiveDocument

ActiveDocument is an object-relational mapping library written in Ruby and inspired by Active Record. My library utilizes object-oriented design and metaprogramming to abstract SQL queries and extend Object classes, which optimize the access speed to database.   

# Resources

* SQLite3
* ActiveSupport::Inflector

# Key Features

* Build my_attr_accessor module to define getter and setter method
* SQLObject, a class interact with the database through method of ::all, ::find, #insert, #update,  #save
* Search method ::where to add the ability to search the database
* Build associatable module to define belongs_to and has_many associations
* Build has_one_through to combine two belongs_to associations.
