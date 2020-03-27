require 'date'

class Task < Post
  def initialize
    super

    @due_date = Time.now # по умолчанию - текущее время, позже переопределится
  end

  def read_from_console
    puts "Что нужно сделать?"
    @text = STDIN.gets.chomp

    puts "Когда это нужно сделать?"
    puts "(укажите дату в формате 'дд-мм-гггг')"

    input = STDIN.gets.chomp
    @due_date = Date.parse(input)
  end

  def to_strings
    time_string = "\nСоздано: #{@created_at.strftime("%d.%m.%Y %H:%M")}"
    deadline = "Сделать до #{@due_date}:"

    return [deadline, @text, time_string]
  end
end
