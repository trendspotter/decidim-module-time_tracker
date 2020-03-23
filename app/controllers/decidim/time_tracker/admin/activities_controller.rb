# frozen_string_literal: true

module Decidim
  module TimeTracker
    module Admin
      class ActivitiesController < Admin::ApplicationController
        helper_method :activities

        def index
          activities
        end

        def new
          enforce_permission_to :create, :activities

          @form = form(TaskActivityForm).instance
        end

        def edit
          enforce_permission_to :update, :activity, activity: current_activity
          @form = form(TaskActivityForm).from_model(current_activity, task: current_task, activity: current_activity)
        end

        def create
          enforce_permission_to :create, :activities

          @form = form(TaskActivityForm).from_params(params)

          CreateActivity.call(@form, current_task) do
            on(:ok) do
              flash[:notice] = I18n.t("activities.create.success", scope: "decidim.time_tracker.admin")
              redirect_to EngineRouter.admin_proxy(current_component).task_activities_path(current_task)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("activities.create.error", scope: "decidim.time_tracker.admin")
              render :new
            end
          end
        end

        def update
          enforce_permission_to :update, :activity, activity: current_activity
          form = form(TaskActivityForm).from_params(params, task: current_task, activity: current_activity)
          UpdateActivity.call(current_activity, form, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("activities.update.success", scope: "decidim.time_tracker.admin")
              redirect_to EngineRouter.admin_proxy(current_component).task_activities_path(current_task)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("activities.update.error", scope: "decidim.time_tracker.admin")
              render :edit
            end
          end
        end

        def destroy
          enforce_permission_to :destroy, :activity, activity: current_activity

          DestroyActivity.call(current_activity, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("activities.destroy.success", scope: "decidim.time_tracker.admin")
              redirect_to EngineRouter.admin_proxy(current_component).task_activities_path(current_task)
            end
          end
        end

        private

        def activities
          @activities = Decidim::TimeTracker::Activity.where(task: current_task.id)
        end

        def current_task
          @current_task ||= Task.find(params[:task_id])
        end

        def current_activity
          @current_activity ||= Activity.find(params[:id])
        end
      end
    end
  end
end
