module ReservationsHelper
  # Helpers para la vista de Rechazo / Cancelación
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

  # Helpers para la vista de Confirmación
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
end
