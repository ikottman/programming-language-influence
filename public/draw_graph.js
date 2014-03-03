var graph = Viva.Graph.graph();

$.ajax("/influenced", {
    type:"GET",
    dataType:"json",
    success:function (res) {
    var arrayLength = res.length;
	for (var i = 0; i < arrayLength; i++) {
		current_node = res[i][0]['data']['name'];
		graph.addNode(current_node);
		influenced = res[i][0]['data']['influenced'].split("|");
		if (influenced != "NULL")
		{
			for (var j = 0; j < influenced.length; j++)
			{
				graph.addLink(current_node, influenced[j]);
			}
		}
	}
    }
})
var renderer = Viva.Graph.View.renderer(graph);
renderer.run();    

