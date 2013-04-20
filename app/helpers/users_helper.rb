module UsersHelper
  def suspended?(u)
    content_tag 'span', u.suspended?, :class => (u.suspended? ? 'text-error' : 'text-success')
  end
  def suspend_link(u)
    if u.suspended?
      link_to 'Unsuspend', unsuspend_user_path(u), :method => :post, data: { confirm: "Are you sure to unsuspend #{u.name}\'s account (#{u.email})?" }
    else
      link_to 'Suspend', suspend_user_path(u), :method => :post, data: { confirm: "Are you sure to suspend #{u.name}\'s account (#{u.email})?" }
    end
  end
end

