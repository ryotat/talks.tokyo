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
    name { |n| "User#{n}" }
    sequence(:email) { |n| "user#{n}@talks.tokyo" }
    password "hoge"
    password_confirmation { |u| u.password }
  end
  
  factory :list do
    ignore do
      organizer "albert"
    end
    name { "#{organizer}'s list" }
    talk_post_password "hoge"
    users { [ find_or_create(User, organizer) ] }
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
end
