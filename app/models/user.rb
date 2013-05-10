class User
  include Mongoid::Document

  field :username, type: String
  field :password, type: String
  validates :password, presence: true, confirmation: true, length: {:minimum => 6, :maximum => 100}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :username, presence: true,
            :length => {
              :maximum => 100,
              :if => Proc.new { |user| half_width?(user.username) }
            },
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: {case_sensitive: false}

  has_many :poll_sets do
    def find_by_id(id)
      where(_id: id).first
    end
  end
  has_many :poll_answers do
    def find_by_poll(poll_id)
      find_by_id(poll_id)
    end
  end

  protected

  def half_width?(string='')
    Moji.type?(string, Moji::HAN)
  end

  def full_width?(string='')
    Moji.type?(string, Moji::ZEN)
  end

  def kata?(string='')
    Moji.type?(string, Moji::KATA)
  end

  def encrypt_password
    self.password = Digest::MD5.hexdigest(self.password)
  end
end

