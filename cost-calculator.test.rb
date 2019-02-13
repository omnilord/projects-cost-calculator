# frozen_string_literal: true

require 'minitest/reporters'
require 'minitest/autorun'
require 'minitest/spec'
require './cost-calculator'
require 'yaml'

Minitest::Reporters.use!(Minitest::Reporters::SpecReporter.new)

fixtures = YAML.load_file('./projects.fixtures.yml')

fixtures.each do |project_set|
  lctd = project_set[:evaluation][:low][:travel]
  lcfd = project_set[:evaluation][:low][:full]
  hctd = project_set[:evaluation][:high][:travel]
  hcfd = project_set[:evaluation][:high][:full]

  total_cost = project_set[:evaluation][:total]

  describe project_set[:description] do
    subject { ProjectSet.new(projects: project_set[:projects]) }

    let(:schedule) { subject.schedule }
    let(:low_cost_travel_days) { lctd }
    let(:low_cost_full_days) { lcfd }
    let(:high_cost_travel_days) { hctd }
    let(:high_cost_full_days) { hcfd }

    it "counts #{lctd} low cost travel day" do
      schedule.low_cost_travel_days.must_equal low_cost_travel_days
    end

    it "counts #{lcfd} low cost full days" do
      schedule.low_cost_full_days.must_equal low_cost_full_days
    end

    it "counts #{hctd} high cost travel day" do
      schedule.high_cost_travel_days.must_equal high_cost_travel_days
    end

    it "counts #{hcfd} high cost full day" do
      schedule.high_cost_full_days.must_equal high_cost_full_days
    end

    it "calculates a total of #{total_cost}" do
      subject.cost.must_equal total_cost
    end
  end
end
