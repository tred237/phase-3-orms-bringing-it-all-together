require 'pry'

class Dog
    attr_accessor :id

    def initialize(attributes, id: nil)
        attributes.each do |key, value|
            self.class.attr_accessor(key)
            self.send("#{key}=", value)
        end
    end

    def self.create_table
        sql = <<-SQL
            create table if not exists dogs (
                id integer primary key,
                name text,
                breed text
            )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            drop table if exists dogs
        SQL
        DB[:conn].execute(sql)
    end
    
    def save
        sql = <<-SQL
            insert into dogs 
            (name, breed)
            values (?,?)
        SQL

        if self.id
            self.update
        else 
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("select id from dogs order by id desc limit 1")[0][0]
        end
    end

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
        dog
    end

    def self.new_from_db(arr)
        self.new(id: arr[0], name: arr[1], breed: arr[2])
    end

    def self.all
        sql = <<-SQL
            SELECT * FROM dogs
        SQL
        DB[:conn].execute(sql).map do |i|
            self.new_from_db(i)
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
            select * from dogs where lower(name) = ?
        SQL
        dog = DB[:conn].execute(sql, name.downcase)
        self.new_from_db(dog[0])
    end

    def self.find(id)
        sql = <<-SQL
            select * from dogs where id = ?
        SQL
        dog = DB[:conn].execute(sql, id)
        self.new_from_db(dog.first)
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            select * from dogs where lower(name) = ? and lower(breed) = ?
        SQL
        dog = DB[:conn].execute(sql, name.downcase, breed.downcase)
        dog.length == 0 ? self.create(name: name, breed: breed) : self.new_from_db(dog.first)
    end

    def update
        sql = <<-SQL
            update dogs
            set name = ?
            where id = ? 
        SQL
        DB[:conn].execute(sql, self.name, self.id)
    end
end



# binding.pry
# 0