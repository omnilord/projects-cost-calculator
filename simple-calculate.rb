# frozen_string_literal: true

require 'yaml'
require_relative './cost-calculator'

DATAFILE = File.expand_path('projects.fixtures.yml', "#{__dir__}/data/")
fixtures = YAML.load_file(DATAFILE)

puts "\nReview #{fixtures.length} project set(s).\n"

fixtures.each do |fixture|
  project_set = ProjectSet.new(projects: fixture[:projects])
  schedule = project_set.schedule

  puts <<~TXT

Group: #{fixture[:description]}
Projects: #{fixture[:projects].length}
Low Cost City Days:
  Travel Days: #{schedule.low_cost_travel_days}
  Full Days: #{schedule.low_cost_full_days}
Low Cost City Days:
  Travel Days: #{schedule.high_cost_travel_days}
  Full Days: #{schedule.high_cost_full_days}
TOTAL FEES: #{project_set.cost}

TXT
end

puts "\nDone.\n"
