require 'rubygems'
require 'neography'
require 'csv'
require 'pp'

def influences(first, second)
		first.outgoing(:influenced) << second
end

def create_graph
	neo = Neography::Rest.new
	languages = CSV.read("./setup/programming_languages.csv")
	#create a list of commands to create each node and execute them all at once
	commands = languages.map{ |each| [:create_unique_node, :pl, :id, each[0],{
		:name => each[0],
		:description => each[1],
		:num_repositories => each[2],
		:influenced => each[3] == :NULL ? "" : each[3],
		:logo => each[4] == :NULL ? "" : each[4],
		:thumbnail => each[5] == :NULL ? "" : each[5]
	}]
	}
	return neo.batch *commands
end

#This creates the relationships between each node
def create_relationships
	count = 0
	CSV.foreach("./setup/programming_languages.csv") do |row|				
		if row[3] != 'NULL'
			first = Neography::Node.find(:pl, :id, row[0])
			for id in row[3].split('|')
				second = Neography::Node.find(:pl, :id, id)
				if !(second.nil? || second.empty?)
					influences(first, second)
					count+= 1
				end
			end
		end
	end
	return count
end

#deletes all existing nodes and their relationships
def clear_graph
  neo = Neography::Rest.new
	neo.execute_query("MATCH (n) OPTIONAL MATCH (n)-[r]-() DELETE n,r")
end

#delete all existing nodes/relationships, create new nodes and their relationships
begin
	clear_graph
	puts "Cleared database of nodes"
	count = create_graph.count
	puts "Created #{count} nodes"
	count = create_relationships
	puts "Created #{count} relationships"
end
