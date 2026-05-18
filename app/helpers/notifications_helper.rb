module NotificationsHelper
  def notification_bg_class(notification)
    if notification.read_at.nil?
      "bg-indigo-50/30 dark:bg-indigo-950/20 border-indigo-100/80 dark:border-indigo-900/30"
    else
      "bg-white dark:bg-slate-900 border-gray-100 dark:border-slate-800"
    end
  end

  def notification_icon_tag(notification)
    msg = notification.message || ""
    if msg.include?("Confirmada") || msg.include?("aceptado")
      content_tag(:i, nil, class: "fa-solid fa-calendar-check text-emerald-500 animate-bounce")
    elsif msg.include?("Rechazada") || msg.include?("cancelado")
      content_tag(:i, nil, class: "fa-solid fa-calendar-xmark text-rose-500")
    elsif notification.notifiable_type == "Payment" || msg.include?("Comprobante") || msg.include?("pago")
      content_tag(:i, nil, class: "fa-solid fa-file-invoice-dollar text-amber-500")
    else
      content_tag(:i, nil, class: "fa-solid fa-bell text-indigo-500")
    end
  end

  def notification_target_path(notification)
    case notification.notifiable
    when Payment
      reservation_path(notification.notifiable.reservation)
    else
      notification.notifiable
    end
  rescue
    root_path
  end
end
