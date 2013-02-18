class Campaing < ActiveRecord::Base
  attr_accessible :countries, :end_at, :name, :start_at

  validates_presence_of :countries, :name, :start_at, :end_at

  validates :start_at,
            :date => {:before => :end_at}

end
