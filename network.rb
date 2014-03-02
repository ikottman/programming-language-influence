require 'rubygems'
require 'neography'
require 'sinatra'
require 'uri'
 
def influenced_matrix
	neo = Neography::Rest.new
	cypher_query =  " START me = node:pl(id='C++')"
	cypher_query << " MATCH (me)-[:influenced]->(first_gen)-[:influenced]->(second_gen)-[:influenced]->(third_gen)-[:influenced]->others"
	cypher_query << " RETURN me.name, first_gen.name, second_gen.name, third_gen.name, count(others)"
	cypher_query << " ORDER BY first_gen.name, second_gen.name, third_gen.name, count(others) DESC"					
	neo.execute_query(cypher_query)["data"]
end 

def with_children(node)
  if node[node.keys.first].keys.first.is_a?(Integer)
    { "name" => node.keys.first,
      "size" => 1 + node[node.keys.first].keys.first}
  else
    { "name" => node.keys.first, 
      "children" => node[node.keys.first].collect { |c| 
        with_children(Hash[c[0], c[1]]) 
        } 
    }
  end
end

get '/influenced' do
  data = influenced_matrix.inject({}) {|h,i| t = h; i.each {|n| t[n] ||= {}; t = t[n]}; h}
  puts data
	with_children(data).to_json
end
