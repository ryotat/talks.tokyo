module ErrorMessages
  def to_list(errors)
    errors.full_messages.map { |x| "<li>#{x}</li>"}.join
  end
end
