module ApplicationHelper
  def level_label(level)
    return "" if level.blank?
    I18n.t("level_labels.#{level}", default: level.to_s.humanize)
  end

  def asset_exists?(path)
    if Rails.env.development?
      Rails.application.assets&.find_asset(path).present?
    else
      Rails.application.assets_manifest.assets[path].present?
    end
  rescue
    false
  end
end
