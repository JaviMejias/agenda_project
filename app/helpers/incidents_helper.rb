module IncidentsHelper
  SEVERITY_CLASSES = {
    "high"   => "bg-rose-50 dark:bg-rose-950/30 text-rose-600 dark:text-rose-400 border-rose-200 dark:border-rose-900",
    "medium" => "bg-amber-50 dark:bg-amber-950/30 text-amber-600 dark:text-amber-400 border-amber-200 dark:border-amber-900",
    "low"    => "bg-blue-50 dark:bg-blue-950/30 text-blue-600 dark:text-blue-400 border-blue-200 dark:border-blue-900"
  }.freeze

  STATUS_CLASSES = {
    "resolved"    => "bg-emerald-50 text-emerald-600 dark:bg-emerald-950/30 dark:text-emerald-400 border-emerald-200 dark:border-emerald-900",
    "in_progress" => "bg-purple-50 text-purple-600 dark:bg-purple-950/30 dark:text-purple-400 border-purple-200 dark:border-purple-900"
  }.freeze

  STATUS_DEFAULT_CLASSES = "bg-gray-50 text-gray-600 dark:bg-slate-800 dark:text-slate-400 border-gray-200 dark:border-slate-700"

  def incident_severity_classes(severity)
    SEVERITY_CLASSES.fetch(severity.to_s, STATUS_DEFAULT_CLASSES)
  end

  def incident_status_classes(status)
    STATUS_CLASSES.fetch(status.to_s, STATUS_DEFAULT_CLASSES)
  end

  def incident_severity_label(severity)
    I18n.t("enums.incident.severity.#{severity}")
  end

  def incident_status_label(status)
    I18n.t("enums.incident.status.#{status}")
  end

  def incident_next_status_label(incident)
    incident.pending? ? I18n.t("incidents.actions.start_repair") : I18n.t("incidents.actions.mark_resolved")
  end

  def incident_next_status_value(incident)
    incident.pending? ? "in_progress" : "resolved"
  end

  def incident_next_status_classes(incident)
    if incident.pending?
      "text-[9px] font-black uppercase tracking-widest px-3 py-1.5 rounded-lg bg-purple-50 text-purple-600 hover:bg-purple-100 dark:bg-purple-900/30 dark:text-purple-400 transition-colors"
    else
      "text-[9px] font-black uppercase tracking-widest px-3 py-1.5 rounded-lg bg-emerald-50 text-emerald-600 hover:bg-emerald-100 dark:bg-emerald-900/30 dark:text-emerald-400 transition-colors"
    end
  end

  def incident_select_options(enum_klass, scope, i18n_key)
    enum_klass.send(scope).keys.map { |k| [ I18n.t("enums.incident.#{i18n_key}.#{k}"), k ] }
  end
end
