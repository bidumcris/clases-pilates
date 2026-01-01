module ApplicationHelper
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
