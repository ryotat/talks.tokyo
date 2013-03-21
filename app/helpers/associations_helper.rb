module AssociationsHelper
  def link_list_or_talk(child)
    if child.is_a?(Talk)
      link_talk child
    else
      link_list child
    end
  end

  def list_or_talk_association_path(link)
    if link.child.is_a?(Talk)
      talk_association_path(link.child, link)
    else
      list_association_path(link.child, link)
    end
  end
end
