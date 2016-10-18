Call.blueprint do
  company       { Company.find 57 }
  agent         { Agent.make! }
  caller_number { Faker::Number.number }
  callee_number { Faker::Number.number }
  started_at    { Time.now }
  stopped_at    { Time.now }
  duration      { (0..368).sample }
  outbound      { [true, false].sample }
  outbound_type { [0, 1, 2].sample }
  result        { [0, 1, 2].sample }
  task          { Task.last }
end