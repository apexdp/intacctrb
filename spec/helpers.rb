module Helpers
  class << self
    def random_id
      return @random_id if @random_id
      number = SecureRandom.random_number.to_s
      @random_id = number[2..number.length]
    end
  end

  def current_random_id
    Helpers.random_id
  end

  def address
    OpenStruct.new({
      address1: Faker::Address.street_address,
      address2: Faker::Address.secondary_address,
      city: Faker::Address.city,
      state: Faker::Address.state_abbr,
      zipcode: Faker::Address.zip_code[0..4]
    })
  end

  def customer
    @customer ||= OpenStruct.new({
      id: current_random_id,
      intacct_system_id: current_random_id,
      name: 'RSpec Company'
    })
  end

  def vendor
    @vendor ||= OpenStruct.new({
      id: current_random_id,
      intacct_system_id: current_random_id,
      first_name: "Rspec",
      last_name: "Test",
      full_name: "Rspec Test",
      email: "test@example.com",
      ach_account_number: "123456789",
      ach_routing_number: "123456789",
      ach_account_type: "savings",
      ach_account_classification: "business",
      ach_last_updated_at: Time.now,
      billing_address: address
    })
  end

  def invoice
    @invoice ||= OpenStruct.new({
      id: current_random_id,
      intacct_system_id: current_random_id,
      date_time_created: DateTime.now,
      claim: OpenStruct.new({
        dlnumber: Faker::Number.number(6),
        claimnumber: Faker::Number.number(6),
        appraisal_type: 'auto',
        insured_full_name: Faker::Name.name,
        vehicle: OpenStruct.new({
          year: 2001,
          make: Faker::Name.name,
          model: 'A1',
          address: address
        }),
        owner: OpenStruct.new({
          insuredorclaimant: 'INSURED',
          full_name: Faker::Name.name
        })
      })
    })
  end

  def default_setup
    Intacct.setup do |config|
      config.xml_sender_id  = ENV['INTACCT_XML_SENDER_ID']
      config.xml_password   = ENV['INTACCT_XML_PASSWORD']
      config.app_user_id    = ENV['INTACCT_USER_ID']
      config.app_company_id = ENV['INTACCT_COMPANY_ID']
      config.app_password   = ENV['INTACCT_PASSWORD']
      yield if block_given?
    end
  end
end
