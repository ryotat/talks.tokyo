FactoryGirl.define do
  factory :user do
    name "Albert Einstein"
    email "albert@talks.tokyo"
    password "hoge"
    password_confirmation "hoge"
  end
  
  factory :list do
    name "Super-interesting list"
    talk_post_password "hoge"
  end
end
