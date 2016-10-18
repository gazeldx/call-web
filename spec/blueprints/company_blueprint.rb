Company.blueprint do
  name        { Faker::Company.name }
  license     { (1..999).sample }
  active      { [true, false].sample }
end