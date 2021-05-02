module ApplicationHelper
  def selected_path(path, t, f)
    request.path == path ? t : f
  end

  def flash_name_to_coler_name(flash_name)
    case flash_name
    when 'notice' then
      return 'blue'
    when 'alert' then
      return 'red'
    end
  end
end
