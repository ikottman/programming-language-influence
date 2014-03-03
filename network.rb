require 'rubygems'
require 'neography'
require 'sinatra'
require 'uri'
 
def influenced_matrix
	neo = Neography::Rest.new
	cypher_query =  " MATCH (n) return (n)"
	neo.execute_query(cypher_query)["data"]
end 

get '/influenced' do
  influenced_matrix.to_json
end
