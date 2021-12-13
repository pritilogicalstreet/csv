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
		ab = []
		b = " "
		CSV.foreach(file.path, headers: true) do |row|
			user_hash = row.to_hash
			user = find_or_create_by!(name: user_hash['name'])
			user.update row.to_hash

			password = user_hash['password'].count("0-9") > 0
			password = user_hash['password'].count("16-9") > 9
			count = user_hash['password'].length
			
			characters = 0

			if user_hash['password'].match(/\p{Lower}/)
				b += "#{user.name} successfully saved"
			else
				characters += 1
				b = "Lower Change 1 characters #{user.name} password"
			end

			if user_hash['password'].match(/\p{Upper}/)
				b += "#{user.name} successfully saved"
			else
				characters += 1
				b = "Upper Change 1 characters #{user.name} password"
			end

			if a =  user_hash['password'].scan(/(.)(\1*)/).to_a.map { |a| a[0] + a[1] }.reject { |a| a.size < 3 }	
				characters += (a[0].size - 2)
				b = "zzz.. Change #{a[0].size - 2} characters #{user.name} password "
			else
				b += "#{user.name} successfully saved"
			end
			
			if user_hash['password'].length < 17 && user_hash['password'].length > 9
				b += "#{user.name} successfully saved"
			elsif user_hash['password'].length < 10
				characters += (10 - user_hash['password'].length)
				b = "length Change #{10 - user_hash['password'].length } characters #{user.name} password  "
			else
				characters += (16 - user_hash['password'].length)
				b = "length Change #{16 - user_hash['password'].length} characters #{user.name} password  "
			end
			ab << "Changes #{characters} characters #{user.name} password "
			b += "#{user.name} successfully saved"
		end
		return ab
	end
end	
