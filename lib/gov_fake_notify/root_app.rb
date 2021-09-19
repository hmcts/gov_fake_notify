# frozen_string_literal: true

require 'roda'
require 'gov_fake_notify/notifications_app'
require 'gov_fake_notify/control_app'
module GovFakeNotify
  # The root application
  class RootApp < Roda
    plugin :multi_run
    plugin :common_logger
    run 'v2/notifications', NotificationsApp
    run 'control', ControlApp

    route(&:multi_run)
  end
end
