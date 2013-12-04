FactoryGirl.define do
  factory :albert, :class => User do
    name "Albert Einstein"
    email "albert@talks.tokyo"
    password "hoge"
    password_confirmation "hoge"
    after(:create) { |user| user.last_login = Time.zone.now }
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
    sequence(:name_of_speaker) { |n| "Speaker#{n}" }
    sequence(:speaker_email) { |n| "speaker#{n}@talks.tokyo" }
    abstract "Blablablablablablablablablablablablablablabla."
    start_time { Array(-5..5).sample.day.ago }
    end_time { |t| t.start_time + 2.hour }
    series { |t| FactoryGirl.create(:list, :ex_directory => t.ex_directory)  }
    venue { FactoryGirl.create(:venue) }
    after(:create) do |talk|
      talk.organiser_email = talk.series.users[0].email
      talk.save!
    end
  end
  
  factory :list do
    ignore do
      organizer { find_or_create(User, :albert) }
    end
    sequence(:name) { |n| "List #{n} managed by #{organizer.name}" }
    users { [ organizer ] }
    details "This list is about blablablablablablablablablablablablablabla."
  end

  factory :posted_talk do
    ignore do
      organizer { find_or_create(User, :albert) }
      speaker { find_or_create(User, :bob) }
    end
    title "A Talk"
    abstract "blabla."
    name_of_speaker { speaker.name }
    speaker_email { speaker.email }
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
