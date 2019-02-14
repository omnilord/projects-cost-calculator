# frozen_string_literal: true

require 'date'


# Encapsulates the cost calculation data
COSTS = {
  low:  { travel: 45, full: 75 }.freeze,
  high: { travel: 55, full: 85 }.freeze
}.freeze


# A means of detemrining which city has priority in overlapping
COST_PRIORITY = { low: 0, high: 1 }.freeze


# A default value for how to parse dates
DATE_FORMAT = '%m/%d/%y'


# An encapsulation of the Projects, their combined and reduced schedule, and
# methods to reduce the scheduled days down to a cost
# @attribute :projects [Array<ProjectSet::Project>]
# @attribute :schedule [Array<ProjectSet::Schedule>]
class ProjectSet
  attr_reader :projects

  # A simple structure for organizing the data received.
  # @param :name [String]
  # @param :start_date [String]
  # @param :end_date [String]
  # @param :start [Date]
  # @param :end [Date]
  Project = Struct.new(:name, :city, :start_date, :end_date, :start, :end)

  def initialize(projects: projects)
    @projects = []
    projects.each do |project|
      @projects << ProjectSet::Project.new(project[:name],
                               project[:city],
                               project[:start_date],
                               project[:end_date],
                               Date.strptime(project[:start_date], DATE_FORMAT),
                               Date.strptime(project[:end_date], DATE_FORMAT)
                              )
    end
  end

  # Memoise the new schedule object fromt he list of projects.
  # @return [ProjectSet::Schedule]
  def schedule
    @schedule ||= ProjectSet::Schedule.new do |schedule|

      # Using the project's start and end dates, add the dates to the schedule
      @projects.each do |project|
        (project[:start]..project[:end]).each do |date|
          schedule.add_day(date: date, city: project[:city])
        end
      end
    end
  end

  # using the schedule, calculate the total cost of the project set.
  # @return [Integer]
  def cost
    schedule.reduce(0) do |cost, day|
      cost + COSTS[day.city][day.cost]
    end
  end
end

# The Schedule represents a class that takes the date range from a project and
# reduces days down to a clean representation of deduplicated days with attributes
# representing each day's properties (cost level of city and type of cost).
# @attribute :projects [Array<ProjectSet::Project>]
# @attribute :schedule [Array<ProjectDay>]
class ProjectSet::Schedule
  attr_reader :schedule

  # A simple struct to keep each day in the schedule's data tidy.
  # @param :city [Symbol<:low|:high>] the level of city costs
  # @param :cost [Symbol<:travel_day|:full_day>] the type of cost
  ProjectDay = Struct.new(:date, :city, :cost)

  def initialize
    @schedule = []

    # pass self to the construction block and let the project load it's days
    # into the schedule
    yield(self)

    deduplicate
    sort
    assign_types
  end

  def add_day(date:, city:)
    @schedule << ProjectDay.new(date, city, nil)
  end

  # A passthrough to an internal
  # @param memo [Integer] The starting value of the reduction
  # @param &block [proc] The block to be passed to the reduction
  # @return [Integer]
  def reduce(memo = 0, &block)
    @schedule.reduce(memo, &block)
  end

  def low_cost_travel_days
    @low_cost_travel_days ||= count_days(:low, :travel)
  end

  def low_cost_full_days
    @low_cost_full_days ||= count_days(:low, :full)
  end

  def high_cost_travel_days
    @high_cost_travel_days ||= count_days(:high, :travel)
  end

  def high_cost_full_days
    @high_cost_full_days ||= count_days(:high, :full)
  end

private

  def count_days(city, cost)
    @schedule.reduce(0) do |m, day|
      m + (day.city == city && day.cost == cost ? 1 : 0)
    end
  end

  # Take all the days, find the overlapping days and remove them with a
  # preference for keeping the highest order as defined in COST_PRIORITY
  def deduplicate
    @schedule = @schedule.group_by(&:date).map do |date, day|
      # Sort by configured priorty and return only the first
      day.sort { |a, b| COST_PRIORITY[b.city] <=> COST_PRIORITY[a.city] }.first
    end
  end

  def sort
    @schedule.sort_by!(&:date)
  end

  # Looping through the deduplicated and sorted schedule, assign a cost
  # type to each day based on it's position in the time sequence and
  # proxity to any gaps.  The first and last day are always :travel.
  def assign_types
    @schedule[0].cost = :travel
    @schedule.each_cons(3) do |days|
      days[1].cost =
        if days[0].date + 1 == days[1].date && days[1].date+ 1 == days[2].date
          :full
        else
          :travel
        end
    end
    @schedule[-1].cost = :travel
  end
end
