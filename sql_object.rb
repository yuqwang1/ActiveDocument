require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject
  attr_writer :table_name
  attr_reader :table_name

  def self.columns
    return @cols if @cols
    array = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
      #{self.table_name}
    SQL
    @cols = array[0].map(&:to_sym)
  end

  def self.finalize!
    self.columns.each do |col|
      define_method(col) do
        self.attributes[col]
      end


    define_method("#{col}=") do |val|
      self.attributes[col] = val
    end
  end
end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      SQL

    self.parse_all(results)
  end

  def self.parse_all(results)
    results.map { |result|self.new(result) }
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL, id)
    SELECT
      #{table_name}.*
    FROM
      #{table_name}
    WHERE
      #{table_name}.id = ?
    SQL

    self.parse_all(results).first
  end

  def initialize(params = {})
    params.each do |attr_name, val|
      attr_name = attr_name.to_sym
      if self.class.columns.include?(attr_name)
        self.send("#{attr_name}=",val)
      else
        raise "unknown attribute '#{attr_name}'"
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |col|self.send(col) }
  end

  def insert
    col = self.class.columns.drop(1)
    col_name = col.map(&:to_s).join(",")
    question_marks = (["?"] * col.count).join(",")

    DBConnection.execute(<<-SQL, *attribute_values.drop(1))
      INSERT INTO
        #{self.class.table_name} (#{col_name})
      VALUES
        (#{question_marks})
      SQL

      self.id = DBConnection.last_insert_row_id
  end

  def update
    set_line = self.class.columns.map { |attr_name|"#{attr_name} = ?" }.join(",")
    DBConnection.execute(<<-SQL, *attribute_values, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        #{self.class.table_name}.id = ?
      SQL
  end

  def save
    id.nil? ? self.insert : self.update
  end
end
