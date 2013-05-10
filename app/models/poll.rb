class Poll
  include Mongoid::Document

  field :name, type: String
  field :details, type: String
  field :active, type: Boolean, default: true
  validates :name, presence: true

  has_many :poll_options, dependent: :delete do
    def find_by_id(id)
      where(_id: id).first
    end
  end
  belongs_to :poll_set

end
