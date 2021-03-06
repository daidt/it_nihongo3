class User < ApplicationRecord
  ratyrate_rater
	has_many :books
	has_many :reviews
  has_many :likes
  has_many :liked_book, through: :likes, source: :book
  has_many :comments
  ATTRIBUTES_PARAMS = [:name, :avatar, :login_name, :email, :genre, :password, :password_confirmation]
  attr_accessor :remember_token, :activation_token
  before_save   :downcase_email
  before_create :create_activation_digest
	validates :name, presence: true, length: { maximum: 50 }
  validates :login_name, presence: true, length: { maximum: 50 }
  validates :gender, presence: true
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
	validates :email, presence: true, length: { maximum: 255 },
		format: { with: VALID_EMAIL_REGEX },
		uniqueness: { case_sensitive: false }
	has_secure_password
	validates :password, presence: true, length: { minimum: 6 },allow_nil: true
  mount_uploader :avatar, AvatarUploader
  
	def self.digest(string)
    	cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    		BCrypt::Password.create(string, cost: cost)
  	end

  	def self.new_token
    	SecureRandom.urlsafe_base64
  	end

  	def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false if digest.nil?
          BCrypt::Password.new(digest).is_password? token
  end

  def activate
    update_columns activated: true, activated_at: Time.zone.now
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  private
   # Converts email to all lower-case.
    def downcase_email
      self.email = email.downcase
    end

    # Creates and assigns the activation token and digest.
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
