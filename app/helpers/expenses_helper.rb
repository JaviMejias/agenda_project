module ExpensesHelper
  def expense_category_badge(expense)
    category_label = Expense.translated_categories[expense.category] || expense.category.to_s.titleize
    color_classes = case expense.category
    when "maintenance" then "bg-amber-50 text-amber-700 dark:bg-amber-950/30 dark:text-amber-400 border-amber-200/30"
    when "services" then "bg-sky-50 text-sky-700 dark:bg-sky-950/30 dark:text-sky-400 border-sky-200/30"
    when "supplies" then "bg-indigo-50 text-indigo-700 dark:bg-indigo-950/30 dark:text-indigo-400 border-indigo-200/30"
    when "taxes" then "bg-rose-50 text-rose-700 dark:bg-rose-950/30 dark:text-rose-400 border-rose-200/30"
    else "bg-gray-50 text-gray-700 dark:bg-slate-800 dark:text-slate-400 border-gray-200/30"
    end
    content_tag(:span, category_label, class: "px-2.5 py-1 rounded-md text-[9px] font-black uppercase tracking-widest border #{color_classes} inline-block")
  end

  def expense_vouchers_avatar_group(expense, size = :md)
    return content_tag(:span, "Sin archivos", class: "text-[9px] font-bold text-gray-300 dark:text-slate-600 uppercase tracking-tighter") unless expense.vouchers.attached?

    container_class = "flex -space-x-2"
    avatar_class = size == :sm ? "w-6 h-6" : "w-8 h-8"
    font_size = size == :sm ? "text-[6px]" : "text-[8px]"
    plus_font_size = size == :sm ? "text-[7px]" : "text-[9px]"
    img_variant_limit = [ 60, 60 ]

    vouchers_array = expense.vouchers.to_a
    taken = vouchers_array.take(3)
    remaining = vouchers_array.size - 3

    content_tag(:div, class: container_class) do
      links = taken.map do |voucher|
        link_to(rails_blob_path(voucher, disposition: "inline"), target: "_blank", class: "#{avatar_class} rounded-full border-2 border-white dark:border-slate-900 bg-gray-100 dark:bg-slate-800 overflow-hidden shadow-sm hover:scale-110 hover:z-10 transition-transform inline-block", title: "Ver #{voucher.filename}") do
          if voucher.image?
            image_tag(voucher.variant(resize_to_limit: img_variant_limit), class: "w-full h-full object-cover")
          else
            content_tag(:div, class: "w-full h-full flex items-center justify-center #{font_size} text-rose-500 font-bold") do
              content_tag(:i, nil, class: "fa-solid fa-file-pdf")
            end
          end
        end
      end.join.html_safe

      if remaining > 0
        plus_tag = content_tag(:div, "+#{remaining}", class: "#{avatar_class} rounded-full border-2 border-white dark:border-slate-900 bg-gray-200 dark:bg-slate-700 flex items-center justify-center #{plus_font_size} font-black text-gray-600 dark:text-slate-400 shadow-sm inline-block")
        links + plus_tag
      else
        links
      end
    end
  end
end
