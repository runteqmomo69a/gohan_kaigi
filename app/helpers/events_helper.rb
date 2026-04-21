# frozen_string_literal: true

module EventsHelper
  def event_ogp_title(event)
    "#{event.title} | #{t('app.title')}"
  end

  def event_ogp_description(event)
    details = [ l(event.event_date) ]
    details << event.event_time.strftime("%H:%M") if event.event_time.present?
    details << event.place if event.place.present?

    note = event.note.to_s.squish
    details << note.truncate(60) if note.present?
    details.join(" / ")
  end
end
