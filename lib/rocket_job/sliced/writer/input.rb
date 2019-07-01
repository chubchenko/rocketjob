module RocketJob
  module Sliced
    module Writer
      # Internal class for uploading records into input slices
      class Input
        attr_reader :record_count

        # Batch collection of lines into slices.
        #
        # Parameters
        #   on_first: [Proc]
        #     Block to call on the first line only, instead of storing in the slice.
        #     Useful for extracting the header row
        #     Default: nil
        def self.collect(input, **args, &block)
          writer = new(input, **args)
          # Create indexes before uploading
          input.create_indexes if input.respond_to?(:create_indexes)
          block.call(writer)
          writer.record_count
        rescue Exception => exc
          # Drop input collection when upload fails
          input.drop
          raise exc
        ensure
          writer&.close
        end

        def initialize(input, on_first: nil)
          @on_first      = on_first
          @batch_count   = 0
          @record_count  = 0
          @input         = input
          @record_number = 1
          @slice         = @input.new(first_record_number: @record_number)
        end

        def <<(line)
          @record_number += 1
          if @on_first
            @on_first.call(line)
            @on_first = nil
            return self
          end
          @slice << line
          @batch_count  += 1
          @record_count += 1
          if @batch_count >= @input.slice_size
            @input.insert(@slice)
            @batch_count = 0
            @slice       = @input.new(first_record_number: @record_number)
          end
          self
        end

        def close
          @input.insert(@slice) if @slice.size.positive?
        end
      end
    end
  end
end
