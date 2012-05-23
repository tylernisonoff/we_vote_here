# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :election do
    finish_time "2012-05-22 01:48:20"
    info "MyText"
    name "MyString"
    privacy 1
    start_time "2012-05-22 01:48:20"
  end
end
