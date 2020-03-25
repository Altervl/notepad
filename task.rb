class Task < Post
  def initialize
    super

    @due_date = Time.now # по умолчанию - текущее время, позже переопределится
  end

  def read_from_console
  end

  def to_strings
  end
end
