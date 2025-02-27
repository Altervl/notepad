require 'sqlite3'

class Post

  @@SQLITE_DB_FILE = 'notepad.sqlite'

  def self.post_types
    {"Link" => Link, "Memo" => Memo, "Task" => Task}
  end

  def self.create(type)
    return post_types[type].new
  end

  def self.find_by_id(id)
    begin
      db = SQLite3::Database.open(@@SQLITE_DB_FILE)
      db.results_as_hash = true

      result = db.execute('SELECT * FROM posts WHERE rowid = ?', id)
      result = result[0] if result.is_a? Array

      db.close
    rescue SQLite3::SQLException => e
      abort "Ошибка БД \"#{@@SQLITE_DB_FILE}\": #{e}."
    end

    if result.empty?
      puts "id #{id} не найден."
      return nil
    else
      post = create(result['type'])
      post.load_data(result)
      return post
    end
  end

  def self.find_all(type, limit)
    begin
      db = SQLite3::Database.open(@@SQLITE_DB_FILE)
      db.results_as_hash = false

      query = 'SELECT rowid, * FROM posts '
      query += 'WHERE type = :type ' unless type.nil? # :type - именованный плейсхолдер
      query += 'ORDER BY rowid DESC '
      query += 'LIMIT :limit ' unless limit.nil?

      statement = db.prepare(query)
      statement.bind_param('type', type) unless type.nil?
      statement.bind_param('limit', limit) unless limit.nil?

      result = statement.execute!

      statement.close
      db.close
    rescue SQLite3::SQLException => e
      abort "Ошибка БД \"#{@@SQLITE_DB_FILE}\": #{e}."
    end

    return result
  end

  def initialize
    @created_at = Time.now
    @text = nil
  end

  def read_from_console
  end

  def to_strings
  end

  def save
    file = File.new(file_path, "w:UTF-8")

    for item in to_strings do
      file.puts(item)
    end

    file.close
  end

  def file_path
    current_path = File.dirname(__FILE__)
    file_name = @created_at.strftime("#{self.class.name}_%Y-%m-%d_%H-%M-%S.txt")

    current_path + "/" + file_name
  end

  def save_to_db
    begin
      db = SQLite3::Database.open(@@SQLITE_DB_FILE)
      db.results_as_hash = true
      db.execute(
          "INSERT INTO posts (" +
            # Все поля, перечисленные через запятую
            to_db_hash.keys.join(', ') + ") " +
            " VALUES ( " +
            # Строка из заданного числа _плейсхолдеров_ ?,?,?...
            ('?,'*to_db_hash.keys.size).chomp(',') +
            ")",
        # Массив значений хэша, которые будут вставлены в запрос вместо _плейсхолдеров_
        to_db_hash.values
      )

      insert_row_id = db.last_insert_row_id

      db.close
    rescue SQLite3::SQLException => e
      abort "Ошибка БД \"#{@@SQLITE_DB_FILE}\": #{e}."
    end

    return insert_row_id
  end

  def to_db_hash
    {
        "type" => self.class.name,
        "created_at" => @created_at.to_s
    }
  end

  def load_data(data_hash)
    @created_at = Time.parse(data_hash['created_at'])
  end
end
