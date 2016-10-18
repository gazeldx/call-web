User.blueprint do
  username    { "#{Faker::Name.last_name.downcase}#{(1..9999).sample}" }
  name        { Faker::Name.name }
  passwd      { 'e97187750d1258b5a4c264e7ca9553fe50f0ec2a' }
  company     { Company.make! }
end