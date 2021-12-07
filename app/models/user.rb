class User < ApplicationRecord
	require 'csv'

	validates :name, presence: true
	validates :password, presence: true, length: { in: 10..16 }
	validate :password_lower_case
	validate :password_uppercase                               
	validate :password_contains_number
	validate :password_char

	def password_uppercase
		return if !!password.match(/\p{Upper}/)
		errors.add :password, ' must contain at least 1 uppercase '
	end

	def password_lower_case
		return if !!password.match(/\p{Lower}/)
		errors.add :password, ' must contain at least 1 lowercase '
	end

	def password_contains_number
		return if password.count("0-9") > 0
		errors.add :password, ' must contain at least one number'
	end

	def password_char
		return unless password.scan(/(.)(\1*)/).to_a.map { |a| a[0] + a[1] }.reject { |a| a.size < 3 }.present?
	
		errors.add :password, ' cannot contain three repeating characters in a row (e.g. "...zzz..." )'
	end

	def self.to_csv
		attributes = %w{ name password }
	
		CSV.generate(headers: true) do |csv|
		  csv << attributes

		  all.each do |user|
			csv << attributes.map{ |attr| user.send(attr) }
		  end
		end
	end

	def self.import(file)
		a = []
		CSV.foreach(file.path, headers: true) do |row|
			user_hash = row.to_hash
			user = find_or_create_by!(name: user_hash['name'])
			user.update row.to_hash
			user.save!
			a << "#{user.name}  was successfully saved    "		
		end
		return a
	end
end
