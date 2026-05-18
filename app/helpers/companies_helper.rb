module CompaniesHelper
  def company_logo_tag(company, size_class = "w-12 h-12", custom_fallback_class = nil)
    if company.logo.attached?
      content_tag(:div, class: "#{size_class} rounded-[1.25rem] shrink-0 shadow-sm overflow-hidden border border-gray-100 dark:border-slate-700 inline-block") do
        image_tag(company.logo, loading: "lazy", class: "w-full h-full object-cover")
      end
    else
      fallback_class = custom_fallback_class || "bg-indigo-50 dark:bg-slate-800 text-indigo-600 dark:text-indigo-400 border border-gray-100 dark:border-slate-700 shadow-sm"
      content_tag(:div, class: "#{size_class} rounded-[1.25rem] shrink-0 flex items-center justify-center #{fallback_class} inline-block") do
        content_tag(:i, nil, class: "fa-solid fa-building")
      end
    end
  end
end
