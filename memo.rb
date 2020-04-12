class Memo < Post
  # тут конструктор заимствуется у класса-родителя

  def read_from_console
    puts "Новая заметка (строка 'end' - выход):"

    line = nil
    @text = []

    until line == "end" do
      line = STDIN.gets.chomp
      @text << line
    end

    @text.pop
  end

  def to_strings
    time_string = "\nСоздано: #{@created_at.strftime("%d.%m.%Y %H:%M")}"
    @text << time_string
    return @text
  end

  def to_db_hash
    return super.merge(
        {
            "text" => @text.join('\n')
        }
    )
  end

  def load_data(data_hash)
    super(data_hash)
    @text = data_hash['text'].split('\n')
  end
end
