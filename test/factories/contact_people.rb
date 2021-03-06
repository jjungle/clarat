require 'ffaker'

FactoryGirl.define do
  factory :contact_person do
    first_name { FFaker::NameDE.name }
    area_code_1 { maybe FFaker.numerify('#' * rand(3..6)) }
    local_number_1 { area_code_1 ? FFaker.numerify('#' * rand(7..11)) : nil }
    area_code_2 do
      (rand(2) == 0 && local_number_1) ? FFaker.numerify('#' * rand(3..6)) : nil
    end
    local_number_2 { area_code_2 ? FFaker.numerify('#' * rand(7..11)) : nil }
    fax_area_code { maybe FFaker.numerify('#' * rand(3..6)) }
    fax_number { fax_area_code ? FFaker.numerify('#' * rand(7..11)) : nil }
    email { maybe FFaker::Internet.email }

    organization

    transient do
      offers []
    end

    after :create do |contact_person, evaluator|
      contact_person.offers = evaluator.offers unless evaluator.offers.blank?
    end

    trait :no_fields do # careful, makes object non-valid
      first_name nil
      local_number_1 nil
      local_number_2 nil
      fax_number nil
      email nil
    end

    trait :just_telephone do
      first_name nil
      area_code_1 '030'
      local_number_1 '123456'
      area_code_2 nil
      local_number_2 nil
      email nil
      fax_number nil
      fax_area_code nil
    end
  end
end
