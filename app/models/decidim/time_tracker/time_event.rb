# frozen_string_literal: true

module Decidim
  module TimeTracker
    # The data store for a time entry in the Decidim::TimeTracker component.
    class TimeEvent < ApplicationRecord
      self.table_name = :decidim_time_tracker_events

      belongs_to :assignee,
                 class_name: "Decidim::TimeTracker::Assignee"

      belongs_to :activity,
                 class_name: "Decidim::TimeTracker::Activity"

      belongs_to :user,
                 foreign_key: "decidim_user_id",
                 class_name: "Decidim::User"

      default_scope { order(start: :desc) }
      scope :started_between, ->(start_date, end_date) { where("start >= ? AND start <= ?", start_date.to_i, end_date.to_i) }

      def self.last_for(user)
        if user.is_a?(Assignee)
          where(assignee: user).last
        else
          where(user: user).last
        end
      end

      def seconds_elapsed
        (Time.current - created_at).to_i
      end

      def stopped?
        stop.to_i >= start
      end
    end
  end
end
