class Factories
  FactoryGirl.define do
    factory :building do
      code "TEST"
      name  "Test Building"
    end
  end
  FactoryGirl.define do
    factory :topic do
      name "First Year Potions"
      subject_area "POTI"
      topic_number "1001"
      year 2014
      semester "S1"
      units 4.5
      coordinator "Snape, Snape, Severus Snape"
      description "[generic description]"
       "[generic description]"
    end
  end
end