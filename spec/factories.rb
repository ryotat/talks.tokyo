FactoryGirl.define do
  factory :albert, :class => User do
    name "Albert Einstein"
    email "albert@talks.tokyo"
    password "hoge"
    password_confirmation "hoge"
    after(:create) { |user| user.last_login = Time.now }
  end
  
  factory :bob, :class => User do
    name "Bob Marley"
    email "bob@talks.tokyo"
    password "fuga"
    password_confirmation "fuga"
  end

  factory :user do
    sequence(:name) { |n| "User#{n}" }
    sequence(:email) { |n| "user#{n}@talks.tokyo" }
    password "hoge"
    password_confirmation { |u| u.password }
  end

  factory :talk do
    sequence(:title) { |n| "Talk#{n}" }
    speaker { FactoryGirl.create(:user) }
    abstract "Blablablablablablablablablablablablablablabla."
    start_time { Array(-5..5).sample.day.ago }
    end_time { |t| t.start_time + 2.hour }
    series { FactoryGirl.create(:list) }
    venue { FactoryGirl.create(:venue) }
  end
  
  factory :list do
    ignore do
      organizer "albert"
    end
    name { "#{organizer}'s list" }
    talk_post_password "hoge"
    users { [ find_or_create(User, organizer) ] }
    after(:create) do |list| 
      Array(5..10).sample.times.map { FactoryGirl.create(:talk, :series => list) }
      FactoryGirl.create(:talk, :series => list, :start_time => Time.now + 60)
    end
  end

  factory :posted_talk do
    ignore do
      organizer "albert"
      speaker "bob"
    end
    title "A Talk"
    abstract "blabla."
    name_of_speaker { find_or_create(User, speaker).name }
    speaker_email { find_or_create(User, speaker).email }
    series { FactoryGirl.create(:list, :organizer => organizer) }
  end

  factory :venue, :class => List do
    name "Venue"
  end

  factory :email_subscription do
    user_id { find_or_create(User, :albert).id }
    list_id { find_or_create(List, :list) }
  end
end
