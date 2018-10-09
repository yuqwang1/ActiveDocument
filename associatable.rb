require_relative 'searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
  defaults = {
    :foreign_key => "#{name}_id".to_sym,
    :primary_key => "id".to_sym,
    :class_name => name.to_s.camelcase
  }
  defaults.keys.each do |key|
    self.send("#{key}=", options[key] || defaults[key])
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      :foreign_key => "#{self_class_name.to_s.underscore}_id".to_sym,
      :primary_key => "id".to_sym,
      :class_name => name.to_s.singularize.camelcase
    }
    defaults.keys.each do |key|
      self.send("#{key}=", options[key] || defaults[key])
    end
  end
end

module Associatable
  def belongs_to(name, options = {})
    obj = BelongsToOptions.new(name, options)
    self.assoc_options[name] = obj

    define_method(name) do
      foreign_key = self.send(obj.foreign_key)
      result = obj.model_class.find(foreign_key)
    end

  end

  def has_many(name, options = {})
      obj = HasManyOptions.new(name, self, options)
      define_method(name) do
      result = obj.model_class.where(obj.foreign_key => self.send(obj.primary_key))
      end
  end

  def assoc_options
    @assoc_options_hash ||= {}
  end
end

class SQLObject
  extend Associatable
end
