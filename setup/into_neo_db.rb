require 'rubygems'
require 'neography'
require 'csv'
require 'pp'

def influences(first, second)
		first.outgoing(:influenced) << second
end

def create_graph
	neo = Neography::Rest.new
	languages = CSV.read("curated_programming_languages.csv")
	#create a list of commands to create each node and execute them all at once
	commands = languages.map{ |each| [:create_unique_node, :pl, :id, each[0], {"name" => each[0], "description" => each[1], "num_repositories" => each[2]}]}
	return neo.batch *commands
end

#This creates the relationships between each node
def create_relationships
	CSV.foreach("curated_programming_languages.csv") do |row|				
		if row[3] != 'NULL'
			first = Neography::Node.find(:pl, :id, row[0])
			for id in row[3].split('|')
				second = Neography::Node.find(:pl, :id, id)
				if !(second.nil? || second.empty?)
					influences(first, second)
				end
			end
		end
	end
end


#this creates the nodes
begin
		create_graph
		create_relationships 
end
