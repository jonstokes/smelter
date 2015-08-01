require 'spec_helper'
require 'securerandom'

describe Smelter do
  let(:extension)        { Test::Extension.new(SecureRandom.uuid) }
  let(:extension_name)   { "test/my_extension" }
  let(:extension_source) {
    <<-EOS
      Test::Extension.define "#{extension_name}" do
        extension do
          def subtract(a, b)
            a - b
          end
        end
      end
    EOS
  }

  let(:script)        { Test::Script.new(SecureRandom.uuid) }
  let(:script_name)   { "test/my_script" }
  let(:script_source) {
    <<-EOS
      Test::Script.define "#{script_name}" do
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
    script.name      = script_name
    script.source    = script_source
    extension.name   = extension_name
    extension.source = extension_source

    Test::Extension.register_all
  end

  after(:each) do
    Redis.new.flushdb
  end

  context "A ScriptRunner for a Script with included modules and extensions defined on it" do
    subject { Test::Script.runner(script_name) }

    it { is_expected.to be_a(Smelter::ScriptRunner) }
    it { is_expected.to respond_to(:add) }
    it { is_expected.to respond_to(:subtract) }
  end

  context "Running scripts" do
    let(:runner) { Test::Script.runner(script_name) }

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
