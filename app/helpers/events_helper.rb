# frozen_string_literal: true

module EventsHelper
  def event_ogp_title(event)
    title_date = l(event.event_date)
    title_date += " #{event.event_time.strftime('%H:%M')}" if event.event_time.present?
    "#{t('app.title')}｜#{title_date}"
  end

  def event_ogp_description(event)
    "#{event.title.to_s.squish.truncate(50)}を会議中"
  end
end
