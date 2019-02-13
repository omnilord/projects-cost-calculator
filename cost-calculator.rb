# frozen_string_literal: true

require 'date'


# @const COSTS
# @desc Encapsulates the cost calculation data
COSTS = {
  low:  { travel: 45, full: 75 }.freeze,
  high: { travel: 55, full: 85 }.freeze
}.freeze


# @const COST_PRIORITY
# @desc A means of detemrining which city has priority in overlapping
COST_PRIORITY = { low: 0, high: 1 }.freeze


# @const DATE_FORMAT
# @desc A default value for how to parse dates
DATE_FORMAT = '%m/%d/%y'


# @name ProjectSet
# @desc A struct encapsulating the Projects and methods to reduce them down to a cost
# @attribute :projects [Array<Project>]
# @attribute :schedule [Array<ProjectSet::Schedule>]
class ProjectSet
  attr_reader :projects

  # @name ProjectSet::Project
  # @desc A simple structure for organizing the data received.
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

  def schedule
    @schedule ||= ProjectSet::Schedule.new(projects: @projects)
  end

  def cost
    schedule.reduce(0) do |cost, day|
      cost + COSTS[day.city][day.cost]
    end
  end
end


class ProjectSet::Schedule
  attr_reader :projects, :schedule

  # ProjectDay - A simple struct to keep each day in the schedule's data tidy.
  # @param :city [Symbol<:low|:high>] the level of city costs
  # @param :cost [Symbol<:travel_day|:full_day>] the type of cost
  ProjectDay = Struct.new(:date, :city, :cost)

  def initialize(projects: projects)
    @projects = projects
    @schedule = []

    projects.each { |project| add_project(project) }
    deduplicate
    sort
    assign_types
  end

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

  def add_project(project)
    (project[:start]..project[:end]).each do |day|
      @schedule << ProjectDay.new(day, project[:city], nil)
    end
  end

  def deduplicate
    @schedule = @schedule.group_by(&:date).map do |date, day|
      # Sort by configured priorty and return only the first
      day.sort { |a, b| COST_PRIORITY[b.city] <=> COST_PRIORITY[a.city] }.first
    end
  end

  def sort
    @schedule.sort_by!(&:date)
  end

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
