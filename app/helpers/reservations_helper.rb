module ReservationsHelper
  def reject_bg_blur_class(status)
    if status == :success
      "bg-rose-500/10 dark:bg-rose-500/5"
    else
      "bg-amber-500/10 dark:bg-amber-500/5"
    end
  end

  def reject_icon_wrapper_classes(status)
    if status == :success
      "bg-rose-50 text-rose-500 dark:bg-rose-950/30 dark:text-rose-400"
    else
      "bg-amber-50 text-amber-500 dark:bg-amber-950/30 dark:text-amber-400"
    end
  end

  def reject_footer_banner_classes(status)
    if status == :success
      "text-rose-600 bg-rose-50 dark:text-rose-400 dark:bg-rose-950/30"
    else
      "text-amber-600 bg-amber-50 dark:text-amber-400 dark:bg-amber-950/30 font-bold"
    end
  end

  def reject_footer_icon_class(status)
    if status == :success
      "fa-circle-xmark"
    else
      "fa-circle-info"
    end
  end

  def reject_header_title(status)
    status == :success ? "Reserva Cancelada" : "Atención"
  end

  def confirm_bg_blur_class(status)
    case status
    when :success
      "bg-emerald-500/10 dark:bg-emerald-500/5"
    when :info
      "bg-amber-500/10 dark:bg-amber-500/5"
    else
      "bg-rose-500/10 dark:bg-rose-500/5"
    end
  end

  def confirm_icon_wrapper_classes(status)
    case status
    when :success
      "bg-emerald-50 text-emerald-500 dark:bg-emerald-950/30 dark:text-emerald-400"
    when :info
      "bg-amber-50 text-amber-500 dark:bg-amber-950/30 dark:text-amber-400"
    else
      "bg-rose-50 text-rose-500 dark:bg-rose-950/30 dark:text-rose-400"
    end
  end

  def confirm_footer_banner_classes(status)
    case status
    when :success
      "text-emerald-600 bg-emerald-50 dark:text-emerald-400 dark:bg-emerald-950/30"
    when :info
      "text-amber-600 bg-amber-50 dark:text-amber-400 dark:bg-amber-950/30"
    else
      "text-rose-600 bg-rose-50 dark:text-rose-400 dark:bg-rose-950/30 font-bold"
    end
  end

  def confirm_footer_icon_class(status)
    case status
    when :success
      "fa-circle-check"
    when :info
      "fa-circle-info"
    else
      "fa-circle-xmark"
    end
  end

  def confirm_header_title(status)
    case status
    when :success
      "¡Todo listo!"
    when :info
      "Aviso"
    else
      "Algo salió mal"
    end
  end

  def reservation_back_link(reservation, from_param)
    case from_param
    when "list" then list_reservations_path
    when "property" then property_path(reservation.property_id)
    when "client" then reservation.client_id ? client_path(reservation.client_id) : clients_path
    else reservations_path
    end
  end

  def reservation_back_text(reservation, from_param)
    case from_param
    when "list" then "al listado"
    when "property" then "a #{reservation.property.name}"
    when "client" then "a la ficha del cliente"
    else "a la agenda"
    end
  end

  def reservation_status_badge_classes(reservation)
    case reservation.status
    when "confirmed" then "bg-emerald-50 dark:bg-emerald-950/30 text-emerald-600 dark:text-emerald-400 border-emerald-200 dark:border-emerald-900"
    when "pending" then "bg-amber-50 dark:bg-amber-950/30 text-amber-600 dark:text-amber-400 border-amber-200 dark:border-amber-900"
    else "bg-rose-50 dark:bg-rose-950/30 text-rose-600 dark:text-rose-400 border-rose-200 dark:border-rose-900"
    end
  end

  def payment_method_icon(payment)
    case payment.payment_method
    when "cash" then "fa-money-bill"
    when "transfer" then "fa-money-bill-transfer"
    when "card" then "fa-credit-card"
    else "fa-money-check"
    end
  end

  def payment_method_label(payment)
    case payment.payment_method
    when "transfer" then "Transferencia"
    when "cash" then "Efectivo"
    when "card" then "Webpay"
    else "Depósito / Otro"
    end
  end

  def payment_method_color_classes(payment)
    case payment.payment_method
    when "transfer" then "bg-blue-50 text-blue-600 border-blue-200 dark:bg-blue-900/30 dark:text-blue-400 dark:border-blue-900/50"
    when "cash" then "bg-emerald-50 text-emerald-600 border-emerald-200 dark:bg-emerald-900/30 dark:text-emerald-400 dark:border-emerald-900/50"
    when "card" then "bg-pink-50 text-pink-600 border-pink-200 dark:bg-pink-900/30 dark:text-pink-400 dark:border-pink-900/50"
    else "bg-gray-50 text-gray-600 border-gray-200 dark:bg-slate-800 dark:text-slate-300 dark:border-slate-700"
    end
  end

  def reservation_status_pdf_color(status)
    case status.to_s
    when "pending" then "#d97706"
    when "confirmed" then "#059669"
    when "cancelled" then "#e11d48"
    else "#6b7280"
    end
  end

  def reservation_status_pdf_bg(status)
    case status.to_s
    when "pending" then "#fffbeb"
    when "confirmed" then "#f0fdf4"
    when "cancelled" then "#fff1f2"
    else "#f9fafb"
    end
  end

  def receipt_status_style(status)
    case status.to_s
    when "pending" then "background-color: #fef3c7; color: #d97706; border: 1px solid #fde68a;"
    when "confirmed" then "background-color: #d1fae5; color: #059669; border: 1px solid #a7f3d0;"
    when "cancelled" then "background-color: #fee2e2; color: #e11d48; border: 1px solid #fecaca;"
    when "completed" then "background-color: #e0e7ff; color: #4338ca; border: 1px solid #c7d2fe;"
    else "background-color: #f8fafc; color: #64748b; border: 1px solid #e2e8f0;"
    end
  end

  def receipt_status_label(status)
    case status.to_s
    when "pending" then "Pendiente"
    when "confirmed" then "Confirmada"
    when "cancelled" then "Cancelada"
    when "completed" then "Completada"
    else status.to_s.titleize
    end
  end

  def reservation_status_color_classes(status)
    case status
    when "pending" then "bg-amber-50 text-amber-700 border-amber-100 dark:bg-amber-950/30 dark:text-amber-400 dark:border-amber-900/50"
    when "confirmed" then "bg-emerald-50 text-emerald-700 border-emerald-100 dark:bg-emerald-950/30 dark:text-emerald-400 dark:border-emerald-900/50"
    when "cancelled" then "bg-rose-50 text-rose-700 border-rose-100 dark:bg-rose-950/30 dark:text-rose-400 dark:border-rose-900/50"
    when "blocked" then "bg-slate-700 text-white border-slate-800 dark:bg-slate-800 dark:text-slate-200 dark:border-slate-700 shadow-sm"
    else "bg-gray-50 text-gray-700 border-gray-100 dark:bg-slate-800/50 dark:text-slate-400 dark:border-slate-700/50"
    end
  end

  def reservation_payment_state_color_classes(payment_state)
    case payment_state
    when "Pagado" then "bg-emerald-50 text-emerald-700 border-emerald-100 dark:bg-emerald-950/30 dark:text-emerald-400 dark:border-emerald-900/50"
    when "Abonado" then "bg-amber-50 text-amber-700 border-amber-100 dark:bg-amber-950/30 dark:text-amber-400 dark:border-emerald-900/50"
    when "No pagado" then "bg-gray-50 text-gray-500 border-gray-100 dark:bg-slate-800/50 dark:text-slate-400 dark:border-slate-700/50"
    else "bg-gray-50 text-gray-500 border-gray-100 dark:bg-slate-800/50 dark:text-slate-400 dark:border-slate-700/50"
    end
  end

  def audit_visible_details(audit)
    audit.details.reject { |k, _| %w[updated_at created_at payment_id id].include?(k) }
  end

  def audit_action_label(action)
    I18n.t("audit.actions.#{action}", default: action.to_s.humanize)
  end

  def audit_icon_config(action)
    case action.to_s
    when "creación"
      { icon: "fa-plus",           color: "text-emerald-500", ring: "ring-emerald-200 dark:ring-emerald-800", badge: "bg-emerald-50 dark:bg-emerald-950/50 border-emerald-200 dark:border-emerald-800 text-emerald-600 dark:text-emerald-400" }
    when "confirmed", "status_changed_to_confirmed"
      { icon: "fa-check",          color: "text-indigo-500",  ring: "ring-indigo-200 dark:ring-indigo-800",   badge: "bg-indigo-50 dark:bg-indigo-950/50 border-indigo-200 dark:border-indigo-800 text-indigo-600 dark:text-indigo-400" }
    when "cancelled", "status_changed_to_cancelled"
      { icon: "fa-ban",            color: "text-rose-500",    ring: "ring-rose-200 dark:ring-rose-800",       badge: "bg-rose-50 dark:bg-rose-950/50 border-rose-200 dark:border-rose-800 text-rose-600 dark:text-rose-400" }
    when "payment_added"
      { icon: "fa-money-bill-wave", color: "text-emerald-500", ring: "ring-emerald-200 dark:ring-emerald-800", badge: "bg-emerald-50 dark:bg-emerald-950/50 border-emerald-200 dark:border-emerald-800 text-emerald-600 dark:text-emerald-400" }
    when "payment_approved"
      { icon: "fa-check-double",   color: "text-blue-500",    ring: "ring-blue-200 dark:ring-blue-800",       badge: "bg-blue-50 dark:bg-blue-950/50 border-blue-200 dark:border-blue-800 text-blue-600 dark:text-blue-400" }
    when "payment_rejected"
      { icon: "fa-xmark",          color: "text-rose-500",    ring: "ring-rose-200 dark:ring-rose-800",       badge: "bg-rose-50 dark:bg-rose-950/50 border-rose-200 dark:border-rose-800 text-rose-600 dark:text-rose-400" }
    when "payment_deleted"
      { icon: "fa-trash",          color: "text-gray-400",    ring: "ring-gray-200 dark:ring-gray-700",       badge: "bg-gray-50 dark:bg-slate-800 border-gray-200 dark:border-slate-700 text-gray-500 dark:text-slate-400" }
    when "actualización"
      { icon: "fa-pen",            color: "text-amber-500",   ring: "ring-amber-200 dark:ring-amber-800",     badge: "bg-amber-50 dark:bg-amber-950/50 border-amber-200 dark:border-amber-800 text-amber-600 dark:text-amber-400" }
    else
      { icon: "fa-circle-dot",     color: "text-gray-400",    ring: "ring-gray-200 dark:ring-gray-700",       badge: "bg-gray-50 dark:bg-slate-800 border-gray-200 dark:border-slate-700 text-gray-500 dark:text-slate-400" }
    end
  end

  def audit_translate_key(key)
    I18n.t("audit.field_keys.#{key}", default: key.to_s.humanize)
  end

  def audit_format_value(key, value)
    return "n/a" if value.blank?

    if %w[amount total_price].include?(key.to_s)
      number_to_currency(value, unit: "$", separator: ",", delimiter: ".", format: "%u%n", precision: 0)
    elsif %w[start_time end_time].include?(key.to_s)
      Time.zone.parse(value.to_s).strftime("%d %b %Y, %H:%M") rescue value.to_s
    else
      I18n.t("audit.field_values.#{key}.#{value}", default: value.to_s)
    end
  end
end
