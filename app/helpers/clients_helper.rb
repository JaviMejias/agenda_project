module ClientsHelper
  def client_tag_classes(tag)
    case tag.to_s
    when "vip"         then "bg-amber-100 text-amber-700 border-amber-200 dark:bg-amber-900/30 dark:text-amber-400 dark:border-amber-800"
    when "recurrent"   then "bg-emerald-100 text-emerald-700 border-emerald-200 dark:bg-emerald-900/30 dark:text-emerald-400 dark:border-emerald-800"
    when "conflictive" then "bg-rose-100 text-rose-700 border-rose-200 dark:bg-rose-900/30 dark:text-rose-400 dark:border-rose-800"
    else                    "bg-gray-100 text-gray-700 border-gray-200 dark:bg-slate-800 dark:text-slate-400 dark:border-slate-700"
    end
  end

  def client_tag_icon(tag)
    case tag.to_s
    when "vip"         then "fa-star"
    when "recurrent"   then "fa-rotate"
    when "conflictive" then "fa-triangle-exclamation"
    else                    "fa-tag"
    end
  end
end
