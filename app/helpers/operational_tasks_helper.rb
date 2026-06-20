module OperationalTasksHelper
  def task_type_options
    OperationalTask.task_types.keys.map { |k| [ I18n.t("enums.operational_task.task_type.#{k}"), k ] }
  end

  def task_name_classes(task)
    if task.is_completed?
      "text-gray-400 dark:text-slate-500 line-through"
    else
      "text-gray-900 dark:text-slate-100"
    end
  end
end
