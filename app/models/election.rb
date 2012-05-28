class Election < ActiveRecord::Base
  attr_accessible :display_preference, :finish_time, :info, :name, :privacy, :start_time, :candidates_attributes
  
  # has_many :votes, dependent: destroy
  has_many :candidates, dependent: :destroy
  accepts_nested_attributes_for :candidates, allow_destroy: true, reject_if: lambda { |c| c.values.all?(&:blank?) }

  belongs_to :user # the owner of the election
  validates_presence_of :user

  #validates :handle, presence: true, format: { with: VALID_HANDLE_REGEX, message: "cannot contain the '@' character" },
            uniqueness: { case_sensitive: false }, length: { minimum: 2 }   

  # Privacy: true = private, false = public

end