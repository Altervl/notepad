class Link < Post

  def initialize
    super
    @url = ''
  end

  def read_from_console
    puts "Адрес ссылки:"
    @url = STDIN.gets.chomp

    puts "Описание ссылки:"
    @text = STDIN.gets.chomp
  end

  def to_strings
    time_string = "\nСоздано: #{@created_at.strftime("%d.%m.%Y %H:%M")}"

    return [@url, @text, time_string]
  end

  def to_db_hash
    return super.merge(
        {
            "url" => @url,
            "text" => @text
        }
    )
  end

  def load_data(data_hash)
    super(data_hash)
    @url = data_hash['url']
    @text = data_hash['text']
  end
end
