class Dog
  attr_accessor :name, :breed
  attr_reader :id
  
  def initialize(name, breed, id = nil)
    @id = id
    @name = name
    @breed = breed
end

def self.create_table
  sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
  SQL
  DB[:conn].execute(sql)
end

def self.drop_table
  sql = <<-SQL
    DROP TABLE IF EXISTS dogs
  SQL
  DB[:conn].execute(sql)
end

def save
  sql = <<-SQL
  INSERT INTO dogs (name, breed) VALUES (?, ?)
  SQL
  DB[:conn].execute(sql, self.name, self.breed)
  @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0]
end

def self.create(name, breed)
  dog = self.new(name, breed)
  dog.save
  dog
end

def self.new_from_db(row)
  dog = self.new(row)
  dog.id = row[0]
  dog.name = row[1]
  dog.breed = row[2]
end

def self.find_by_id(id)
  sql = <<-SQL
    SELECT * FROM dogs WHERE id = ? LIMIT 1
  SQL
  DB[:conn].execute(sql, self.id)
end

def self.find_or_create_by(name, breed)
  dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
  if !dog.empty?
    dog_data = dog[0]
    dog = self.new(dog_data[0], dog_data[1], dog_data[2])
  else
    self.find_by_name(name)
  end
end

def self.find_by_name(name)
  sql = <<-SQL
    SELECT * FROM dogs WHERE name = ?
  SQL
  result = DB[:conn].execute(sql, self.name)[0]
  Dog.new(result[0], result[1], result[2])
end
end






end