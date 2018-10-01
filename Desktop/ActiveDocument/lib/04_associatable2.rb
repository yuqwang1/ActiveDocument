require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    # ...
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      from_table = through_options.table_name
      from_primary_key = through_options.primary_key
      from_foreign_key =  through_options.foreign_key

      to_table = source_options.table_name
      to_primary_key = source_options.primary_key
      to_foreign_key = source_options.foreign_key

      results = DBConnection.execute(<<-SQL, self.send(from_foreign_key))
        SELECT
          #{to_table}.*
        FROM
          #{from_table}
        JOIN
          #{to_table}
        ON
          #{from_table}.#{to_foreign_key} = #{to_table}.#{to_primary_key}
        WHERE
          #{from_table}.#{from_primary_key} = ?
      SQL

      source_options.model_class.parse_all(results).first
    end
  end
end
