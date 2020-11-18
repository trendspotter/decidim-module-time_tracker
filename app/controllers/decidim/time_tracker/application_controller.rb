# frozen_string_literal: true

module Decidim
  module TimeTracker
    # This controller is the abstract class from which all other controllers of
    # this engine inherit.
    #
    # Note that it inherits from `Decidim::Components::BaseController`, which
    # override its layout and provide all kinds of useful methods.
    class ApplicationController < Decidim::Components::BaseController
      helper_method :time_tracker

      private

      def time_tracker
        @time_tracker ||= Decidim::TimeTracker::TimeTracker.find_by(component: current_component)
      end
    end
  end
end
