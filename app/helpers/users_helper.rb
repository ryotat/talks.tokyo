module UsersHelper
  def suspended?(u)
    content_tag 'span', u.suspended?, :class => (u.suspended? ? 'text-error' : 'text-success')
  end
end

