class Factories
  # This will guess the User class
  FactoryGirl.define do
    factory :building do
      code "TEST"
      name  "Test Building"
    end
  end
end