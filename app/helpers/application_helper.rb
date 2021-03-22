module ApplicationHelper
  def selected_path(path, t, f)
    request.path == path ? t : f
  end
end
