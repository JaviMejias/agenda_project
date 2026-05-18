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
    when 'list' then list_reservations_path
    when 'property' then property_path(reservation.property_id)
    else reservations_path
    end
  end

  def reservation_back_text(reservation, from_param)
    case from_param
    when 'list' then 'al listado'
    when 'property' then "a #{reservation.property.name}"
    else 'a la agenda'
    end
  end

  def reservation_status_badge_classes(reservation)
    case reservation.status
    when 'confirmed' then 'bg-emerald-50 dark:bg-emerald-950/30 text-emerald-600 dark:text-emerald-400 border-emerald-200 dark:border-emerald-900'
    when 'pending' then 'bg-amber-50 dark:bg-amber-950/30 text-amber-600 dark:text-amber-400 border-amber-200 dark:border-amber-900'
    else 'bg-rose-50 dark:bg-rose-950/30 text-rose-600 dark:text-rose-400 border-rose-200 dark:border-rose-900'
    end
  end

  def payment_method_icon(payment)
    case payment.payment_method
    when 'cash' then 'fa-money-bill'
    when 'transfer' then 'fa-money-bill-transfer'
    when 'card' then 'fa-credit-card'
    else 'fa-money-check'
    end
  end

  def payment_method_label(payment)
    case payment.payment_method
    when 'transfer' then 'Transferencia'
    when 'cash' then 'Efectivo'
    when 'card' then 'Tarjeta'
    else 'Depósito / Otro'
    end
  end

  def reservation_status_pdf_color(status)
    case status.to_s
    when 'pending' then '#d97706'
    when 'confirmed' then '#059669'
    when 'cancelled' then '#e11d48'
    else '#6b7280'
    end
  end

  def reservation_status_pdf_bg(status)
    case status.to_s
    when 'pending' then '#fffbeb'
    when 'confirmed' then '#f0fdf4'
    when 'cancelled' then '#fff1f2'
    else '#f9fafb'
    end
  end

  def receipt_status_style(status)
    case status.to_s
    when 'pending' then 'background-color: #fef3c7; color: #d97706; border: 1px solid #fde68a;'
    when 'confirmed' then 'background-color: #d1fae5; color: #059669; border: 1px solid #a7f3d0;'
    when 'cancelled' then 'background-color: #fee2e2; color: #e11d48; border: 1px solid #fecaca;'
    when 'completed' then 'background-color: #e0e7ff; color: #4338ca; border: 1px solid #c7d2fe;'
    else 'background-color: #f8fafc; color: #64748b; border: 1px solid #e2e8f0;'
    end
  end

  def receipt_status_label(status)
    case status.to_s
    when 'pending' then 'Pendiente'
    when 'confirmed' then 'Confirmada'
    when 'cancelled' then 'Cancelada'
    when 'completed' then 'Completada'
    else status.to_s.titleize
    end
  end
end
