# frozen_string_literal: true

require 'spec_helper'

shared_examples 'a command' do |with_name:, with_called_name: nil,
                                stubbed_response: nil,
                                with_input_args: [], with_called_args: []|
  with_called_name ||= with_name
  let(:callable) { JabberAdmin.predefined_callable(with_name) }
  let(:res) do
    instance_double(RestClient::Response, body: stubbed_response, code: 200)
  end
  let(:action) do
    proc do |actual_callable|
      actual_callable ||= callable

      args, kwargs = with_input_args

      if kwargs.nil?
        if args.nil?
          described_class.call(actual_callable)
        else
          described_class.call(actual_callable, **args)
        end
      else
        described_class.call(actual_callable, *args, **kwargs)
      end
    end
  end

  it 'calls the call method on the given callable' do
    expect(callable).to receive(:call).once.and_return(res)
    action.call
  end

  # rubocop:disable RSpec/MultipleExpectations because of the test abstraction
  # rubocop:disable RSpec/ExampleLength because of the test abstraction
  it "passes '#{with_called_name}' as command name to the callable" do
    callable = proc do |command, _payload = {}|
      expect(command).to be_eql(with_called_name)
      res
    end
    expect(callable).to receive(:call).once.and_call_original
    action[callable]
  end

  if with_input_args.empty?
    it 'passes no further arguments to the callable' do
      callable = proc do |_command, payload = {}|
        expect(payload).to be_empty
        res
      end
      expect(callable).to receive(:call).once.and_call_original
      action[callable]
    end
  end

  (with_called_args.first || []).each do |key, value|
    it "passes the '#{key}' symbol to the callable" do
      hash = { key => value }
      callable = proc do |_command, payload = {}|
        expect(payload).to match(a_hash_including(hash))
        res
      end
      expect(callable).to receive(:call).once.and_call_original
      action[callable]
    end
  end
  # rubocop:enable RSpec/MultipleExpectations, RSpec/ExampleLength

  describe 'integration test', vcr: true do
    it 'raises no errors' do
      args, kwargs = with_input_args

      puts 'args: ' + args.inspect
      puts 'kwargs: ' + kwargs.inspect

      if kwargs.nil?
        if args.present?
          expect { JabberAdmin.send("#{with_name}!", **args) }.not_to \
            raise_error
        else
          expect { JabberAdmin.send("#{with_name}!", *args) }.not_to \
            raise_error
        end
      else
        expect { JabberAdmin.send("#{with_name}!", *args, **kwargs) }.not_to \
          raise_error
      end
    end
  end
end
