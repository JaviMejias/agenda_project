module ApplicationHelper
  if Rails.env.test?
    def vite_stylesheet_tag(*args); end
    def vite_javascript_tag(*args); end
    def vite_client_tag(*args); end
  end
end
