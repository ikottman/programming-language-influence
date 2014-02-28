require 'rubygems'
require 'neography'
require 'csv'

def create_node(row)
	Neography::Node.create_unique(:pl, :id, row[0], "id" => row[0], "description" => row[1], "influenced" => row[2],
	 "influenced by" => row[3], "thumbnail" => row[4], "full picture" => row[5], :name => row[6])
end

def influences(first, second)
	if first == nil
		puts 'hello'
	else
		first.outgoing(:influenced) << second
	end
end


#this creates the nodes
begin
	CSV.foreach("curated_programming_languages.csv") do |row|
	  #puts row[0]
	  create_node(row)		
	end
end

#This creates the relationships between each node
#id	description	influenced	influenced by	thumbnail	full picture	name
begin
	CSV.foreach("curated_programming_languages.csv") do |row|				
		if row[2] != 'NULL'
		  #puts "first id: #{row[0]}"
			first = Neography::Node.find(:pl, :id, row[0])
			for id in row[2].split('|')
				#puts "second id: #{id}"
				second = Neography::Node.find(:pl, :id, id)
				if !(second.nil? || second.empty?)
					influences(first, second)
				end		
			end
		end
	end
end
