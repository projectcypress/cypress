class C3Task < Task
  # C3 = Report
  #  - Ability to create a data file
  #  - Cat 1 R3 or Cat 3
  # This validation will be rolled into the C1 and C2 tasks
  # and the C3 task won't have its own dedicated upload.
  def execute(_file)
  end
end
