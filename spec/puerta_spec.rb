require 'spec_helper'

RSpec.describe Puerta do
  it "has a version number" do
    expect(Puerta::VERSION).not_to be nil
  end

  describe ".configure" do
    context "default env" do
      it "return sandox by default" do
        Puerta.reset_config
        expect(Puerta.config.sandbox?).to eq true
      end
    end

    context "set env as production" do
      it 'return production' do

        Puerta.configure do |config|
          config.env = 'production'
        end

        expect(Puerta.config.production?).to eq true
      end
    end

  end

  describe ".reset_config" do
    it 'reset config back to default' do
      Puerta.configure do |config|
        config.env = 'production'
      end

      expect(Puerta.config.production?).to eq true
      Puerta.reset_config
      expect(Puerta.config.sandbox?).to eq true

    end
  end

end
