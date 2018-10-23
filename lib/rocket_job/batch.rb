require 'active_support/concern'
require 'rocket_job/batch/callbacks'
require 'rocket_job/batch/io'
require 'rocket_job/batch/logger'
require 'rocket_job/batch/model'
require 'rocket_job/batch/state_machine'
require 'rocket_job/batch/throttle'
require 'rocket_job/batch/throttle_running_slices'
require 'rocket_job/batch/worker'

module RocketJob
  module Batch
    extend ActiveSupport::Concern

    include Model
    include StateMachine
    include Callbacks
    include Logger
    include Worker
    include Throttle
    include ThrottleRunningSlices
    include IO

    autoload :LowerPriority, 'rocket_job/batch/lower_priority'
    autoload :Performance, 'rocket_job/batch/performance'
    autoload :Statistics, 'rocket_job/batch/statistics'
    autoload :Result, 'rocket_job/batch/result'
    autoload :Results, 'rocket_job/batch/results'
    autoload :Tabular, 'rocket_job/batch/tabular'
  end
end

