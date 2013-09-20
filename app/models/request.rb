class Request < ActiveRecord::Base
  attr_accessible :stitch_id

  validates :stitch_id, presence: true
end
