class SendBirthdayNotificationsJob < ApplicationJob
  queue_as :background

  def perform(reference_date = Date.current)
    date = reference_date.is_a?(String) ? Date.parse(reference_date) : reference_date.to_date

    if ENV["BIRTHDAY_EMAIL_NOTIFICATIONS"] == "true"
      users_with_birthday(date).find_each do |user|
        next unless user.email.present?
        StudentMailer.birthday(user).deliver_later
      end
    end

    if ENV["BIRTHDAY_WHATSAPP_NOTIFICATIONS"] == "true"
      client = Whatsapp::Client.new
      return unless client.enabled?

      users_with_birthday(date).find_each do |user|
        next unless user.whatsapp_opt_in?
        to = user.mobile_e164_ar
        next if to.blank?

        template = ENV.fetch("WHATSAPP_TEMPLATE_BIRTHDAY", "birthday")
        client.send_template(
          to: to,
          template_name: template,
          language: ENV.fetch("WHATSAPP_TEMPLATE_LANGUAGE", "es_AR"),
          variables: [user.name.presence || "alumna/o"]
        )
      end
    end
  end

  private

  def users_with_birthday(date)
    User.where(role: :alumno, active: true)
        .where("birth_date IS NOT NULL")
        .where("EXTRACT(MONTH FROM birth_date) = ? AND EXTRACT(DAY FROM birth_date) = ?", date.month, date.day)
  end
end

