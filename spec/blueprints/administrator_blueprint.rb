Administrator.blueprint do
  username    { "#{Faker::Name.last_name.downcase}#{(1..9999).sample}" }
  name        { Faker::Name.name }
  passwd      { 'ecc0a196a116c84ca19fa461d409064827b9e2f3' }
end