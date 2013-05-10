class PollSet
  include Mongoid::Document

  field :name, type: String
  field :details, type: String
  field :active, type: Boolean, default: true
  validates :name, presence: true

  has_many :polls, dependent: :delete do
    def find_by_id(id)
      where(_id: id).first
    end

    def active_polls
      where(active: true)
    end
  end
  belongs_to :user

end
