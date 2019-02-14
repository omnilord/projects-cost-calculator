# projects-cost-calculator

You have a set of projects, and you need to calculate a reimbursement amount for the set. Each project has a start date and an end date. The first day of a project and the last day of a project are always "travel" days. Days in the middle of a project are "full" days. There are also two types of cities a project can be in, high cost cities and low cost cities.

## Operating criteria

### Original Rules

1. First day and last day of a project, or sequence of projects, is a travel day.
2. Any day in the middle of a project, or sequence of projects, is considered a full day.
3. If there is a gap between projects, then the days on either side of that gap are travel days.
4. If two projects push up against each other, or overlap, then those days are full days as well.
5. Any given day is only ever counted once, even if two projects are on the same day.
6. A travel day is reimbursed at a rate of 45 dollars per day in a low cost city.
7. A travel day is reimbursed at a rate of 55 dollars per day in a high cost city.
8. A full day is reimbursed at a rate of 75 dollars per day in a low cost city.
9. A full day is reimbursed at a rate of 85 dollars per day in a high cost city.

### Additional Clarification

10. The first day of any project counts as a travel day, even if it is a one or two day project.
11. "Pushed together" is inclussive of travel days.
12. When multiple projects overlap, use the high cost city to calculate for that day.

## validation fixtures

Given the following sets of projects, provide code which will calculate the reimbursement for each.

- Set 1:
  - Project 1: Low Cost City Start Date: 9/1/15 End Date: 9/3/15
  - Cost Evaluation:
    * low cost city: 2 travel days, 1 full day,
    * high cost city: 0 travel days, 0 full days,
    * total: 165 dollars

- Set 2:
  - Project 1: Low Cost City Start Date: 9/1/15 End Date: 9/1/15
  - Project 2: High Cost City Start Date: 9/2/15 End Date: 9/6/15
  - Project 3: Low Cost City Start Date: 9/6/15 End Date: 9/8/15
  - Cost Evaluation:
    * low cost city: 2 travel days, 1 full day,
    * high cost city: 0 travel days, 5 full days,
    * total: 590 dollars

- Set 3:
  - Project 1: Low Cost City Start Date: 9/1/15 End Date: 9/3/15
  - Project 2: High Cost City Start Date: 9/5/15 End Date: 9/7/15
  - Project 3: High Cost City Start Date: 9/8/15 End Date: 9/8/15
  - Cost Evaluation:
    * low cost city: 2 travel days, 1 full day,
    * high cost city: 2 travel days, 2 full days,
    * total: 445 dollars

- Set 4:
  - Project 1: Low Cost City Start Date: 9/1/15 End Date: 9/1/15
  - Project 2: Low Cost City Start Date: 9/1/15 End Date: 9/1/15
  - Project 3: High Cost City Start Date: 9/2/15 End Date: 9/2/15
  - Project 4: High Cost City Start Date: 9/2/15 End Date: 9/3/15
  - Cost Evaluation:
    * low cost city: 1 travel days, 0 full day,
    * high cost city: 1 travel days, 1 full days,
    * total: 185 dollars

## Execution

### Setup

```
git clone https://github.com/omnilord/projects-cost-calculator.git
cd projects-cost-calculator
bundle install
```

### Tests
```
rake test
```

### User-Readable Script
```
rake
```
