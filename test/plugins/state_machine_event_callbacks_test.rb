require_relative "../test_helper"

module Plugins
  class StateMachineEventCallbacksTest < Minitest::Test
    # This job adds each event callback as they run into an array
    # [:start, :complete, :fail, :retry, :pause, :resume, :abort, :requeue]
    class PositivePathJob < RocketJob::Job
      field :call_list, type: Array, default: []

      before_complete do
        call_list << "before_complete_block"
      end

      after_complete do
        call_list << "after_complete_block"
      end

      before_complete :before_complete_method

      before_start do
        call_list << "before_start_block"
      end

      before_start :before_start_method

      before_start do
        call_list << "before_start2_block"
      end

      after_start :after_start_method
      after_complete :after_complete_method

      before_complete do
        call_list << "before_complete2_block"
      end

      after_start do
        call_list << "after_start_block"
      end

      after_complete do
        call_list << "after_complete2_block"
      end

      after_start :after_start_method

      after_start do
        call_list << "after_start2_block"
      end

      before_start :before_start_method2
      before_complete :before_complete_method2

      def perform
        call_list << "perform"
      end

      private

      def before_start_method
        call_list << "before_start_method"
      end

      def before_start_method2
        call_list << "before_start_method2"
      end

      def after_start_method
        call_list << "after_start_method"
      end

      def before_complete_method
        call_list << "before_complete_method"
      end

      def before_complete_method2
        call_list << "before_complete_method2"
      end

      def after_complete_method
        call_list << "after_complete_method"
      end
    end

    describe RocketJob::Plugins::StateMachine do
      after do
        @job.destroy if @job && !@job.new_record?
      end

      describe "before_start after_start & before_complete after_complete" do
        it "runs blocks and functions" do
          @job = PositivePathJob.new
          @job.perform_now
          assert @job.completed?, @job.attributes.ai
          expected = %w[before_start_block before_start_method before_start2_block before_start_method2 after_start2_block after_start_method after_start_block perform before_complete_block before_complete_method before_complete2_block before_complete_method2 after_complete2_block after_complete_method after_complete_block]
          assert_equal expected, @job.call_list, "Sequence of before_perform callbacks is incorrect"
        end
      end
    end
  end
end
