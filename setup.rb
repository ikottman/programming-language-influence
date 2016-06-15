require 'rubygems'
require 'csv'
require 'json'
require 'neo4j-core'

# create nodes for each programming language
def create_graph
	session = Neo4j::Session.open(:server_db)
	nodes = []
	CSV.foreach("./setup/programming_languages.csv") do |row| 
		nodes << Neo4j::Node.create( {
			:name => row[0],
			:description => row[1],
			:num_repositories => row[2],
			:influenced => row[3] == :NULL ? "" : row[3],
			:logo => row[4] == :NULL ? "" : row[4],
			:thumbnail => row[5] == :NULL ? "" : row[5]
		 } )
	end
	puts "Created #{nodes.size} nodes"
end

# Creates the relationships between each node
def create_relationships()
	count = 0
	CSV.foreach("./setup/programming_languages.csv") do |row|
		if row[3] != 'NULL'
			first = Neo4j::Session.query("MATCH (n) WHERE n.name = '#{row[0]}' RETURN n").first.n
			for id in row[3].split('|')
				second = Neo4j::Session.query("MATCH (n) WHERE n.name = '#{id}' RETURN n").first.n
				if !(second.nil?)
					first.create_rel(:influeced, second)
					count+= 1
				end
			end
		end
	end
	puts "Created #{count} relationships"
end

# deletes all existing nodes and their relationships
def clear_graph
	session = Neo4j::Session.open(:server_db)
	session.query("MATCH (n) DETACH DELETE n")
	puts "Cleared database of nodes"
end

# delete all existing nodes/relationships, create new nodes and their relationships
begin
	clear_graph
  create_graph
  create_relationships	
end
