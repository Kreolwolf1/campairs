require 'spec_helper'
describe Campaing do
  it "Should create a valid campaing" do
    campaing = Campaing.new({ name: 'test',
                                 start_at: '2013-01-31T22:00:00Z',
                                 end_at: '2013-02-27T22:00:00Z',
                                 countries: "{\"test\":[\"1\"]}" })
  end
end