module ActiveRecord
    module ConnectionAdapters
        class Column  
            def type_cast_code(var_name)
                ActiveSupport::Deprecation.warn("Column#type_cast_code is deprecated in favor of" \
                  "using Column#type_cast only, and it is going to be removed in future Rails versions.")

                klass = self.class.name

                case type
                when :string, :text        then var_name
                when :integer              then "(#{var_name}.to_i rescue #{var_name} ? 1 : 0)"
                when :float                then "#{var_name}.to_f"
                when :decimal              then "#{klass}.value_to_decimal(#{var_name})"
                when :datetime, :timestamp then "#{klass}.string_to_time(#{var_name})"
                when :time                 then "#{klass}.string_to_dummy_time(#{var_name})"
                when :date                 then "#{klass}.value_to_date(#{var_name})"
                when :binary               then "#{klass}.binary_to_string(#{var_name})"
                when :boolean              then "#{klass}.value_to_boolean(#{var_name})"
                when :hstore               then "#{klass}.string_to_hstore(#{var_name})"
                when :inet, :cidr          then "#{klass}.string_to_cidr(#{var_name})"
                when :json                 then "#{klass}.string_to_json(#{var_name})"
                else var_name
                end
            end
        end

        class PostgreSQLColumn < Column
            module Cast
                def json_to_string(object)
                    if Hash === object
                        ActiveSupport::JSON.encode(object)
                    else
                        object
                    end
                end

                def string_to_json(string)
                    if String === string
                        ActiveSupport::JSON.decode(string)
                    else
                        string
                    end
                end
            end
 
            def self.extract_value_from_default(default)
                # This is a performance optimization for Ruby 1.9.2 in development.
                # If the value is nil, we return nil straight away without checking
                # the regular expressions. If we check each regular expression,
                # Regexp#=== will call NilClass#to_str, which will trigger
                # method_missing (defined by whiny nil in ActiveSupport) which
                # makes this method very very slow.
                return default unless default

                case default
                  # Numeric types
                  when /\A\(?(-?\d+(\.\d*)?\)?)\z/
                    $1
                  # Character types
                  when /\A'(.*)'::(?:character varying|bpchar|text)\z/m
                    $1
                  # Character types (8.1 formatting)
                  when /\AE'(.*)'::(?:character varying|bpchar|text)\z/m
                    $1.gsub(/\\(\d\d\d)/) { $1.oct.chr }
                  # Binary data types
                  when /\A'(.*)'::bytea\z/m
                    $1
                  # Date/time types
                  when /\A'(.+)'::(?:time(?:stamp)? with(?:out)? time zone|date)\z/
                    $1
                  when /\A'(.*)'::interval\z/
                    $1
                  # Boolean type
                  when 'true'
                    true
                  when 'false'
                    false
                  # Geometric types
                  when /\A'(.*)'::(?:point|line|lseg|box|"?path"?|polygon|circle)\z/
                    $1
                  # Network address types
                  when /\A'(.*)'::(?:cidr|inet|macaddr)\z/
                    $1
                  # Bit string types
                  when /\AB'(.*)'::"?bit(?: varying)?"?\z/
                    $1
                  # XML type
                  when /\A'(.*)'::xml\z/m
                    $1
                  # Arrays
                  when /\A'(.*)'::"?\D+"?\[\]\z/
                    $1
                  # Hstore
                  when /\A'(.*)'::hstore\z/
                    $1
                  # JSON
                  when /\A'(.*)'::json\z/
                    $1
                  # Object identifier types
                  when /\A-?\d+\z/
                    $1
                  else
                    # Anything else is blank, some user type, or some function
                    # and we can't know the value of that, so return nil.
                    nil
                end
            end
        
        private

            def simplified_type(field_type)
                  case field_type
                  # Numeric and monetary types
                  when /^(?:real|double precision)$/
                    :float
                  # Monetary types
                  when 'money'
                    :decimal
                  when 'hstore'
                    :hstore
                  # Network address types
                  when 'inet'
                    :inet
                  when 'cidr'
                    :cidr
                  when 'macaddr'
                    :macaddr
                  # Character types
                  when /^(?:character varying|bpchar)(?:\(\d+\))?$/
                    :string
                  # Binary data types
                  when 'bytea'
                    :binary
                  # Date/time types
                  when /^timestamp with(?:out)? time zone$/
                    :datetime
                  when 'interval'
                    :string
                  # Geometric types
                  when /^(?:point|line|lseg|box|"?path"?|polygon|circle)$/
                    :string
                  # Bit strings
                  when /^bit(?: varying)?(?:\(\d+\))?$/
                    :string
                  # XML type
                  when 'xml'
                    :xml
                  # tsvector type
                  when 'tsvector'
                    :tsvector
                  # Arrays
                  when /^\D+\[\]$/
                    :string
                  # Object identifier types
                  when 'oid'
                    :integer
                  # UUID type
                  when 'uuid'
                    :uuid
                  # JSON type
                  when 'json'
                    :json
                    # Small and big integer types
                  when /^(?:small|big)int$/
                    :integer
                    # Pass through all types that are not specific to PostgreSQL.
                  else
                    super
                  end
            end
        end

        class PostgreSQLAdapter < AbstractAdapter
            class TableDefinition < ActiveRecord::ConnectionAdapters::TableDefinition            
                def json(name, options = {})
                  column(name, 'json', options)
                end

                NATIVE_DATABASE_TYPES = {
                    primary_key: "serial primary key",
                    string:      { name: "character varying", limit: 255 },
                    text:        { name: "text" },
                    integer:     { name: "integer" },
                    float:       { name: "float" },
                    decimal:     { name: "decimal" },
                    datetime:    { name: "timestamp" },
                    timestamp:   { name: "timestamp" },
                    time:        { name: "time" },
                    date:        { name: "date" },
                    binary:      { name: "bytea" },
                    boolean:     { name: "boolean" },
                    xml:         { name: "xml" },
                    tsvector:    { name: "tsvector" },
                    hstore:      { name: "hstore" },
                    inet:        { name: "inet" },
                    cidr:        { name: "cidr" },
                    macaddr:     { name: "macaddr" },
                    uuid:        { name: "uuid" },
                    json:        { name: "json" }
                }
            end

            module OID
                class Type
                    def type; end

                    def type_cast_for_write(value)
                        value
                    end
                end

                class Json < Type
                    def type_cast(value)
                        return if value.nil?
                        ConnectionAdapters::PostgreSQLColumn.string_to_json value
                    end
                end

                NAMES = Hash.new { |h,k| # :nodoc:
                  h[k] = OID::Identity.new
                }

                def self.register_type(name, type)
                    NAMES[name] = type
                end

                register_type 'json', OID::Json.new
            end

            module Quoting
                def quote(value, column = nil)
                    return super unless column

                    case value
                    when Hash
                        case column.sql_type
                        when 'hstore' then super(PostgreSQLColumn.hstore_to_string(value), column)
                        when 'json' then super(PostgreSQLColumn.json_to_string(value), column)
                        else super
                        end
                    when IPAddr
                        case column.sql_type
                        when 'inet', 'cidr' then super(PostgreSQLColumn.cidr_to_string(value), column)
                        else super
                        end
                    when Float
                        if value.infinite? && column.type == :datetime
                            "'#{value.to_s.downcase}'"
                        elsif value.infinite? || value.nan?
                            "'#{value.to_s}'"
                        else
                            super
                        end
                    when Numeric
                        return super unless column.sql_type == 'money'
                        # Not truly string input, so doesn't require (or allow) escape string syntax.
                        "'#{value}'"
                    when String
                        case column.sql_type
                        when 'bytea' then "'#{escape_bytea(value)}'"
                        when 'xml'   then "xml '#{quote_string(value)}'"
                        when /^bit/
                            case value
                            when /^[01]*$/      then "B'#{value}'" # Bit-string notation
                            when /^[0-9A-F]*$/i then "X'#{value}'" # Hexadecimal notation
                            end
                        else
                            super
                        end
                    else
                        super
                    end
                end
            end
        end
    end
end
