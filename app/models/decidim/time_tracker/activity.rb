# frozen_string_literal: true

module Decidim
  module TimeTracker
    # The data store for a Activity in the Decidim::TimeTracker component. It
    # stores a description and other useful information related to an activity.
    class Activity < ApplicationRecord
      self.table_name = :decidim_time_tracker_activities

      belongs_to :task,
                 class_name: "Decidim::TimeTracker::Task"

      has_many :assignees,
               class_name: "Decidim::TimeTracker::Assignee"

      has_many :time_events,
               class_name: "Decidim::TimeTracker::TimeEvent"

      scope :active, -> { where(active: true) }

      # total number of seconds spent by the user
      # not counting current counters
      def user_total_seconds(user)
        @user_total_seconds ||= time_events.where(user: user).sum(&:total_seconds).to_i
      end

      def user_total_seconds_for_date(user, date)
        @user_total_seconds_for_date ||= time_events.started_between(date.beginning_of_day, date.end_of_day).where(user: user).sum(&:total_seconds).to_i
      end

      # Total number of secons spent by the user
      # and counting any possible running counters
      def user_seconds_elapsed(user)
        @user_seconds_elapsed ||= user_total_seconds(user) + time_events.last_for(user).seconds_elapsed
      end

      def counter_active_for?(user)
        !time_events.last_for(user).stopped?
      end

      # Returns how many seconds are available for this task in the current day
      # this can be less than the activity is allowed due the change of date
      def remaining_seconds_for_the_day
        @remaining_seconds_for_the_day ||= [max_minutes_per_day * 60, (Time.current.end_of_day - Time.current).to_i].min
      end

      def assignee_pending?(user)
        assignees.pending.where(user: user).count.positive?
      end

      def assignee_accepted?(user)
        assignees.accepted.where(user: user).count.positive?
      end

      def assignee_rejected?(user)
        assignees.rejected.where(user: user).count.positive?
      end
    end
  end
end
