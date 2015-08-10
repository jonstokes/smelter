require 'spec_helper'
require 'securerandom'

describe Smelter do
  let(:extension_id)     { "test/my_extension" }
  let(:extension)        { Test::Extension.new(extension_id) }
  let(:extension_source) {
    <<-EOS
      Test::Extension.define "#{extension_id}" do
        extension do
          def subtract(a, b)
            a - b
          end
        end
      end
    EOS
  }

  let(:script_id)     { "test/my_script" }
  let(:script)        { Test::Script.new(script_id) }
  let(:script_source) {
    <<-EOS
      Test::Script.define "#{script_id}" do
        extensions 'test/*'

        script do
          number do |instance|
            instance['number'] * 10
          end

          subtraction_result do |instance|
            subtract(instance['number'], 1)
          end

          addition_result do |instance|
            add(instance['subtraction_result'], 10)
          end
        end
      end
    EOS
  }

  before(:each) do
    script.source    = script_source
    extension.source = extension_source

    Test::Extension.register_all
  end

  after(:each) do
    Redis.new.flushdb
  end

  context "A ScriptRunner for a Script with included modules and extensions defined on it" do
    subject { Test::Script.runner(script_id) }

    it { is_expected.to be_a(Smelter::ScriptRunner) }
    it { is_expected.to respond_to(:add) }
    it { is_expected.to respond_to(:subtract) }
  end

  context "Running scripts" do
    let(:runner) { Test::Script.runner(script_id) }

    it "mutates a shared instance variable across scripts" do
      instance = { 'number' => 5 }
      result_hash = {
        'number'             => 50,
        'subtraction_result' => 49,
        'addition_result'    => 59
      }
      runner.run(instance)

      expect(instance).to eq(result_hash)
    end
  end
end
