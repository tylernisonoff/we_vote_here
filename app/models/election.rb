class Election < ActiveRecord::Base
  attr_accessible :display_preference, :finish_time, :info, :name, :privacy, :start_time, :candidates_attributes
  
  # has_many :votes, dependent: destroy
  has_many :candidates, dependent: :destroy
  accepts_nested_attributes_for :candidates, reject_if: lambda { |c| c.values.all?(&:blank?) }, allow_destroy: true

  belongs_to :user # the owner of the election

  validates :user_id, presence: true

  # Privacy settings: 0 = public, 1 = private

  # Display preferences:
  # 0 = show standings and votes at all times
  # 1 = show standings during election, reveal votes after election
  # 2 = reveal results/standings and votes at end
end